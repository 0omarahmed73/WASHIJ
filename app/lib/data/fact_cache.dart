import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/remote_artwork_data.dart';

abstract interface class ArtworkCache {
  Future<Map<String, RemoteArtworkData>> readAll(Iterable<String> qids);
  Future<void> writeAll(Map<String, RemoteArtworkData> records);
}

class FactCache implements ArtworkCache {
  const FactCache({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const _prefix = 'washij.remote.v1.';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<Map<String, RemoteArtworkData>> readAll(Iterable<String> qids) async {
    final prefs = await _preferences();
    final result = <String, RemoteArtworkData>{};
    for (final qid in qids) {
      final raw = prefs.getString('$_prefix$qid');
      if (raw == null) continue;
      try {
        result[qid] = RemoteArtworkData.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } on FormatException {
        await prefs.remove('$_prefix$qid');
      } on TypeError {
        await prefs.remove('$_prefix$qid');
      }
    }
    return result;
  }

  @override
  Future<void> writeAll(Map<String, RemoteArtworkData> records) async {
    final prefs = await _preferences();
    for (final entry in records.entries) {
      await prefs.setString(
        '$_prefix${entry.key}',
        jsonEncode(entry.value.toJson()),
      );
    }
  }
}
