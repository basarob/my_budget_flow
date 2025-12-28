import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../widgets/filter_modal.dart';
import '../widgets/recurring_transaction_list.dart';
import '../widgets/transaction_list.dart';
import 'add_transaction_screen.dart';

/// İşlemler Listeleme ve Yönetim Ekranı
///
/// Uygulamanın ana ekranlarından biridir. Kullanıcının tüm finansal hareketlerini
/// görüntüleyebileceği ve yönetebileceği merkezi bir arayüz sunar.
///
/// Ana Bölümler:
/// 1. Sekmeler (Tabs):
///    - **Geçmiş**: Gerçekleşen gelir/gider işlemleri.
///    - **Düzenli**: Otomatik tekrarlanan talimatlar.
/// 2. Arama ve Filtreleme:
///    - Üst kısımdaki arama çubuğu ile işlemler içinde metin bazlı arama yapılabilir.
///    - Filtre butonu ile tarih, kategori ve tip bazlı detaylı filtreleme modali açılır.
/// 3. Yeni Ekleme (FAB):
///    - Sağ alt köşedeki buton ile yeni işlem ekleme ekranına yönlendirir.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FocusNode _searchFocusNode;
  bool _isFilterButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Sekme değişirken klavyeyi kapat
        _searchFocusNode.unfocus();
      }
      // Düzenli işlemler sekmesinde filtre butonunu gizle
      setState(() {
        _isFilterButtonVisible = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200], // iOS Segmented Control arka planı
            borderRadius: BorderRadius.circular(
              12,
            ), // Köşeleri biraz daha keskin ama yuvarlak
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary, // Tema ana rengi
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white, // Seçili metin rengi
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelColor:
                Colors.grey[600], // Seçili olmayan metin rengi
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: l10n.tabHistory),
              Tab(text: l10n.tabRecurring),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // Boşluğa tıklanınca klavyeyi kapat
          _searchFocusNode.unfocus();
        },
        child: Column(
          children: [
            // Arama ve Filtre Alanı
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        focusNode: _searchFocusNode,
                        onChanged: (value) {
                          ref
                              .read(transactionFilterProvider.notifier)
                              .setSearchQuery(value);
                          ref.invalidate(paginatedTransactionProvider);
                        },
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isFilterButtonVisible) ...[
                    const SizedBox(width: 12),
                    // "Temizle" butonu için görsel geri bildirim eklendi (InkWell)
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _showFilterModal(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Colors.transparent, // Filtre butonu da sadeleşti
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Icon(Icons.filter_list, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bulunan İşlem Sayısı (Aktif filtre varsa gösterilir)
            Consumer(
              builder: (context, ref, child) {
                final filter = ref.watch(transactionFilterProvider);
                final transactionsAsync = ref.watch(
                  paginatedTransactionProvider,
                );

                final hasActiveFilter =
                    filter.type != null ||
                    filter.dateRange != null ||
                    (filter.selectedCategories != null &&
                        filter.selectedCategories!.isNotEmpty) ||
                    (filter.searchQuery != null &&
                        filter.searchQuery!.isNotEmpty);

                if (!hasActiveFilter) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 8,
                    top: 0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.foundTransactionsPrefix,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      transactionsAsync.when(
                        data: (list) => Text(
                          "${list.length}",
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, _) => const Text("-"),
                      ),
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [TransactionList(), RecurringTransactionList()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          // Ekran değişimi öncesi klavyeyi kapat
          _searchFocusNode.unfocus();

          // Her iki tab için de standart ekleme ekranı açılır
          final startRefresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );

          if (startRefresh == true) {
            ref.invalidate(paginatedTransactionProvider);
            ref.invalidate(recurringListProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Gelişmiş Filtreleme Modalı
  void _showFilterModal(BuildContext context) {
    // Modal açılmadan önce klavyeyi kapat
    _searchFocusNode.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Arkaplanı şeffaf yap
      builder: (context) {
        return const FilterModal();
      },
    );
  }
}
