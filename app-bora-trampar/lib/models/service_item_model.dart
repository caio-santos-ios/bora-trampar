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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceItemModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
