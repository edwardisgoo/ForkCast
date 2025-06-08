class Query {
  final int minPrice;
  final int maxPrice;
  final double minDistance;
  final double maxDistance;
  final String requirement;
  final String note;

  Query({
    required this.minPrice,
    required this.maxPrice,
    required this.minDistance,
    required this.maxDistance,
    required this.requirement,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'min_price': minPrice,
        'max_price': maxPrice,
        'min_distance': minDistance,
        'max_distance': maxDistance,
        'requirement': requirement,
        'note': note,
      };

  Query copyWith({
    int? minPrice,
    int? maxPrice,
    double? minDistance,
    double? maxDistance,
    String? requirement,
    String? note,
  }) {
    return Query(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      requirement: requirement ?? this.requirement,
      note: note ?? this.note,
    );
  }
}
