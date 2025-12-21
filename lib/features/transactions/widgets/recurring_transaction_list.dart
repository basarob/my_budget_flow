import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction_model.dart';
import '../models/transaction_model.dart'; // For TransactionType
import '../models/category_model.dart'; // Import CategoryModel
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart'; // Import CategoryProvider
import '../../../l10n/app_localizations.dart';

class RecurringTransactionList extends ConsumerWidget {
  const RecurringTransactionList({super.key});

  String _getLocalizedFrequency(BuildContext context, String frequency) {
    final l10n = AppLocalizations.of(context)!;
    switch (frequency) {
      case 'daily':
      case 'Günlük':
      case 'Daily':
        return l10n.frequencyDaily;
      case 'weekly':
      case 'Haftalık':
      case 'Weekly':
        return l10n.frequencyWeekly;
      case 'monthly':
      case 'Aylık':
      case 'Monthly':
        return l10n.frequencyMonthly;
      case 'yearly':
      case 'Yıllık':
      case 'Yearly':
        return l10n.frequencyYearly;
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recurringListAsync = ref.watch(recurringListProvider);
    final categoryListAsync = ref.watch(categoryListProvider);
    final currencyFormatter = NumberFormat.currency(
      symbol: '₺',
      decimalDigits: 2,
    );

    return recurringListAsync.when(
      data: (allItems) {
        // User Feedback #2: Düzenli İşlemler Ekranında Arama (Search Query)
        final searchQuery =
            ref.watch(transactionFilterProvider).searchQuery ?? '';
        final items = allItems.where((item) {
          if (searchQuery.isEmpty) return true;
          return item.categoryName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              item.title.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_repeat, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  l10n.noRecurringFound,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addRecurringHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isActive = item.isActive;
            final isExpense = item.type == TransactionType.expense;
            final color = isExpense ? Colors.red : Colors.green;

            // Helper to find category
            CategoryModel findCategory(String name) {
              // Legacy support for Turkish names (Same logic as TransactionList)
              String searchName = name;
              if (name == 'Gıda') searchName = 'categoryFood';
              if (name == 'Fatura') searchName = 'categoryBills';
              if (name == 'Ulaşım') searchName = 'categoryTransport';
              if (name == 'Kira/Aidat') searchName = 'categoryRent';
              if (name == 'Eğlence') searchName = 'categoryEntertainment';
              if (name == 'Alışveriş') searchName = 'categoryShopping';
              if (name == 'Maaş') searchName = 'categorySalary';
              if (name == 'Yatırım') searchName = 'categoryInvestment';
              if (name == 'Diğer') searchName = 'categoryOther';

              return categoryListAsync.maybeWhen(
                data: (cats) => cats.firstWhere(
                  (c) => c.name == searchName,
                  orElse: () => CategoryModel(
                    id: '',
                    name: name,
                    iconCode: Icons.category.codePoint,
                    colorValue: Colors.grey.value,
                  ),
                ),
                orElse: () => CategoryModel(
                  id: '',
                  name: name,
                  iconCode: Icons.category.codePoint,
                  colorValue: Colors.grey.value,
                ),
              );
            }

            final category = findCategory(item.categoryName);
            final localizedCategoryName = category.getLocalizedName(context);
            final localizedFrequency = _getLocalizedFrequency(
              context,
              item.frequency,
            );

            return Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                HapticFeedback.lightImpact();
                ref
                    .read(transactionControllerProvider.notifier)
                    .deleteRecurringItem(item.id);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.recurringDeleted),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    action: SnackBarAction(
                      label: l10n.undoAction,
                      onPressed: () {
                        ref
                            .read(transactionControllerProvider.notifier)
                            .addRecurringItem(item);
                      },
                    ),
                  ),
                );

                // Zorla Kapatma (Timer)
                Future.delayed(const Duration(seconds: 3), () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  }
                });
              },
              child: Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(category.colorValue).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      // User Feedback #6: Oklar yerine kategori simgesi
                      child: Icon(
                        IconData(
                          category.iconCode,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(category.colorValue),
                      ),
                    ),
                    title: Text(
                      item.title.isNotEmpty
                          ? item.title
                          : localizedCategoryName, // Localized name
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$localizedFrequency - ${DateFormat('dd MMMM', Localizations.localeOf(context).toString()).format(item.startDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (item.description.isNotEmpty)
                          Text(
                            item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            currencyFormatter.format(item.amount),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color,
                              decoration: isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: isActive,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();

                            final updatedItem = RecurringTransactionModel(
                              id: item.id,
                              title: item.title,
                              userId: item.userId,
                              amount: item.amount,
                              type: item.type,
                              categoryName: item.categoryName,
                              frequency: item.frequency,
                              startDate: item.startDate,
                              description: item.description,
                              isActive: val,
                              lastProcessedDate: item.lastProcessedDate,
                            );

                            ref
                                .read(transactionControllerProvider.notifier)
                                .updateRecurringItem(updatedItem);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Hata: $err')),
    );
  }
}
