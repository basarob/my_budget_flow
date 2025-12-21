import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart'; // Import CategoryModel
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart'; // Import CategoryProvider
import '../screens/add_transaction_screen.dart';
import '../../../l10n/app_localizations.dart';

class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  // Eski Helper fonksiyonları kaldırıldı (_getIconForCategory, _getCategoryColor)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // 1. Pagination Provider'ı dinle
    final transactionListAsync = ref.watch(paginatedTransactionProvider);
    // 2. Kategori Listesini dinle (Dinamik ikonlar için)
    final categoryListAsync = ref.watch(categoryListProvider);

    final currencyFormatter = NumberFormat.currency(
      symbol: '₺',
      decimalDigits: 2,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Scroll en aşağıya yaklaştıysa (200px kala) yeni veri yükle
        if (!scrollInfo.metrics.outOfRange &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(paginatedTransactionProvider.notifier).loadMore();
        }
        return false;
      },
      child: transactionListAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            // Filtre durumu?
            // Eğer filtre varsa "sonuç bulunamadı" denebilir.
            // Şimdilik genel boş durumu:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTransactionsFound,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addTransactionHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            // +1 for loading indicator at bottom if needed
            itemCount: transactions.length + 1,
            itemBuilder: (context, index) {
              // Loading Indicator at the bottom
              if (index == transactions.length) {
                // Sadece veri varsa ve yükleniyorsa göster diyeceğim ama
                // Provider "loading" durumuna sadece ilk açılışta geçiyor (AsyncValue.loading).
                // "loadMore" sırasında state .data olarak kalıyor, biz ekleme yapıyoruz.
                // İstenirse buraya küçük bir loader konabilir.
                return const SizedBox(height: 50); // Spacer
              }

              final transaction = transactions[index];

              // Helper to find category
              CategoryModel findCategory(String name) {
                // Legacy support for Turkish names
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

                // Legacy for English (if any)
                if (name == 'Food') searchName = 'categoryFood';
                // ... add others if needed, mostly Turkish was used.

                return categoryListAsync.maybeWhen(
                  data: (cats) => cats.firstWhere(
                    (c) => c.name == searchName,
                    orElse: () => CategoryModel(
                      id: '',
                      name: name, // Custom or unknown: use original name
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

              final category = findCategory(transaction.categoryName);
              final localizedCategoryName = category.getLocalizedName(context);
              final isExpense = transaction.type == TransactionType.expense;
              final amountColor = isExpense
                  ? Colors.red
                  : Colors
                        .green; // Transaction amount color (remains standard red/green or can be themed)

              return Dismissible(
                key: Key(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  HapticFeedback.lightImpact(); // Haptic Feedback

                  // 1. SnackBar'ı temizle (önceki varsa)
                  ScaffoldMessenger.of(context).clearSnackBars();

                  // 2. Optimistic Update (Listeden anında sil)
                  ref
                      .read(paginatedTransactionProvider.notifier)
                      .removeItem(transaction.id);

                  // 3. Backend Silme İşlemi (Arka planda)
                  ref
                      .read(transactionControllerProvider.notifier)
                      .deleteTransaction(transaction.id);

                  // 4. SnackBar Göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.transactionDeleted),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        20,
                      ), // Alttan boşluk azaltıldı
                      action: SnackBarAction(
                        label: l10n.undoAction,
                        onPressed: () {
                          ref
                              .read(transactionControllerProvider.notifier)
                              .addTransaction(transaction);
                          // Geri alma durumunda listeyi tekrar çekmek mantıklı
                          ref.invalidate(paginatedTransactionProvider);
                        },
                      ),
                    ),
                  );

                  // 5. Zorla Kapatma (Timer) - Windows hover sorununu aşmak için
                  Future.delayed(const Duration(seconds: 3), () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                    }
                  });
                },
                child: Card(
                  // User Feedback #4: Daha kompakt boşluk
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      // Düzenleme Modu
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionScreen(
                            transactionToEdit: transaction,
                          ),
                        ),
                      );

                      if (refresh == true) {
                        ref.invalidate(paginatedTransactionProvider);
                      }
                    },
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(category.colorValue).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconData(
                            category.iconCode,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Color(category.colorValue),
                        ),
                      ),
                      title: Text(
                        transaction.title.isNotEmpty
                            ? transaction.title
                            : localizedCategoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              Localizations.localeOf(context).toString(),
                            ).format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (transaction.description != null &&
                              transaction.description!.isNotEmpty)
                            Text(
                              transaction.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 110),
                        child: Text(
                          '${isExpense ? '-' : '+'}${currencyFormatter.format(transaction.amount)}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: amountColor,
                          ),
                        ),
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
      ),
    );
  }
}
