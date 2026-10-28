import 'models/artist.dart';
import 'models/artwork.dart';
import 'models/movement.dart';
import 'models/period.dart';

class Catalog {
  const Catalog({
    required this.artworks,
    required this.artists,
    required this.movements,
    required this.periods,
  });

  final List<Artwork> artworks;
  final Map<String, Artist> artists;
  final Map<String, Movement> movements;
  final List<Period> periods;

  Artwork? artwork(String id) =>
      _firstOrNull(artworks, (item) => item.id == id);

  List<Artwork> worksByArtist(String id) =>
      artworks.where((item) => item.artistId == id).toList(growable: false);

  List<Artwork> worksInMovement(String id) =>
      artworks.where((item) => item.movementId == id).toList(growable: false);

  static T? _firstOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}
