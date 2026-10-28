class ArtReading {
  const ArtReading({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.publication,
    required this.author,
    required this.url,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String publication;
  final String author;
  final DateTime? publishedAt;
  final String url;

  factory ArtReading.fromJson(Map<String, dynamic> json) => ArtReading(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    publication: json['publication'] as String? ?? '',
    author: json['author'] as String? ?? '',
    publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
    url: json['url'] as String,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'publication': publication,
    'author': author,
    'publishedAt': publishedAt?.toUtc().toIso8601String(),
    'url': url,
  };
}
