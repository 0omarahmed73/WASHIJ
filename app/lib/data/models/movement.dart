class Movement {
  const Movement({
    required this.id,
    required this.nameAr,
    required this.nameOrig,
    required this.period,
    required this.place,
    required this.line,
    required this.intro,
    required this.traits,
  });

  final String id;
  final String nameAr;
  final String nameOrig;
  final String period;
  final String place;
  final String line;
  final String intro;
  final List<String> traits;

  factory Movement.fromJson(String id, Map<String, dynamic> json) => Movement(
    id: id,
    nameAr: json['ar'] as String,
    nameOrig: json['orig'] as String,
    period: json['period'] as String? ?? '',
    place: json['where'] as String? ?? '',
    line: json['line'] as String? ?? '',
    intro: json['intro'] as String? ?? '',
    traits: ((json['traits'] as List<dynamic>?) ?? const []).cast<String>(),
  );
}
