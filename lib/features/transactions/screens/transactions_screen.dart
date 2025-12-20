import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import '../widgets/recurring_transaction_list.dart';
import 'add_transaction_screen.dart';
import '../models/transaction_filter_state.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filterState = ref.watch(transactionFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          // AppBar'ın hemen altına TabBar'ı ekliyoruz
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.tabHistory), // "Geçmiş"
                Tab(text: l10n.tabRecurring), // "Düzenli"
              ],
            ),
          ),

          // Filtreler (Sadece Geçmiş sekmesindeyken gösterilebilir veya her zaman)
          // Tasarıma göre TabBar'ın altında
          _buildFilterBar(context, filterState),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TransactionList(), // Geçmiş Listesi
                RecurringTransactionList(), // Düzenli Listesi
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, TransactionFilterState state) {
    // Sadece geçmiş sekmesinde filtre göstermek mantıklı olabilir
    // ama şimdilik her iki sekmede de görünsün, belki düzenli işlemleri de filtreleriz.
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Arama
          IconButton(
            onPressed: () {
              // Arama modalını aç veya arama çubuğunu genişlet
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 8),

          // Tarih Çipleri
          _buildDateChip(context, '1 Gün', 1, state),
          const SizedBox(width: 8),
          _buildDateChip(context, '1 Hafta', 7, state),
          const SizedBox(width: 8),
          _buildDateChip(context, '1 Ay', 30, state),
          const SizedBox(width: 8),
          _buildDateChip(context, '3 Ay', 90, state),
          const SizedBox(width: 8),
          _buildDateChip(context, '6 Ay', 180, state),

          const SizedBox(width: 8),
          // Kategori Filtresi
          ActionChip(
            avatar: const Icon(Icons.category, size: 16),
            label: const Text('Kategori'),
            onPressed: () {
              // Kategori seçimi modalı
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(
    BuildContext context,
    String label,
    int days,
    TransactionFilterState state,
  ) {
    // Basit mantık: Eğer seçili tarih aralığı bu gün sayısına eşitse seçili göster
    // Gerçek uygulamada daha hassas bir kontrol gerekebilir (örn: DateTimeRange karşılaştırması)
    final isSelected = state.dateRange?.duration.inDays == days;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          final now = DateTime.now();
          final start = now.subtract(Duration(days: days));
          // Saatleri sıfırla ki tam gün olsun
          final range = DateTimeRange(
            start: DateTime(start.year, start.month, start.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );

          ref
              .read(transactionFilterProvider.notifier)
              .update(state.copyWith(dateRange: range));
        } else {
          // Filtreyi temizle
          ref.read(transactionFilterProvider.notifier).clear();
        }
      },
    );
  }
}
