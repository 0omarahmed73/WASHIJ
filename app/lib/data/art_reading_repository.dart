import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import 'models/art_reading.dart';

class ArtReadingRepository {
  ArtReadingRepository({required http.Client client}) : _client = client;

  static const _cacheKey = 'washij.art-readings.v1';
  static const _maxCacheItems = 30;
  static const _maxExcerptLength = 260;
  static const _requestTimeout = Duration(seconds: 12);
  static const _corsProxy = 'https://proxy.cors.dev/';
  static const _allowedArticleHosts = {
    'shamsb52.substack.com',
    'sabahfenoon.blogspot.com',
  };

  static const _sources = [
    _RssSource(
      name: 'نشرة شَمْس',
      feedUrl: 'https://shamsb52.substack.com/feed',
      keywords: ['لوحة', 'لوحات', 'الفن', 'فنان', 'رسام', 'العشاء الأخير'],
    ),
    _RssSource(
      name: 'صباح فنون',
      feedUrl: 'https://sabahfenoon.blogspot.com/feeds/posts/default?alt=rss&max-results=12',
      keywords: ['لوحة', 'لوحات', 'الفن', 'فنون', 'فنان', 'رسام', 'تشكيل'],
    ),
  ];

  final http.Client _client;

  Future<List<ArtReading>> load() async {
    final cached = await _readCache();
    try {
      var failedSources = 0;
      final results = await Future.wait(
        _sources.map((source) async {
          try {
            return await _fetchSource(source);
          } on Object {
            failedSources++;
            return const <ArtReading>[];
          }
        }),
        eagerError: false,
      );
      if (failedSources == _sources.length && cached.isEmpty) {
        throw http.ClientException('Unable to load Arabic art-reading feeds');
      }
      final readings = <String, ArtReading>{};
      for (final sourceReadings in results) {
        for (final reading in sourceReadings) {
          readings.putIfAbsent(reading.url, () => reading);
        }
      }
      final fresh = readings.values.toList()
        ..sort((a, b) => _dateOrder(a.publishedAt, b.publishedAt));
      if (fresh.isNotEmpty) await _writeCache(fresh);
      return fresh.isNotEmpty ? fresh : cached;
    } on Object {
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<ArtReading>> _fetchSource(_RssSource source) async {
    final feedUri = Uri.parse(source.feedUrl);
    final requestUri = kIsWeb ? Uri.parse('$_corsProxy$feedUri') : feedUri;
    final response = await _client
        .get(
          requestUri,
          headers: const {
            'Accept': 'application/rss+xml, application/atom+xml, application/xml, text/xml',
          },
        )
        .timeout(_requestTimeout);
    if (response.statusCode != 200) {
      throw http.ClientException(
        'HTTP ${response.statusCode} while reading ${source.name}',
        requestUri,
      );
    }
    if (response.bodyBytes.length > 6 * 1024 * 1024) {
      throw http.ClientException('Feed response is too large', requestUri);
    }

    final document = XmlDocument.parse(utf8.decode(response.bodyBytes));
    final rssItems = document.findAllElements('item');
    final entries = rssItems.isNotEmpty
        ? rssItems.toList(growable: false)
        : document
              .findAllElements(
                'entry',
                namespaceUri: 'http://www.w3.org/2005/Atom',
              )
              .toList(growable: false);

    final readings = <ArtReading>[];
    for (final entry in entries) {
      final title = _elementText(entry, {'title'});
      final url = _link(entry);
      if (title.isEmpty || !_isArtRelated(title, source.keywords)) continue;
      if (!_validSourceUrl(url)) continue;

      final publishedAt =
          DateTime.tryParse(
            _elementText(entry, {'pubDate', 'published', 'updated'}),
          ) ??
          _parseRssDate(_elementText(entry, {'pubDate'}));
      final excerpt = _plainText(
        _elementText(entry, {'description', 'summary', 'content', 'encoded'}),
      );
      final author = _elementText(entry, {'author', 'creator'});
      final id = _elementText(entry, {'guid', 'id'});

      readings.add(
        ArtReading(
          id: id.isEmpty ? url : id,
          title: title,
          subtitle: _truncate(excerpt, _maxExcerptLength),
          publication: source.name,
          author: _displayAuthor(author),
          publishedAt: publishedAt,
          url: url,
        ),
      );
    }
    return readings;
  }

  Future<List<ArtReading>> _readCache() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final value = preferences.getString(_cacheKey);
      if (value == null) return const [];
      final records = (jsonDecode(value) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      return records
          .map(ArtReading.fromJson)
          .where((reading) => _validSourceUrl(reading.url))
          .take(_maxCacheItems)
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  Future<void> _writeCache(List<ArtReading> readings) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        readings
            .take(_maxCacheItems)
            .map((reading) => reading.toJson())
            .toList(),
      );
      await preferences.setString(_cacheKey, encoded);
    } on Object {
      // A cache failure must not block fresh public feed results.
    }
  }

  static String _elementText(XmlElement element, Set<String> names) {
    for (final child in element.children.whereType<XmlElement>()) {
      if (names.contains(child.name.local)) return child.innerText.trim();
    }
    return '';
  }

  static String _link(XmlElement entry) {
    for (final child in entry.children.whereType<XmlElement>()) {
      if (child.name.local != 'link') continue;
      final href = child.getAttribute('href');
      final value = href ?? child.innerText.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  static bool _isArtRelated(String title, List<String> keywords) {
    final lower = title.toLowerCase();
    return keywords.any(lower.contains) ||
        lower.contains('painting') ||
        lower.contains('artwork');
  }

  static String _displayAuthor(String value) {
    final author = value.trim();
    final match = RegExp(r'\(([^()]*)\)\s*$').firstMatch(author);
    return match?.group(1)?.trim() ?? author;
  }

  static DateTime? _parseRssDate(String value) {
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } on FormatException {
      // RSS dates commonly use RFC 822, which DateTime.parse may not accept.
      final match = RegExp(
        r'^(?:\w{3},?\s+)?(\d{1,2})\s+(\w{3})\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})',
      ).firstMatch(value);
      if (match == null) return null;
      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      final month = months[match.group(2)];
      if (month == null) return null;
      return DateTime.utc(
        int.parse(match.group(3)!),
        month,
        int.parse(match.group(1)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
      );
    }
  }

  static String _plainText(String value) {
    final withoutTags = value
        .replaceAll(
          RegExp(r'<(script|style)\b[^>]*>.*?</\1>', dotAll: true),
          ' ',
        )
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
          final codePoint = int.tryParse(match.group(1)!);
          return codePoint == null ? ' ' : String.fromCharCode(codePoint);
        })
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return withoutTags;
  }

  static String _truncate(String value, int maxLength) {
    final codePoints = value.runes.toList(growable: false);
    if (codePoints.length <= maxLength) return value;
    return '${String.fromCharCodes(codePoints.take(maxLength))}…';
  }

  static int _dateOrder(DateTime? left, DateTime? right) {
    if (left == null) return right == null ? 0 : 1;
    if (right == null) return -1;
    return right.compareTo(left);
  }

  static bool _validSourceUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.userInfo.isEmpty &&
        !uri.hasPort &&
        _allowedArticleHosts.contains(uri.host);
  }
}

class _RssSource {
  const _RssSource({
    required this.name,
    required this.feedUrl,
    required this.keywords,
  });

  final String name;
  final String feedUrl;
  final List<String> keywords;
}
