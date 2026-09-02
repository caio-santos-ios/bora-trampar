import 'package:flutter/material.dart';
import 'service_item_model.dart';

class CategoryModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ServiceItemModel> services;
  final bool isSpecial;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.services = const [],
    this.isSpecial = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['name'] ?? json['title'] ?? 'Serviço',
      subtitle: json['subtitle'] ?? json['description'] ?? 'Serviços especializados',
      icon: _mapIconFromJson(json['icon'] ?? json['name'] ?? ''),
      services: (json['services'] as List? ?? [])
          .map((s) => ServiceItemModel(
                id: s['id'] ?? s['_id'] ?? '',
                categoryId: json['id'] ?? json['_id'] ?? '',
                name: s['name'] ?? s['title'] ?? '',
                basePrice: (s['basePrice'] ?? s['price'] ?? 150.0).toDouble(),
              ))
          .toList(),
      isSpecial: json['isSpecial'] ?? false,
    );
  }

  static IconData _mapIconFromJson(String iconName) {
    final name = iconName.toLowerCase();
    if (name.contains('constru') || name.contains('obras') || name.contains('alvenaria')) {
      return Icons.construction_rounded;
    }
    if (name.contains('pint') || name.contains('acabamento')) {
      return Icons.format_paint_rounded;
    }
    if (name.contains('eletr') || name.contains('energia')) {
      return Icons.bolt_rounded;
    }
    if (name.contains('hidraul') || name.contains('encan') || name.contains('agua')) {
      return Icons.plumbing_rounded;
    }
    if (name.contains('limp') || name.contains('faxina') || name.contains('diaria')) {
      return Icons.cleaning_services_rounded;
    }
    if (name.contains('jardim') || name.contains('paisag')) {
      return Icons.yard_rounded;
    }
    return Icons.handyman_rounded;
  }
}
