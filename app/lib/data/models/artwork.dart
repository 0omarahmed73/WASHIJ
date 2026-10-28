class Artwork {
  const Artwork({
    required this.id,
    required this.qid,
    required this.titleAr,
    required this.titleOrig,
    required this.artistId,
    required this.movementId,
    required this.year,
    required this.dateText,
    required this.medium,
    required this.dimensions,
    required this.collection,
    required this.place,
    required this.poem,
    required this.intro,
    required this.story,
    required this.reading,
    required this.details,
    required this.interpretations,
    required this.related,
    required this.sources,
    required this.image,
    required this.credit,
    required this.commonsFile,
    required this.wikipediaTitle,
  });

  final String id;
  final String qid;
  final String titleAr;
  final String titleOrig;
  final String artistId;
  final String movementId;
  final int year;
  final String dateText;
  final String medium;
  final String dimensions;
  final String collection;
  final String place;
  final String poem;
  final String intro;
  final List<String> story;
  final List<String> reading;
  final List<ArtworkDetail> details;
  final List<Interpretation> interpretations;
  final List<RelatedArtwork> related;
  final List<SourceReference> sources;
  final ArtworkImage? image;
  final ArtworkCredit credit;
  final String commonsFile;
  final String wikipediaTitle;

  Artwork copyWith({
    String? titleAr,
    String? dateText,
    String? medium,
    String? dimensions,
    String? collection,
    String? place,
    ArtworkImage? image,
    ArtworkCredit? credit,
  }) => Artwork(
    id: id,
    qid: qid,
    titleAr: titleAr ?? this.titleAr,
    titleOrig: titleOrig,
    artistId: artistId,
    movementId: movementId,
    year: year,
    dateText: dateText ?? this.dateText,
    medium: medium ?? this.medium,
    dimensions: dimensions ?? this.dimensions,
    collection: collection ?? this.collection,
    place: place ?? this.place,
    poem: poem,
    intro: intro,
    story: story,
    reading: reading,
    details: details,
    interpretations: interpretations,
    related: related,
    sources: sources,
    image: image ?? this.image,
    credit: credit ?? this.credit,
    commonsFile: commonsFile,
    wikipediaTitle: wikipediaTitle,
  );

  factory Artwork.fromJson(Map<String, dynamic> json) => Artwork(
    id: json['id'] as String,
    qid: json['qid'] as String,
    titleAr: json['titleAr'] as String,
    titleOrig: json['titleOrig'] as String,
    artistId: json['artistId'] as String,
    movementId: json['movementId'] as String,
    year: (json['year'] as num).toInt(),
    dateText: json['dateText'] as String? ?? '',
    medium: json['medium'] as String? ?? '',
    dimensions: json['dimensions'] as String? ?? '',
    collection: json['collection'] as String? ?? '',
    place: json['place'] as String? ?? '',
    poem: json['poem'] as String,
    intro: json['intro'] as String? ?? '',
    story: _strings(json['story']),
    reading: _strings(json['reading']),
    details: ((json['details'] as List<dynamic>?) ?? const [])
        .map(
          (item) =>
              ArtworkDetail.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
    interpretations: ((json['interpretations'] as List<dynamic>?) ?? const [])
        .map(
          (item) =>
              Interpretation.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
    related: ((json['related'] as List<dynamic>?) ?? const [])
        .map(
          (item) =>
              RelatedArtwork.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
    sources: ((json['sources'] as List<dynamic>?) ?? const [])
        .map(
          (item) =>
              SourceReference.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
    image: json['image'] == null
        ? null
        : ArtworkImage.fromJson(
            Map<String, dynamic>.from(json['image'] as Map),
          ),
    credit: ArtworkCredit.fromJson(
      Map<String, dynamic>.from(json['credit'] as Map),
    ),
    commonsFile: json['commonsFile'] as String? ?? '',
    wikipediaTitle: json['wikipediaTitle'] as String? ?? '',
  );

  static List<String> _strings(Object? value) =>
      ((value as List<dynamic>?) ?? const []).cast<String>();
}

class ArtworkImage {
  const ArtworkImage({
    required this.asset,
    required this.width,
    required this.height,
    this.remoteUrl,
  });

  final String asset;
  final int width;
  final int height;
  final String? remoteUrl;

  ArtworkImage copyWith({String? remoteUrl}) => ArtworkImage(
    asset: asset,
    width: width,
    height: height,
    remoteUrl: remoteUrl ?? this.remoteUrl,
  );

  factory ArtworkImage.fromJson(Map<String, dynamic> json) => ArtworkImage(
    asset: json['asset'] as String,
    width: (json['width'] as num).toInt(),
    height: (json['height'] as num).toInt(),
    remoteUrl: json['remoteUrl'] as String?,
  );
}

class ArtworkCredit {
  const ArtworkCredit({
    required this.author,
    required this.licence,
    required this.fileUrl,
    required this.articleUrl,
    required this.attribution,
    this.fetchedAt,
    this.isFallback = true,
  });

  final String author;
  final String licence;
  final String fileUrl;
  final String articleUrl;
  final String attribution;
  final DateTime? fetchedAt;
  final bool isFallback;

  factory ArtworkCredit.fromJson(Map<String, dynamic> json) => ArtworkCredit(
    author: json['author'] as String,
    licence: json['licence'] as String,
    fileUrl: json['fileUrl'] as String,
    articleUrl: json['articleUrl'] as String,
    attribution:
        json['attribution'] as String? ?? 'Wikimedia Commons contributors',
    fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? ''),
    isFallback: json['isFallback'] as bool? ?? true,
  );
}

class ArtworkDetail {
  const ArtworkDetail({required this.title, required this.text, this.crop});

  final String title;
  final String text;
  final CropRect? crop;

  factory ArtworkDetail.fromJson(Map<String, dynamic> json) => ArtworkDetail(
    title: json['title'] as String,
    text: json['text'] as String,
    crop: json['crop'] == null
        ? null
        : CropRect.fromJson(Map<String, dynamic>.from(json['crop'] as Map)),
  );
}

class CropRect {
  const CropRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  factory CropRect.fromJson(Map<String, dynamic> json) => CropRect(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['w'] as num).toDouble(),
    height: (json['h'] as num).toDouble(),
  );
}

class Interpretation {
  const Interpretation({required this.text, required this.attribution});

  final String text;
  final String attribution;

  factory Interpretation.fromJson(Map<String, dynamic> json) => Interpretation(
    text: json['text'] as String,
    attribution: json['attribution'] as String,
  );
}

class RelatedArtwork {
  const RelatedArtwork({required this.artworkId, required this.reason});

  final String artworkId;
  final String reason;

  factory RelatedArtwork.fromJson(Map<String, dynamic> json) => RelatedArtwork(
    artworkId: json['artworkId'] as String,
    reason: json['reason'] as String,
  );
}

class SourceReference {
  const SourceReference({required this.title, required this.url});

  final String title;
  final String url;

  factory SourceReference.fromJson(Map<String, dynamic> json) =>
      SourceReference(
        title: json['title'] as String,
        url: json['url'] as String,
      );
}
