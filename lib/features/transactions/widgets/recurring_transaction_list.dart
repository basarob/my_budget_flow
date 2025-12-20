import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class RecurringTransactionList extends ConsumerWidget {
  const RecurringTransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringListAsync = ref.watch(recurringListProvider);
    final currencyFormatter = NumberFormat.currency(
      symbol: '₺',
      decimalDigits: 2,
    );

    return recurringListAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              'Düzenli işlem bulunamadı.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isExpense = item.type == 'expense';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  child: Icon(
                    Icons.repeat,
                    color: isExpense ? Colors.red : Colors.green,
                  ),
                ),
                title: Text(
                  item.categoryName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Her ${item.frequency}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyFormatter.format(item.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Silme onayı isteyip sil
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Sil?'),
                            content: const Text(
                              'Bu düzenli işlemi silmek istediğine emin misin?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('İptal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ref
                                      .read(
                                        transactionControllerProvider.notifier,
                                      )
                                      .deleteRecurringItem(item.id);
                                },
                                child: const Text(
                                  'Sil',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
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
