class Query {
  int minPrice;
  int maxPrice;
  double minDistance;
  double maxDistance;
  String requirement;//我想吃
  String note;//備註
  Query({
    required this.minPrice,
    required this.maxPrice,
    required this.minDistance,
    required this.maxDistance,
    required this.requirement,
    required this.note
  });
}