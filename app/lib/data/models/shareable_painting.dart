import 'artist.dart';
import 'artwork.dart';
import 'cleveland_artwork.dart';
import 'museum_painting.dart';

/// What the zoom, download and share features need to know about a painting,
/// whichever collection it comes from.
class ShareablePainting {
  const ShareablePainting({
    required this.id,
    required this.titleArabic,
    required this.titleOriginal,
    required this.artistArabic,
    required this.artistOriginal,
    required this.dateText,
    required this.creditLine,
    required this.attribution,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String titleArabic;
  final String titleOriginal;
  final String artistArabic;
  final String artistOriginal;
  final String dateText;

  /// The museum's credit line for the card footer.
  final String creditLine;

  /// Source and licence, e.g. "Cleveland Museum of Art · CC0".
  final String attribution;
  final String? imageAsset;
  final String? imageUrl;

  bool get hasImage => imageAsset != null || imageUrl != null;

  /// A safe file name stem such as `washij-cma-94979`.
  String get fileStem {
    final safe = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return 'washij-${safe.isEmpty ? 'painting' : safe}';
  }

  factory ShareablePainting.fromMuseum(
    MuseumPainting painting,
  ) => ShareablePainting(
    id: painting.id,
    titleArabic: painting.titleArabic,
    titleOriginal: painting.title,
    artistArabic: painting.artistArabic,
    artistOriginal: painting.artist,
    dateText: painting.dateArabic.isNotEmpty
        ? painting.dateArabic
        : painting.date,
    creditLine: painting.credit,
    attribution:
        '${painting.source} · ${painting.licenceName} · ${painting.sourceUrl}',
    imageAsset: painting.imageAsset,
    imageUrl: painting.imageUrl,
  );

  factory ShareablePainting.fromCleveland(ClevelandArtwork artwork) =>
      ShareablePainting(
        id: 'cma-${artwork.id}',
        titleArabic: artwork.titleArabic ?? artwork.title,
        titleOriginal: artwork.title,
        artistArabic: artwork.artistDisplay,
        artistOriginal: '',
        dateText: artwork.dateDisplay,
        creditLine: artwork.creditLine,
        attribution: 'Cleveland Museum of Art · CC0 · ${artwork.sourceUrl}',
        imageUrl: artwork.imageUrl,
      );

  factory ShareablePainting.fromArtwork(Artwork artwork, Artist artist) {
    final credit = artwork.credit;
    final creditDetails = [
      credit.author.trim(),
      credit.licence.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
    return ShareablePainting(
      id: artwork.id,
      titleArabic: artwork.titleAr,
      titleOriginal: artwork.titleOrig,
      artistArabic: artist.nameAr,
      artistOriginal: artist.nameOrig,
      dateText: artwork.dateText.isNotEmpty
          ? artwork.dateText
          : '${artwork.year}',
      creditLine: creditDetails.isEmpty ? '' : creditDetails,
      attribution: credit.attribution.trim().isNotEmpty
          ? credit.attribution
          : credit.fileUrl,
      imageAsset: artwork.image?.asset,
      imageUrl: artwork.image?.remoteUrl,
    );
  }
}
