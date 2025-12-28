import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/category_model.dart';
import 'selection_card.dart';

/// Dosya: category_selector_card.dart
///
/// Amaç: İşlem ekleme ekranında kategori seçimini başlatan kart bileşeni.
///
/// Özellikler:
/// - Seçili kategoriyi (ikon ve isim) gösterir
/// - Seçim yapılmamışsa placeholder gösterir
/// - SelectionCard bileşenini kullanır
class CategorySelectorCard extends StatelessWidget {
  final CategoryModel selectedCategory;
  final bool isSelected;
  final VoidCallback onTap;

  const CategorySelectorCard({
    super.key,
    required this.selectedCategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoryName = selectedCategory.getLocalizedName(context);

    return SelectionCard(
      title: l10n.categoryLabel,
      selectedValue: isSelected ? categoryName : null,
      icon: IconData(selectedCategory.iconCode, fontFamily: 'MaterialIcons'),
      iconColor: isSelected
          ? Color(selectedCategory.colorValue)
          : AppColors.passive,
      onTap: onTap,
      placeholder: l10n.selectCategoryHint,
    );
  }
}
