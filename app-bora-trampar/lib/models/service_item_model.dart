import 'package:flutter/material.dart';
import '../core/utils/font_awesome_helper.dart';

class ServiceItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String icon;
  final IconData? iconData;
  final double basePrice;

  const ServiceItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.icon = '',
    this.iconData,
    this.basePrice = 150.0,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    final rawIcon = (json['icon'] ?? '').toString();
    final name = (json['name'] ?? json['title'] ?? 'Serviço').toString();

    return ServiceItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      categoryId: (json['categoryId'] ?? json['category_id'] ?? '').toString(),
      name: name,
      icon: rawIcon,
      iconData: FontAwesomeHelper.getIcon(rawIcon, fallbackText: name),
      basePrice: (json['basePrice'] ?? json['price'] ?? 150.0).toDouble(),
    );
  }

  IconData get effectiveIcon => iconData ?? FontAwesomeHelper.getIcon(icon, fallbackText: name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceItemModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
