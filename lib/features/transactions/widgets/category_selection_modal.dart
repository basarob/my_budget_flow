import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import 'add_category_modal.dart';

class CategorySelectionModal extends ConsumerWidget {
  final String? currentCategoryName;
  final ValueChanged<CategoryModel> onCategorySelected;

  const CategorySelectionModal({
    super.key,
    required this.currentCategoryName,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Tutamaç
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.passive.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),

              // Başlık ve Ekle Butonu
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.selectCategoryTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    // Modern "Yeni Ekle" butonu
                    Material(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          _showAddCategoryDialog(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Liste
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final categoryListAsync = ref.watch(categoryListProvider);
                    return categoryListAsync.when(
                      data: (allCategories) {
                        final defaultCategories = allCategories
                            .where((c) => !c.isCustom)
                            .toList();
                        final customCategories = allCategories
                            .where((c) => c.isCustom)
                            .toList();

                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          children: [
                            // Varsayılanlar
                            Text(
                              l10n.defaultCategoriesTitle.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.passive,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: defaultCategories.length,
                              itemBuilder: (context, index) {
                                return _buildCategoryItem(
                                  context,
                                  ref,
                                  defaultCategories[index],
                                );
                              },
                            ),

                            // Özel Kategoriler
                            if (customCategories.isNotEmpty) ...[
                              const SizedBox(height: 32),
                              Text(
                                l10n.userCategoriesTitle.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.passive,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.8,
                                    ),
                                itemCount: customCategories.length,
                                itemBuilder: (context, index) {
                                  return _buildCategoryItem(
                                    context,
                                    ref,
                                    customCategories[index],
                                  );
                                },
                              ),
                            ],
                            // Alt boşluk
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 20,
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) =>
                          Center(child: Text(l10n.errorGeneric(e))),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    WidgetRef ref,
    CategoryModel cat,
  ) {
    final isSelected = currentCategoryName == cat.name;
    final itemColor = Color(cat.colorValue);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onCategorySelected(cat);
      },
      onLongPress: cat.isCustom
          ? () => _showDeleteCategoryDialog(context, ref, cat)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? itemColor.withOpacity(0.15)
                  : AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? itemColor
                    : AppColors.passive.withOpacity(0.3),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: itemColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
              color: isSelected ? itemColor : AppColors.passive,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.getLocalizedName(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? itemColor : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteCategoryTitle),
          content: Text(l10n.deleteCategoryConfirmMessage(category.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(categoryControllerProvider.notifier)
                    .deleteCategory(category.id, category.name);
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
                // Seçili kategori silindiyse bir üst katman bunu yönetmeli
                // Ancak burada onCategorySelected ile 'Other' falan döndüremeyiz çünkü dialog içindeyiz.
                // Kategori silme işlemi provider listen eden parent tarafından fark edilir.
                // Parent, eğer seçili kategori silindiyse varsayılana dönmeli.
                // Bu logic AddTransactionScreen içinde kalabilir, veya buradaki callback
                // silme sonrası tetiklenebilir. Şimdilik basit tutalım.
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.expenseRed,
              ),
              child: Text(l10n.deleteButton),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddCategoryModal();
      },
    );
  }
}
