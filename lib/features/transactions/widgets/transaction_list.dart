import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
// import '../../categories/repositories/category_repository.dart'; // Silindi

class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Şimdilik listeyi provider'dan alıyoruz
    // İleride pagination yapısı buraya entegre edilebilir
    final transactionsAsync = ref.watch(filteredTransactionListProvider);
    final currencyFormatter = NumberFormat.currency(
      symbol: '₺',
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat.yMMMd('tr_TR');

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet, // Cüzdan sembolü
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz harcama yok, harikasın! 🎉',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk işlemini ekleyerek başla.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // FAB için boşluk
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final isExpense = transaction.type == 'expense';

            return Dismissible(
              key: Key(transaction.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                // Silme işlemi
                ref
                    .read(transactionControllerProvider.notifier)
                    .deleteTransaction(transaction.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('İşlem silindi.'),
                    action: SnackBarAction(
                      label: 'GERİ AL',
                      onPressed: () {
                        // Geri ekleme (Undo)
                        ref
                            .read(transactionControllerProvider.notifier)
                            .addTransaction(transaction);
                      },
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  child: Icon(
                    // Kategori ikonu (basitleştirilmiş)
                    _getCategoryIcon(transaction.categoryName),
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(
                  transaction.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (transaction.description?.isNotEmpty ?? false)
                      ? '${dateFormatter.format(transaction.date)} - ${transaction.description}'
                      : dateFormatter.format(transaction.date),
                ),
                trailing: Text(
                  '${isExpense ? '-' : '+'} ${currencyFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    color: isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

  IconData _getCategoryIcon(String categoryName) {
    // Burada CategoryRepository'den ikon eşleştirmesi yapılabilir
    // Şimdilik categoryName'e göre basit bir switch veya varsayılan ikon
    // İleride CategoryRepository'den map çekilebilir.
    switch (categoryName.toLowerCase()) {
      case 'market':
        return Icons.shopping_cart;
      case 'fatura':
        return Icons.receipt;
      case 'kira':
        return Icons.home;
      case 'maaş':
        return Icons.work;
      case 'yol':
        return Icons.directions_bus;
      case 'yemek':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }
}
