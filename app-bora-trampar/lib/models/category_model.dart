import 'package:flutter/material.dart';
import '../core/utils/font_awesome_helper.dart';
import 'service_item_model.dart';

class CategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final IconData icon;
  final List<ServiceItemModel> services;
  final bool isSpecial;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconName = '',
    this.services = const [],
    this.isSpecial = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawIcon = (json['icon'] ?? '').toString();
    final name = (json['name'] ?? json['title'] ?? '').toString();

    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: name,
      subtitle: (json['subtitle'] ?? json['description'] ?? '').toString(),
      iconName: rawIcon,
      icon: FontAwesomeHelper.getIcon(rawIcon, fallbackText: name),
      services: (json['services'] as List? ?? [])
          .map((s) => ServiceItemModel(
                id: s['id'] ?? s['_id'] ?? '',
                categoryId: json['id'] ?? json['_id'] ?? '',
                name: s['name'] ?? s['title'] ?? '',
                basePrice: (s['basePrice'] ?? s['price'] ?? 0.0).toDouble(),
              ))
          .toList(),
      isSpecial: json['isSpecial'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
