class MuseumPainting {
  const MuseumPainting({
    required this.id,
    required this.source,
    required this.title,
    required this.titleArabic,
    required this.artist,
    required this.artistArabic,
    required this.date,
    required this.dateArabic,
    required this.medium,
    required this.mediumArabic,
    required this.dimensions,
    required this.origin,
    required this.originArabic,
    required this.credit,
    required this.sourceUrl,
    required this.imageAsset,
    required this.imageUrl,
    required this.licence,
    required this.descriptionArabic,
    required this.translationStatus,
  });

  final String id;
  final String source;
  final String title;
  final String titleArabic;
  final String artist;
  final String artistArabic;
  final String date;
  final String dateArabic;
  final String medium;
  final String mediumArabic;
  final String dimensions;
  final String origin;
  final String originArabic;
  final String credit;
  final String sourceUrl;
  final String? imageAsset;
  final String? imageUrl;
  final String licence;
  final String descriptionArabic;
  final String translationStatus;

  bool get isArtInstitute => source == 'Art Institute of Chicago';

  String get licenceName => isArtInstitute ? 'CC BY 4.0' : 'CC0';

  String get licenceUrl => isArtInstitute
      ? 'https://creativecommons.org/licenses/by/4.0/'
      : 'https://creativecommons.org/publicdomain/zero/1.0/';

  String get sourceNameArabic =>
      isArtInstitute ? 'معهد شيكاغو للفنون' : 'متحف كليفلاند للفنون';

  factory MuseumPainting.fromJson(Map<String, dynamic> json) {
    final source = _requiredString(json, 'source');
    final expectedLicence = switch (source) {
      'Art Institute of Chicago' =>
        'Description CC BY 4.0; public-domain artwork',
      'Cleveland Museum of Art' => 'CC0',
      _ => throw const FormatException('Unknown museum source'),
    };
    if (json['licence'] != expectedLicence) {
      throw const FormatException('Unexpected artwork licence');
    }

    final page = _httpsUrl(
      _requiredString(json, 'page'),
      source == 'Art Institute of Chicago'
          ? const {'www.artic.edu'}
          : const {'clevelandart.org', 'www.clevelandart.org'},
    );
    final rawImage = json['image'];
    final image = rawImage is String && rawImage.isNotEmpty
        ? _httpsUrl(
            rawImage,
            source == 'Art Institute of Chicago'
                ? const {'www.artic.edu'}
                : const {'openaccess-cdn.clevelandart.org'},
          )
        : null;

    return MuseumPainting(
      id: _requiredString(json, 'id'),
      source: source,
      title: _requiredString(json, 'title'),
      titleArabic: _requiredString(json, 'title_ar'),
      artist: _string(json['artist']),
      artistArabic: _requiredString(json, 'artist_ar'),
      date: _string(json['date']),
      dateArabic: _string(json['date_ar']),
      medium: _string(json['medium']),
      mediumArabic: _string(json['medium_ar']),
      dimensions: _string(json['dimensions']),
      origin: _string(json['origin']),
      originArabic: _string(json['origin_ar']),
      credit: _string(json['credit']),
      sourceUrl: page,
      imageAsset: _museumImageAsset(json['image_asset']),
      imageUrl: image,
      licence: expectedLicence,
      descriptionArabic: _requiredString(json, 'description_ar'),
      translationStatus: _requiredString(json, 'translation'),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Museum painting is missing $key');
    }
    return value.trim();
  }

  static String _string(Object? value) => value is String ? value.trim() : '';

  static String? _museumImageAsset(Object? value) {
    if (value == null) return null;
    if (value is! String) {
      throw const FormatException('Invalid museum artwork asset');
    }
    final path = value.trim();
    if (!path.startsWith('assets/images/museum_paintings/') ||
        !path.endsWith('.webp') ||
        path.contains('..') ||
        path.contains('\\')) {
      throw const FormatException('Invalid museum artwork asset');
    }
    return path;
  }

  static String _httpsUrl(String value, Set<String> allowedHosts) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        !allowedHosts.contains(uri.host) ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      throw const FormatException('Invalid museum artwork URL');
    }
    return uri.toString();
  }
}
