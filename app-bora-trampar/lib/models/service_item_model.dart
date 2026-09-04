class ServiceItemModel {
  final String id;
  final String categoryId;
  final String name;
  final double basePrice;

  const ServiceItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.basePrice = 150.0,
  });
}
