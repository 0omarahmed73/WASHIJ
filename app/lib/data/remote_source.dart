import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/artwork.dart';
import 'models/remote_artwork_data.dart';

abstract interface class ArtworkRemoteSource {
  Future<Map<String, RemoteArtworkData>> fetchFor(List<Artwork> artworks);
}

class RemoteSource implements ArtworkRemoteSource {
  RemoteSource({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 6);
  static const _wikidataEndpoint = 'www.wikidata.org';
  static const _commonsEndpoint = 'commons.wikimedia.org';
  final http.Client _client;

  void close() => _client.close();

  @override
  Future<Map<String, RemoteArtworkData>> fetchFor(
    List<Artwork> artworks,
  ) async {
    final worksWithImages = artworks
        .where((work) => work.image != null)
        .toList();
    final records = <String, RemoteArtworkData>{};
    final facts = await _fetchWikidata(artworks);
    records.addAll(facts);
    final credits = await _fetchCommons(worksWithImages);
    for (final entry in credits.entries) {
      final previous = records[entry.key];
      records[entry.key] = previous == null
          ? entry.value
          : previous.merge(entry.value);
    }
    return records;
  }

  Future<Map<String, RemoteArtworkData>> _fetchWikidata(
    List<Artwork> artworks,
  ) async {
    if (artworks.isEmpty) return const {};
    try {
      final entitiesJson = await _getJson(_wikidataEndpoint, '/w/api.php', {
        'action': 'wbgetentities',
        'ids': artworks.map((work) => work.qid).join('|'),
        'props': 'labels|claims|sitelinks',
        'languages': 'ar|en',
        'sitefilter': 'arwiki|enwiki',
        'format': 'json',
        'origin': '*',
      });
      final entities = Map<String, dynamic>.from(
        entitiesJson['entities'] as Map,
      );
      final referenceIds = <String>{};
      for (final raw in entities.values) {
        final entity = Map<String, dynamic>.from(raw as Map);
        for (final property in ['P186', 'P195', 'P1071', 'P276']) {
          for (final value in _itemValues(entity, property)) {
            referenceIds.add(value);
          }
        }
      }
      final referenceLabels = await _fetchLabels(referenceIds);
      final now = DateTime.now().toUtc();
      return {
        for (final artwork in artworks)
          if (entities[artwork.qid] case final raw?)
            artwork.qid: _factsFromEntity(
              artwork,
              Map<String, dynamic>.from(raw as Map),
              referenceLabels,
              now,
            ),
      };
    } on Object {
      return const {};
    }
  }

  Future<Map<String, String>> _fetchLabels(Set<String> ids) async {
    if (ids.isEmpty) return const {};
    try {
      final data = await _getJson(_wikidataEndpoint, '/w/api.php', {
        'action': 'wbgetentities',
        'ids': ids.join('|'),
        'props': 'labels',
        'languages': 'ar|en',
        'format': 'json',
        'origin': '*',
      });
      final entities = Map<String, dynamic>.from(data['entities'] as Map);
      return {
        for (final entry in entities.entries)
          entry.key: ?_entityLabel(
            Map<String, dynamic>.from(entry.value as Map),
          ),
      };
    } on Object {
      return const {};
    }
  }

  RemoteArtworkData _factsFromEntity(
    Artwork artwork,
    Map<String, dynamic> entity,
    Map<String, String> referenceLabels,
    DateTime fetchedAt,
  ) {
    final claims = Map<String, dynamic>.from(
      (entity['claims'] as Map?) ?? const {},
    );
    final sitelinks = Map<String, dynamic>.from(
      (entity['sitelinks'] as Map?) ?? const {},
    );
    final arLabel = _labelFor(entity, 'ar');
    final dateText = _dateText(_firstValue(claims, 'P571'));
    final mediums = _itemValues(
      entity,
      'P186',
    ).map((id) => referenceLabels[id]).whereType<String>().toSet().join('، ');
    final collectionId = _itemValues(entity, 'P195').firstOrNull;
    final placeId = [
      ..._itemValues(entity, 'P1071'),
      ..._itemValues(entity, 'P276'),
    ].firstOrNull;
    final article = _articleUrl(sitelinks);
    final height = _dimensionCm(_firstValue(claims, 'P2048'));
    final width = _dimensionCm(_firstValue(claims, 'P2049'));
    final dimensionText = height != null && width != null
        ? '${_formatNumber(height)} × ${_formatNumber(width)} سم'
        : null;

    return RemoteArtworkData(
      qid: artwork.qid,
      fetchedAt: fetchedAt,
      titleAr: arLabel,
      dateText: dateText,
      medium: mediums.isEmpty ? null : mediums,
      dimensions: dimensionText,
      collection: collectionId == null ? null : referenceLabels[collectionId],
      place: placeId == null ? null : referenceLabels[placeId],
      articleUrl: article,
    );
  }

  Future<Map<String, RemoteArtworkData>> _fetchCommons(
    List<Artwork> artworks,
  ) async {
    if (artworks.isEmpty) return const {};
    try {
      final titles = artworks
          .map((work) => 'File:${work.commonsFile}')
          .join('|');
      final data = await _getJson(_commonsEndpoint, '/w/api.php', {
        'action': 'query',
        'titles': titles,
        'prop': 'imageinfo',
        'iiprop': 'url|extmetadata',
        'format': 'json',
        'origin': '*',
      });
      final pages = Map<String, dynamic>.from(
        (data['query'] as Map)['pages'] as Map,
      );
      final byTitle = <String, Artwork>{
        for (final work in artworks)
          _normaliseFileTitle(work.commonsFile): work,
      };
      final now = DateTime.now().toUtc();
      final result = <String, RemoteArtworkData>{};
      for (final raw in pages.values) {
        final page = Map<String, dynamic>.from(raw as Map);
        final title = _normaliseFileTitle(page['title'] as String? ?? '');
        final work = byTitle[title];
        if (work == null) continue;
        final imageInfo =
            ((page['imageinfo'] as List<dynamic>?) ?? const []).firstOrNull;
        if (imageInfo == null) continue;
        final info = Map<String, dynamic>.from(imageInfo as Map);
        final metadata = Map<String, dynamic>.from(
          (info['extmetadata'] as Map?) ?? const {},
        );
        final imageUrl = _trustedUrl(
          info['url'] as String?,
          'upload.wikimedia.org',
        );
        final fileUrl = _trustedUrl(
          info['descriptionurl'] as String?,
          'commons.wikimedia.org',
        );
        result[work.qid] = RemoteArtworkData(
          qid: work.qid,
          fetchedAt: now,
          imageUrl: imageUrl,
          author: _metadataText(metadata, 'Artist'),
          licence: _metadataText(metadata, 'LicenseShortName'),
          fileUrl: fileUrl,
        );
      }
      return result;
    } on Object {
      return const {};
    }
  }

  Future<Map<String, dynamic>> _getJson(
    String host,
    String path,
    Map<String, String> query,
  ) async {
    final response = await _client
        .get(Uri.https(host, path, query))
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode} from $host');
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static List<String> _itemValues(
    Map<String, dynamic> entity,
    String property,
  ) {
    final claims = entity['claims'];
    if (claims is! Map) return const [];
    final statements = claims[property];
    if (statements is! List) return const [];
    return [for (final raw in statements) ?_itemId(raw)];
  }

  static String? _itemId(Object? statement) {
    if (statement is! Map) return null;
    final value =
        ((statement['mainsnak'] as Map?)?['datavalue'] as Map?)?['value'];
    if (value is! Map) return null;
    final id = value['id'];
    return id is String ? id : null;
  }

  static Object? _firstValue(Map<String, dynamic> claims, String property) {
    final statements = claims[property];
    if (statements is! List || statements.isEmpty) return null;
    final statement = statements.first;
    if (statement is! Map) return null;
    return ((statement['mainsnak'] as Map?)?['datavalue'] as Map?)?['value'];
  }

  static String? _labelFor(Map<String, dynamic> entity, String language) {
    final labels = entity['labels'];
    if (labels is! Map) return null;
    final item = labels[language];
    return item is Map ? item['value'] as String? : null;
  }

  static String? _entityLabel(Map<String, dynamic> entity) =>
      _labelFor(entity, 'ar') ?? _labelFor(entity, 'en');

  static String? _articleUrl(Map<String, dynamic> sitelinks) {
    final raw = sitelinks['arwiki'] ?? sitelinks['enwiki'];
    if (raw is! Map) return null;
    final site = raw['site'] as String?;
    final title = raw['title'] as String?;
    if (site == null ||
        (site != 'arwiki' && site != 'enwiki') ||
        title == null ||
        title.isEmpty) {
      return null;
    }
    final language = site.substring(0, 2);
    final safeTitle = Uri.encodeComponent(title.replaceAll(' ', '_'));
    return 'https://$language.wikipedia.org/wiki/$safeTitle';
  }

  static String? _dateText(Object? value) {
    if (value is! Map) return null;
    final time = value['time'];
    if (time is! String) return null;
    final match = RegExp(r'^\+?(\d+)-(\d{2})').firstMatch(time);
    if (match == null) return null;
    final year = match.group(1)!;
    final month = int.tryParse(match.group(2)!);
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return month != null && month > 0 && month < months.length
        ? '${months[month]} $year'
        : year;
  }

  static double? _dimensionCm(Object? value) {
    if (value is! Map) return null;
    final amount = double.tryParse(
      (value['amount'] as String? ?? '').replaceFirst('+', ''),
    );
    if (amount == null) return null;
    final unit = value['unit'] as String? ?? '';
    if (unit.endsWith('/Q11573')) return amount * 100;
    if (unit.endsWith('/Q174789')) return amount / 10;
    return amount;
  }

  static String _formatNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);

  static String _normaliseFileTitle(String title) =>
      title.replaceFirst(RegExp(r'^File:'), '').replaceAll('_', ' ').trim();

  static String? _metadataText(Map<String, dynamic> metadata, String key) {
    final value = metadata[key];
    if (value is! Map || value['value'] is! String) return null;
    final plain = (value['value'] as String)
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return plain.isEmpty ? null : plain;
  }

  static String? _trustedUrl(String? value, String host) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    return uri?.scheme == 'https' && uri?.host == host ? value : null;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
