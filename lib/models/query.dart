class Query {
  final int minPrice;
  final int maxPrice;
  final double minDistance;
  final double maxDistance;
  final String requirement; // 我想吃
  final String note; // 備註

  const Query(
      {required this.minPrice,
      required this.maxPrice,
      required this.minDistance,
      required this.maxDistance,
      required this.requirement,
      required this.note});
}
