import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For DatePicker
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_list.dart';
import '../widgets/recurring_transaction_list.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart'; // Import Added
import 'add_transaction_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFilterButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // User Feedback #2: Düzenli sekmesinde filtre butonu gizlensin
      setState(() {
        _isFilterButtonVisible = _tabController.index == 0;
      });
    });
    // User Feedback #2: Search TextField logic connection
    // Kullanıcı arama yapınca provider'ı güncelleyeceğiz.
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // User Feedback #1: "İşlemler" yazmasına gerek yok.
    // AppBar title'ı kaldırıp, TabBar'ı daha temiz hale getireceğiz.

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory, // Click efekti temiz olsun
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: l10n.tabHistory),
              Tab(text: l10n.tabRecurring),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor:
            theme.scaffoldBackgroundColor, // AppBar arkaplanı sayfa ile aynı
        elevation: 0,
      ),
      body: Column(
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
                  child: TextField(
                    onChanged: (value) {
                      ref
                          .read(transactionFilterProvider.notifier)
                          .setSearchQuery(value);
                      ref.invalidate(paginatedTransactionProvider);
                    },
                    decoration: InputDecoration(
                      hintText: l10n.searchHint, // Localized
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                if (_isFilterButtonVisible) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showFilterModal(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Found Transactions Count (Show only if active filters exist)
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(transactionFilterProvider);
              final transactionsAsync = ref.watch(paginatedTransactionProvider);

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
                        color: Colors.grey.shade600,
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
                      error: (_, __) => const Text("-"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.mediumImpact();
          // User Feedback #6: Her iki tab için de standart ekleme ekranı açılsın
          final startRefresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddTransactionScreen(), // Default isRecurring = false
            ),
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

  // User Feedback #3: Advanced Filter Modal
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran veya dinamik yükseklik için
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _FilterModalContent();
      },
    );
  }
}

class _FilterModalContent extends ConsumerStatefulWidget {
  const _FilterModalContent();

  @override
  ConsumerState<_FilterModalContent> createState() =>
      _FilterModalContentState();
}

class _FilterModalContentState extends ConsumerState<_FilterModalContent> {
  // _selectedType: null = Tümü (Gelir + Gider), income = Sadece Gelir, expense = Sadece Gider
  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(transactionFilterProvider);
    _selectedType = currentFilters.type;
    _selectedDateRange = currentFilters.dateRange;
    _selectedCategories = List.from(currentFilters.selectedCategories ?? []);
  }

  // --- MANTIK ---

  void _onTypeChanged(TransactionType? type) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedType = type;
    });
  }

  void _setDateRange(String preset) {
    HapticFeedback.selectionClick();

    // Toggle Logic: Eğer zaten seçili olana tıklandıysa kaldır.
    if (_isRangePreset(preset)) {
      setState(() {
        _selectedDateRange = null;
      });
      return;
    }

    final now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    if (preset == 'week') {
      start = start.subtract(Duration(days: now.weekday - 1));
    } else if (preset == 'month') {
      start = DateTime(now.year, now.month, 1);
    } else if (preset == '3months') {
      start = DateTime(now.year, now.month - 2, 1);
    }

    setState(() {
      _selectedDateRange = DateTimeRange(start: start, end: end);
    });
  }

  Future<void> _pickCustomRange() async {
    HapticFeedback.selectionClick();

    // Toggle check for custom
    if (_isCustomSelected()) {
      setState(() {
        _selectedDateRange = null;
      });
      return;
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: DateTime(
            picked.start.year,
            picked.start.month,
            picked.start.day,
          ),
          end: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
            999,
          ),
        );
      });
    }
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(transactionFilterProvider.notifier);
    notifier.setFilterType(_selectedType);
    notifier.setFilterDateRange(_selectedDateRange);
    notifier.setFilterCategories(_selectedCategories);
    // Filtreler değişince listeyi başa sar ve yeniden yükle
    ref.invalidate(paginatedTransactionProvider);
    Navigator.pop(context);
  }

  void _clearFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedType = null; // Tümü
      _selectedDateRange = null;
      _selectedCategories = [];
    });
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Hardcoded list removed
    final categoryListAsync = ref.watch(categoryListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Kompakt
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filterTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Material(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: _clearFilters,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.clearAllFilters,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                children: [
                  // 1. Transaction Type Section (PREMIUM SEGMENTED CONTROL)
                  _buildSectionHeader(l10n.transactionTypeHeader),
                  const SizedBox(height: 12),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentedTab(theme, l10n.allTransactions, null),
                        _buildSegmentedTab(
                          theme,
                          l10n.incomeType,
                          TransactionType.income,
                        ),
                        _buildSegmentedTab(
                          theme,
                          l10n.expenseType,
                          TransactionType.expense,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Date Range Section
                  _buildSectionHeader(l10n.dateHeader),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildDateChip(theme, l10n.dateToday, 'today'),
                      _buildDateChip(theme, l10n.dateWeek, 'week'),
                      _buildDateChip(theme, l10n.dateMonth, 'month'),
                      _buildDateChip(theme, l10n.date3Months, '3months'),
                      _buildCustomDateChip(theme, l10n.dateCustom),
                    ],
                  ),
                  if (_selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '${DateFormat('d MMM', 'tr_TR').format(_selectedDateRange!.start)} - ${DateFormat('d MMM yyyy', 'tr_TR').format(_selectedDateRange!.end)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 3. Categories Section
                  _buildSectionHeader(l10n.categoriesHeader),
                  const SizedBox(height: 12),
                  categoryListAsync.when(
                    data: (categoryList) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryList
                            .map((cat) => _buildCategoryChip(theme, cat))
                            .toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text(l10n.errorCategoriesLoad),
                  ),
                ],
              ),
            ),

            // Filter Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.showResultsButton,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildSegmentedTab(
    ThemeData theme,
    String label,
    TransactionType? value,
  ) {
    final isSelected = _selectedType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTypeChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.scaffoldBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onSurface
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme, String label, String presetKey) {
    final isSelected = _isRangePreset(presetKey);
    return GestureDetector(
      onTap: () => _setDateRange(presetKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateChip(ThemeData theme, String label) {
    final isCustom = _isCustomSelected();
    return GestureDetector(
      onTap: _pickCustomRange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isCustom
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCustom ? theme.colorScheme.primary : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCustom ? FontWeight.w700 : FontWeight.w500,
            color: isCustom
                ? theme.colorScheme.primary
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, CategoryModel category) {
    final isSelected = _selectedCategories.contains(category.name);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(category.name);
          } else {
            _selectedCategories.add(category.name);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Text(
          category.getLocalizedName(context),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  bool _isRangePreset(String preset) {
    if (_selectedDateRange == null) return false;
    final now = DateTime.now();
    final start = _selectedDateRange!.start;
    final isSameDay = (DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    if (preset == 'today') return isSameDay(start, now);
    if (preset == 'week') {
      final weekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      return isSameDay(start, weekStart);
    }
    if (preset == 'month')
      return start.day == 1 &&
          start.month == now.month &&
          start.year == now.year;
    if (preset == '3months')
      return isSameDay(start, DateTime(now.year, now.month - 2, 1));
    return false;
  }

  bool _isCustomSelected() {
    return _selectedDateRange != null &&
        !_isRangePreset('today') &&
        !_isRangePreset('week') &&
        !_isRangePreset('month') &&
        !_isRangePreset('3months');
  }
}
