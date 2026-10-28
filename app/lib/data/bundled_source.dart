import 'dart:convert';

import 'package:flutter/services.dart';

import 'catalog.dart';
import 'models/artist.dart';
import 'models/artwork.dart';
import 'models/movement.dart';
import 'models/period.dart';

abstract interface class CatalogSource {
  Future<Catalog> load();
}

class BundledSource implements CatalogSource {
  const BundledSource({this._bundle});

  final AssetBundle? _bundle;

  @override
  Future<Catalog> load() async {
    final bundle = _bundle ?? rootBundle;
    final worksJson =
        jsonDecode(await bundle.loadString('assets/data/works.json')) as List;
    final artistsJson = jsonDecode(
      await bundle.loadString('assets/data/artists.json'),
    ) as Map<String, dynamic>;
    final movementsJson = jsonDecode(
      await bundle.loadString('assets/data/movements.json'),
    ) as Map<String, dynamic>;
    final periodsJson =
        jsonDecode(await bundle.loadString('assets/data/periods.json')) as List;

    return Catalog(
      artworks: worksJson
          .map(
            (item) => Artwork.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
      artists: artistsJson.map(
        (id, value) => MapEntry(
          id,
          Artist.fromJson(id, Map<String, dynamic>.from(value as Map)),
        ),
      ),
      movements: movementsJson.map(
        (id, value) => MapEntry(
          id,
          Movement.fromJson(id, Map<String, dynamic>.from(value as Map)),
        ),
      ),
      periods: periodsJson
          .map(
            (item) => Period.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
    );
  }
}
