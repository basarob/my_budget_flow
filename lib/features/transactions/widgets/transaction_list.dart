import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../../calendar/providers/calendar_provider.dart'; // Takvim senkronizasyonu
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';

/// Geçmiş İşlemler Listesi
///
/// Kullanıcının eklediği gelir ve gider işlemlerini kronolojik olarak listeler.
///
/// Özellikler:
/// - Infinite Scroll: Listeyi aşağı kaydırdıkça eski veriler (Pagination) yüklenir.
/// - Silme: Sağa veya sola kaydırarak işlem silinebilir. Silme işlemi için geri alma (Undo) sunulur.
/// - Düzenleme: Karta tıklandığında işlem düzenleme ekranı açılır.
/// - Kategori Eşleştirme: İşlem modelindeki kategori ismine göre ilgili ikon ve rengi bulur.
class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Pagination Provider'ı dinle
    final transactionListAsync = ref.watch(paginatedTransactionProvider);
    // Kategori Listesini dinle (İkon ve renkler için)
    final categoryListAsync = ref.watch(categoryListProvider);

    final currencyFormatter = NumberFormat.currency(
      symbol: '₺',
      decimalDigits: 2,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Listenin sonuna yaklaşıldığında (200px kala) yeni veri yükle
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: AppColors.passive.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTransactionsFound,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addTransactionHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            // +1: Listenin en altında biraz boşluk bırakmak için
            itemCount: transactions.length + 1,
            itemBuilder: (context, index) {
              if (index == transactions.length) {
                return const SizedBox(height: 50); // Spacer
              }

              final transaction = transactions[index];

              // Kategori Bulma Helper
              CategoryModel findCategory(String name) {
                return categoryListAsync.maybeWhen(
                  data: (cats) => cats.firstWhere(
                    (c) => c.name == name,
                    // Eğer kategori bulunamazsa (veya özel karakterse)
                    // mevcut isme göre geçici (dummy) bir model oluştur veya "Diğer" dön.
                    orElse: () => CategoryModel(
                      id: '',
                      name: name,
                      iconCode: Icons.category.codePoint,
                      colorValue: AppColors.passive.value,
                    ),
                  ),
                  orElse: () => CategoryModel(
                    id: '',
                    name: name,
                    iconCode: Icons.category.codePoint,
                    colorValue: AppColors.passive.value,
                  ),
                );
              }

              final category = findCategory(transaction.categoryName);
              final localizedCategoryName = category.getLocalizedName(context);

              final isExpense = transaction.type == TransactionType.expense;
              final amountColor = isExpense
                  ? AppColors.expenseRed
                  : AppColors.incomeGreen;

              return Dismissible(
                key: Key(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.expenseRed,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: AppColors.surface),
                ),
                onDismissed: (_) {
                  HapticFeedback.lightImpact();

                  // 2. Optimistic Update (Listeden anında sil)
                  ref
                      .read(paginatedTransactionProvider.notifier)
                      .removeItem(transaction.id);

                  // 3. Backend Silme İşlemi
                  ref
                      .read(transactionControllerProvider.notifier)
                      .deleteTransaction(transaction.id);

                  // 4. Takvimi Güncelle (Silme sonrası)
                  ref.invalidate(calendarProvider);

                  // 5. Geri Alma Seçenekli SnackBar
                  SnackbarUtils.showStandard(
                    context,
                    message: l10n.transactionDeleted,
                    undoLabel: l10n.undoAction,
                    onUndo: () {
                      ref
                          .read(transactionControllerProvider.notifier)
                          .addTransaction(transaction);
                      ref.invalidate(paginatedTransactionProvider);
                      // Geri alındığında takvimi tekrar güncelle
                      ref.invalidate(calendarProvider);
                    },
                  );

                  // 5. Kesin kapanma garantisi
                  Future.delayed(const Duration(seconds: 3), () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  });
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.passive.withOpacity(0.3)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      // Düzenleme Ekranına Git
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
                              color: AppColors.textSecondary,
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
                                color: AppColors.textSecondary.withOpacity(0.7),
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
        error: (err, stack) =>
            Center(child: Text(l10n.errorGeneric(err.toString()))),
      ),
    );
  }
}
