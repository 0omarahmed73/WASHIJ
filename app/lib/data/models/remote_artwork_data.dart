import 'artwork.dart';

class RemoteArtworkData {
  const RemoteArtworkData({
    required this.qid,
    required this.fetchedAt,
    this.titleAr,
    this.dateText,
    this.medium,
    this.dimensions,
    this.collection,
    this.place,
    this.imageUrl,
    this.author,
    this.licence,
    this.fileUrl,
    this.articleUrl,
  });

  final String qid;
  final DateTime fetchedAt;
  final String? titleAr;
  final String? dateText;
  final String? medium;
  final String? dimensions;
  final String? collection;
  final String? place;
  final String? imageUrl;
  final String? author;
  final String? licence;
  final String? fileUrl;
  final String? articleUrl;

  RemoteArtworkData merge(RemoteArtworkData newer) => RemoteArtworkData(
    qid: qid,
    fetchedAt: newer.fetchedAt,
    titleAr: newer.titleAr ?? titleAr,
    dateText: newer.dateText ?? dateText,
    medium: newer.medium ?? medium,
    dimensions: newer.dimensions ?? dimensions,
    collection: newer.collection ?? collection,
    place: newer.place ?? place,
    imageUrl: newer.imageUrl ?? imageUrl,
    author: newer.author ?? author,
    licence: newer.licence ?? licence,
    fileUrl: newer.fileUrl ?? fileUrl,
    articleUrl: newer.articleUrl ?? articleUrl,
  );

  factory RemoteArtworkData.fromJson(Map<String, dynamic> json) =>
      RemoteArtworkData(
        qid: json['qid'] as String,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        titleAr: json['titleAr'] as String?,
        dateText: json['dateText'] as String?,
        medium: json['medium'] as String?,
        dimensions: json['dimensions'] as String?,
        collection: json['collection'] as String?,
        place: json['place'] as String?,
        imageUrl: json['imageUrl'] as String?,
        author: json['author'] as String?,
        licence: json['licence'] as String?,
        fileUrl: json['fileUrl'] as String?,
        articleUrl: json['articleUrl'] as String?,
      );

  Map<String, Object?> toJson() => {
    'qid': qid,
    'fetchedAt': fetchedAt.toUtc().toIso8601String(),
    'titleAr': titleAr,
    'dateText': dateText,
    'medium': medium,
    'dimensions': dimensions,
    'collection': collection,
    'place': place,
    'imageUrl': imageUrl,
    'author': author,
    'licence': licence,
    'fileUrl': fileUrl,
    'articleUrl': articleUrl,
  };

  Artwork applyTo(Artwork artwork) {
    final remoteImage = imageUrl;
    final remoteCredit = ArtworkCredit(
      author: _value(author, artwork.credit.author),
      licence: _value(licence, artwork.credit.licence),
      fileUrl: _value(fileUrl, artwork.credit.fileUrl),
      articleUrl: _value(articleUrl, artwork.credit.articleUrl),
      attribution: artwork.credit.attribution,
      fetchedAt: fetchedAt,
      isFallback:
          author == null &&
          licence == null &&
          fileUrl == null &&
          articleUrl == null,
    );
    return artwork.copyWith(
      titleAr: _value(titleAr, artwork.titleAr),
      dateText: _value(dateText, artwork.dateText),
      medium: _value(medium, artwork.medium),
      dimensions: _value(dimensions, artwork.dimensions),
      collection: _value(collection, artwork.collection),
      place: _value(place, artwork.place),
      image: artwork.image?.copyWith(remoteUrl: remoteImage),
      credit: remoteCredit,
    );
  }

  static String _value(String? candidate, String fallback) =>
      candidate == null || candidate.trim().isEmpty ? fallback : candidate;
}
