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
    required this.services,
    this.isSpecial = false,
  });
}
