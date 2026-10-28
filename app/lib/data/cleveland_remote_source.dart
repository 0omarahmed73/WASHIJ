import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/cleveland_artwork.dart';

class ClevelandRemoteSource {
  ClevelandRemoteSource({required http.Client client}) : _client = client;

  static const _apiHost = 'openaccess-api.clevelandart.org';
  static const _wikidataHost = 'query.wikidata.org';
  static const _corsProxy = 'https://proxy.cors.dev/';
  static const _timeout = Duration(seconds: 12);
  static const _wikidataBatchSize = 50;
  static const _fields =
      'id,accession_number,type,share_license_status,title,creation_date,'
      'creators,technique,measurements,creditline,tombstone,url,images';

  final http.Client _client;

  Future<List<ClevelandArtwork>> fetchPaintings({
    int page = 1,
    int limit = 12,
  }) async {
    if (page < 1) throw ArgumentError.value(page, 'page', 'Must be positive');
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100');
    }

    final baseUri = Uri.https(_apiHost, '/api/artworks/', {
      'type': 'Painting',
      'has_image': '1',
      'skip': '${(page - 1) * limit}',
      'limit': '$limit',
      'fields': _fields,
    });
    final response = await _getJson(
      baseUri.replace(query: '${baseUri.query}&cc0'),
    );
    return _buildArtworks(_records(response));
  }

  Future<List<ClevelandArtwork>> searchPaintings({
    required String query,
    int limit = 6,
  }) async {
    final searchTerm = query.trim();
    if (searchTerm.isEmpty) return const [];
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100');
    }

    final baseUri = Uri.https(_apiHost, '/api/artworks/', {
      'q': searchTerm,
      'type': 'Painting',
      'has_image': '1',
      'limit': '$limit',
      'fields': _fields,
    });
    final response = await _getJson(
      baseUri.replace(query: '${baseUri.query}&cc0'),
    );
    return _buildArtworks(_records(response));
  }

  Future<ClevelandArtwork?> fetchPaintingById(int id) async {
    if (id < 1) throw ArgumentError.value(id, 'id', 'Must be positive');
    final response = await _getJsonIfFound(
      Uri.https(_apiHost, '/api/artworks/$id', {'fields': _fields}),
    );
    if (response == null) return null;
    final rawData = response['data'];
    if (rawData is! Map) {
      throw const FormatException('Cleveland artwork data is not an object');
    }
    final record = _eligibleArtwork(rawData);
    if (record == null || record.id != id) return null;
    final paintings = await _buildArtworks([record]);
    return paintings.isEmpty ? null : paintings.single;
  }

  Future<List<ClevelandArtwork>> _buildArtworks(
    Iterable<_ClevelandRecord> records,
  ) async {
    final items = records.toList(growable: false);
    final arabicTitles = await _fetchArabicTitles(
      items.map((item) => item.accessionNumber),
    );
    return items
        .map(
          (item) => ClevelandArtwork(
            id: item.id,
            accessionNumber: item.accessionNumber,
            title: item.title,
            titleArabic: arabicTitles[item.accessionNumber],
            artistDisplay: item.artistDisplay,
            dateDisplay: item.dateDisplay,
            mediumDisplay: item.mediumDisplay,
            dimensions: item.dimensions,
            creditLine: item.creditLine,
            imageUrl: item.imageUrl,
            sourceUrl: item.sourceUrl,
          ),
        )
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final requestUri = _requestUri(uri);
    final response = await _client
        .get(requestUri, headers: const {'Accept': 'application/json'})
        .timeout(_timeout);
    return _decodeJson(response, requestUri);
  }

  Future<Map<String, dynamic>?> _getJsonIfFound(Uri uri) async {
    final requestUri = _requestUri(uri);
    final response = await _client
        .get(requestUri, headers: const {'Accept': 'application/json'})
        .timeout(_timeout);
    if (response.statusCode == 404) return null;
    return _decodeJson(response, requestUri);
  }

  Future<Map<String, dynamic>> _getSparqlJson(Uri uri) async {
    final requestUri = _requestUri(uri);
    final response = await _client
        .get(
          requestUri,
          headers: const {
            'Accept': 'application/sparql-results+json, application/json',
          },
        )
        .timeout(_timeout);
    return _decodeJson(response, requestUri);
  }

  Uri _requestUri(Uri uri) => kIsWeb ? Uri.parse('$_corsProxy$uri') : uri;

  Map<String, dynamic> _decodeJson(http.Response response, Uri uri) {
    if (response.statusCode != 200) {
      throw http.ClientException(
        'HTTP ${response.statusCode} from ${uri.host}',
        uri,
      );
    }
    if (response.bodyBytes.length > 6 * 1024 * 1024) {
      throw http.ClientException('Response is too large', uri);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Expected a JSON object response');
    }
    return Map<String, dynamic>.from(decoded);
  }

  List<_ClevelandRecord> _records(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is! List) {
      throw const FormatException('Cleveland response data is not a list');
    }
    return data.map(_eligibleArtwork).whereType<_ClevelandRecord>().toList();
  }

  Future<Map<String, String>> _fetchArabicTitles(
    Iterable<String> accessions,
  ) async {
    final values = accessions.toSet().where((item) => item.isNotEmpty).toList();
    final titleCandidates = <String, Set<String>>{};
    for (var start = 0; start < values.length; start += _wikidataBatchSize) {
      final batch = values.skip(start).take(_wikidataBatchSize).toList();
      final requested = batch
          .map((value) => '"${_sparqlString(value)}"')
          .join(' ');
      final query =
          '''
SELECT ?accession ?label WHERE {
  VALUES ?requestedAccession { $requested }
  ?artwork wdt:P11110 ?accession;
           rdfs:label ?label.
  FILTER(STR(?accession) = ?requestedAccession && LANG(?label) = "ar")
}
''';
      try {
        final response = await _getSparqlJson(
          Uri.https(_wikidataHost, '/sparql', {
            'query': query,
            'format': 'json',
          }),
        );
        final bindings =
            ((response['results'] as Map?)?['bindings'] as List?) ?? const [];
        for (final raw in bindings) {
          if (raw is! Map) continue;
          final binding = Map<String, dynamic>.from(raw);
          final accession =
              ((binding['accession'] as Map?)?['value'] as String?) ?? '';
          final label =
              ((binding['label'] as Map?)?['value'] as String?)?.trim() ?? '';
          if (batch.contains(accession) && label.isNotEmpty) {
            titleCandidates.putIfAbsent(accession, () => <String>{}).add(label);
          }
        }
      } on Object {
        // Arabic labels are optional; the verified museum title remains usable.
        break;
      }
    }
    return {
      for (final entry in titleCandidates.entries)
        if (entry.value.length == 1) entry.key: entry.value.single,
    };
  }

  static _ClevelandRecord? _eligibleArtwork(Object? raw) {
    if (raw is! Map) return null;
    final item = Map<String, dynamic>.from(raw);
    final id = item['id'];
    final accession = item['accession_number'];
    final title = item['title'];
    final imageUrl = _webImageUrl(item['images']);
    final sourceUrl = _validatedMuseumUrl(item['url']);
    final creditLine = _string(item['creditline']).isNotEmpty
        ? _string(item['creditline'])
        : _string(item['tombstone']);
    if (id is! int ||
        accession is! String ||
        accession.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        item['type'] != 'Painting' ||
        item['share_license_status'] != 'CC0' ||
        imageUrl == null ||
        sourceUrl == null ||
        creditLine.isEmpty) {
      return null;
    }
    return _ClevelandRecord(
      id: id,
      accessionNumber: accession.trim(),
      title: title.trim(),
      artistDisplay: _creators(item['creators']),
      dateDisplay: _string(item['creation_date']),
      mediumDisplay: _string(item['technique']),
      dimensions: _string(item['measurements']),
      creditLine: creditLine,
      imageUrl: imageUrl,
      sourceUrl: sourceUrl,
    );
  }

  static String? _webImageUrl(Object? value) {
    if (value is! Map) return null;
    final web = value['web'];
    final rawUrl = web is Map ? web['url'] : null;
    if (rawUrl is! String) return null;
    final uri = Uri.tryParse(rawUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'openaccess-cdn.clevelandart.org' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasFragment) {
      return null;
    }
    return uri.toString();
  }

  static String? _validatedMuseumUrl(Object? value) {
    if (value is! String) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        !{'clevelandart.org', 'www.clevelandart.org'}.contains(uri.host) ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      return null;
    }
    return uri.toString();
  }

  static String _creators(Object? value) {
    if (value is! List) return '';
    return value
        .whereType<Map>()
        .map((creator) => _string(creator['description']))
        .where((name) => name.isNotEmpty)
        .join(', ');
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static String _sparqlString(String value) =>
      value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
}

class _ClevelandRecord {
  const _ClevelandRecord({
    required this.id,
    required this.accessionNumber,
    required this.title,
    required this.artistDisplay,
    required this.dateDisplay,
    required this.mediumDisplay,
    required this.dimensions,
    required this.creditLine,
    required this.imageUrl,
    required this.sourceUrl,
  });

  final int id;
  final String accessionNumber;
  final String title;
  final String artistDisplay;
  final String dateDisplay;
  final String mediumDisplay;
  final String dimensions;
  final String creditLine;
  final String imageUrl;
  final String sourceUrl;
}
