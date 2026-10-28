class ClevelandArtwork {
  const ClevelandArtwork({
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
    this.titleArabic,
  });

  final int id;
  final String accessionNumber;
  final String title;
  final String? titleArabic;
  final String artistDisplay;
  final String dateDisplay;
  final String mediumDisplay;
  final String dimensions;
  final String creditLine;
  final String imageUrl;
  final String sourceUrl;

  String get displayTitle => titleArabic ?? title;
}
