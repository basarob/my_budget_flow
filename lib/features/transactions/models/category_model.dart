import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int iconCode; // IconData.codePoint (Material Icons)
  final int colorValue; // Color(0xFF...).value
  final bool isCustom; // Kullanıcı mı ekledi?

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isCustom = false,
  });

  // Varsayılan Kategoriler Listesi
  static List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'cat_food',
      name: 'Gıda',
      iconCode: Icons.shopping_cart.codePoint,
      colorValue: Colors.orange.value,
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'Ulaşım',
      iconCode: Icons.directions_bus.codePoint,
      colorValue: Colors.blue.value,
    ),
    CategoryModel(
      id: 'cat_home',
      name: 'Ev/Kira',
      iconCode: Icons.home.codePoint,
      colorValue: Colors.indigo.value,
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'Faturalar',
      iconCode: Icons.receipt.codePoint,
      colorValue: Colors.redAccent.value,
    ),
    CategoryModel(
      id: 'cat_health',
      name: 'Sağlık',
      iconCode: Icons.local_hospital.codePoint,
      colorValue: Colors.teal.value,
    ),
    CategoryModel(
      id: 'cat_entertainment',
      name: 'Eğlence',
      iconCode: Icons.movie.codePoint,
      colorValue: Colors.purple.value,
    ),
    CategoryModel(
      id: 'cat_salary',
      name: 'Maaş',
      iconCode: Icons.attach_money.codePoint,
      colorValue: Colors.green.value,
    ),
    CategoryModel(
      id: 'cat_other',
      name: 'Diğer',
      iconCode: Icons.category.codePoint,
      colorValue: Colors.grey.value,
    ),
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isCustom': isCustom,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconCode: map['iconCode'] ?? Icons.category.codePoint,
      colorValue: map['colorValue'] ?? Colors.grey.value,
      isCustom: map['isCustom'] ?? false,
    );
  }
}
