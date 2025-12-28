import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Dosya: category_model.dart
///
/// Amaç: Kategori veri modelini tanımlar.
///
/// Özellikler:
/// - Kategori verilerini (id, isim, ikon, renk) tutar
/// - Varsayılan sistem kategorilerini listeler
/// - Yerelleştirilmiş kategori isimlerini döndürür
/// - JSON serileştirme (toMap/fromMap) işlemlerini yapar
class CategoryModel {
  final String id;
  final String name; // Yerelleştirme anahtarı veya özel kategori adı
  final int iconCode; // IconData.codePoint
  final int colorValue; // Color.value
  final bool isCustom; // true ise kullanıcı tarafından eklenmiştir

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isCustom = false,
  });

  /// Varsayılan sistem kategorilerini döndürür.
  /// Renkler [AppTheme] içerisinden alınır.
  static List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'cat_food',
      name: 'categoryFood',
      iconCode: Icons.restaurant.codePoint,
      colorValue: AppColors.categoryColors[0].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_bills',
      name: 'categoryBills',
      iconCode: Icons.receipt_long.codePoint,
      colorValue: AppColors.categoryColors[1].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_transport',
      name: 'categoryTransport',
      iconCode: Icons.directions_bus.codePoint,
      colorValue: AppColors.categoryColors[2].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_rent',
      name: 'categoryRent',
      iconCode: Icons.home.codePoint,
      colorValue: AppColors.categoryColors[3].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_entertainment',
      name: 'categoryEntertainment',
      iconCode: Icons.movie.codePoint,
      colorValue: AppColors.categoryColors[4].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_shopping',
      name: 'categoryShopping',
      iconCode: Icons.shopping_bag.codePoint,
      colorValue: AppColors.categoryColors[5].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_salary',
      name: 'categorySalary',
      iconCode: Icons.payments.codePoint,
      colorValue: AppColors.categoryColors[9].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_investment',
      name: 'categoryInvestment',
      iconCode: Icons.trending_up.codePoint,
      colorValue: AppColors.categoryColors[11].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_health',
      name: 'categoryHealth',
      iconCode: Icons.medical_services_outlined.codePoint,
      colorValue: AppColors.categoryColors[6].toARGB32(),
    ),
    CategoryModel(
      id: 'cat_other',
      name: 'categoryOther',
      iconCode: Icons.more_horiz.codePoint,
      colorValue: AppColors.categoryColors[8].toARGB32(),
    ),
  ];

  /// Kategori adını yerelleştirilmiş (Türkçe/İngilizce) olarak döndürür.
  String getLocalizedName(BuildContext context) {
    if (isCustom) return name;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return name;

    switch (name) {
      case 'categoryFood':
        return l10n.categoryFood;
      case 'categoryBills':
        return l10n.categoryBills;
      case 'categoryTransport':
        return l10n.categoryTransport;
      case 'categoryRent':
        return l10n.categoryRent;
      case 'categoryEntertainment':
        return l10n.categoryEntertainment;
      case 'categoryShopping':
        return l10n.categoryShopping;
      case 'categorySalary':
        return l10n.categorySalary;
      case 'categoryInvestment':
        return l10n.categoryInvestment;
      case 'categoryHealth':
        return l10n.categoryHealth;
      case 'categoryOther':
        return l10n.categoryOther;
      default:
        return name;
    }
  }

  /// Firestore veya yerel depolama için Map dönüşümü
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isCustom': isCustom,
    };
  }

  /// Map verisinden nesne oluşturma
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconCode: map['iconCode'] ?? Icons.category.codePoint,
      colorValue: map['colorValue'] ?? const Color(0xFF9E9E9E).toARGB32(),
      isCustom: map['isCustom'] ?? false,
    );
  }
}
