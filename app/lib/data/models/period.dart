class Period {
  const Period({
    required this.id,
    required this.labelAr,
    required this.minYear,
    required this.maxYearExclusive,
  });

  final String id;
  final String labelAr;
  final int minYear;
  final int? maxYearExclusive;

  bool contains(int year) =>
      year >= minYear && (maxYearExclusive == null || year < maxYearExclusive!);

  factory Period.fromJson(Map<String, dynamic> json) => Period(
    id: json['id'] as String,
    labelAr: json['ar'] as String,
    minYear: (json['minYear'] as num).toInt(),
    maxYearExclusive: (json['maxYearExclusive'] as num?)?.toInt(),
  );
}
