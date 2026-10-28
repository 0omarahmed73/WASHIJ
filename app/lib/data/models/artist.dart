class Artist {
  const Artist({
    required this.id,
    required this.nameAr,
    required this.nameOrig,
    required this.born,
    required this.died,
    required this.place,
    required this.leadArtworkId,
    required this.movementIds,
    required this.bio,
    required this.style,
  });

  final String id;
  final String nameAr;
  final String nameOrig;
  final String born;
  final String died;
  final String place;
  final String leadArtworkId;
  final List<String> movementIds;
  final String bio;
  final String style;

  factory Artist.fromJson(String id, Map<String, dynamic> json) => Artist(
    id: id,
    nameAr: json['ar'] as String,
    nameOrig: json['orig'] as String,
    born: json['born'] as String? ?? '',
    died: json['died'] as String? ?? '',
    place: json['place'] as String? ?? '',
    leadArtworkId: json['lead'] as String? ?? '',
    movementIds: ((json['movements'] as List<dynamic>?) ?? const [])
        .cast<String>(),
    bio: json['bio'] as String? ?? '',
    style: json['style'] as String? ?? '',
  );
}
