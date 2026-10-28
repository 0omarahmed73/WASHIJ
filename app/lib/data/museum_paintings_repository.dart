import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/museum_painting.dart';

class MuseumPaintingsRepository {
  MuseumPaintingsRepository({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  Future<List<MuseumPainting>> load() async {
    final text = await (_bundle ?? rootBundle).loadString(
      'assets/data/museum_paintings_ar.json',
    );
    final decoded = jsonDecode(text);
    if (decoded is! List) {
      throw const FormatException('Museum paintings data is not a list');
    }
    final paintings = decoded
        .map(
          (item) =>
              MuseumPainting.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
    final ids = paintings.map((painting) => painting.id).toSet();
    if (ids.length != paintings.length) {
      throw const FormatException('Museum paintings data has duplicate ids');
    }
    return paintings;
  }
}
