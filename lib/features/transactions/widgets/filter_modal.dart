import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/scale_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import 'modern_date_picker.dart';

/// İşlem Filtreleme Modalı
///
/// Kullanıcının işlem listesini belirli kriterlere göre daraltmasını sağlar.
///
/// Filtreleme Seçenekleri:
/// - İşlem Tipi: Gelir, Gider veya Hepsi
/// - Tarih Aralığı: Bugün, Bu Hafta, Bu Ay, Son 3 Ay veya Özel Aralık
/// - Kategoriler: Birden fazla kategori seçilebilir
///
/// Seçilen filtreler [TransactionFilterProvider] üzerinden yönetilir ve
/// uygulandığında liste otomatik olarak yenilenir.
class FilterModal extends ConsumerStatefulWidget {
  const FilterModal({super.key});

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
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
    HapticFeedback.lightImpact();
    setState(() {
      _selectedType = type;
    });
  }

  void _setDateRange(String preset) {
    HapticFeedback.lightImpact();

    // Toggle: Eğer zaten seçili olana tıklandıysa kaldır.
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
      // Pazartesi'yi bul
      start = start.subtract(Duration(days: now.weekday - 1));
      // Pazar'a kadar (Haftanın tamamı)
      end = start.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
    } else if (preset == 'month') {
      start = DateTime(now.year, now.month, 1);
      // Ayın son günü hesabı (Bir sonraki ayın ilk gününden 1 sn çıkar)
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      end = nextMonth.subtract(const Duration(milliseconds: 1));
    } else if (preset == '3months') {
      start = DateTime(now.year, now.month - 2, 1);
    }

    setState(() {
      _selectedDateRange = DateTimeRange(start: start, end: end);
    });
  }

  Future<void> _pickCustomRange() async {
    HapticFeedback.selectionClick();

    if (_isCustomSelected()) {
      setState(() {
        _selectedDateRange = null;
      });
      return;
    }

    // Modern Date Picker (Bottom Sheet)
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernDatePicker(
        initialStartDate: _selectedDateRange?.start,
        initialEndDate: _selectedDateRange?.end,
        onSaved: (start, end) {
          setState(() {
            _selectedDateRange = DateTimeRange(start: start, end: end);
          });
        },
      ),
    );
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(transactionFilterProvider.notifier);
    notifier.setFilterType(_selectedType);
    notifier.setFilterDateRange(_selectedDateRange);
    notifier.setFilterCategories(_selectedCategories);

    // Filtreler değişince listeyi yenile
    ref.invalidate(paginatedTransactionProvider);
    Navigator.pop(context);
  }

  void _clearFilters() {
    // "Hepsini temizle" butonu için hissiyat
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedType = null;
      _selectedDateRange = null;
      _selectedCategories = [];
    });
  }

  bool _isRangePreset(String preset) {
    if (_selectedDateRange == null) return false;

    final now = DateTime.now();
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;

    // Sadece gün başlangıcı/bitişi kontrolü için
    final todayStart = DateTime(now.year, now.month, now.day);

    if (preset == 'today') {
      return start.year == now.year &&
          start.month == now.month &&
          start.day == now.day &&
          end.difference(start).inDays == 0;
    } else if (preset == 'week') {
      final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

      final isSameStart =
          start.year == weekStart.year &&
          start.month == weekStart.month &&
          start.day == weekStart.day;

      final isNotTodayEnd =
          !(end.year == now.year &&
              end.month == now.month &&
              end.day == now.day);

      return isSameStart && isNotTodayEnd;
    } else if (preset == 'month') {
      return start.year == now.year &&
          start.month == now.month &&
          start.day == 1;
    } else if (preset == '3months') {
      // Basit bir kontrol, tam kesinlik zorunlu değil
      return start.year == now.year && start.month == now.month - 2;
    }
    return false;
  }

  bool _isCustomSelected() {
    if (_selectedDateRange == null) return false;
    // Eğer yukarıdakilerden hiçbiri değilse custom'dur
    return !_isRangePreset('today') &&
        !_isRangePreset('week') &&
        !_isRangePreset('month') &&
        !_isRangePreset('3months');
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryListAsync = ref.watch(categoryListProvider);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    // Modal Yüksekliği ekranın %75'i kadar olsun
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header (Başlık ve Kapat Butonu)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                // Konteyner Çizgisi (Drawer Handle)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.passive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.filterTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ScaleButton(
                      onTap: _clearFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.expenseRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_sweep,
                              size: 18,
                              color: AppColors.expenseRed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.clearAllFilters,
                              style: const TextStyle(
                                color: AppColors.expenseRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),

          // 2. İçerik (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // İşlem Tipi
                _buildSectionTitle(l10n.transactionTypeHeader),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.passive.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTypeSegment(theme, l10n.allTransactions, null),
                      _buildTypeSegment(
                        theme,
                        l10n.incomeType,
                        TransactionType.income,
                      ),
                      _buildTypeSegment(
                        theme,
                        l10n.expenseType,
                        TransactionType.expense,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Tarih
                _buildSectionTitle(l10n.dateHeader),
                if (_selectedDateRange != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${DateFormat('d MMM', Localizations.localeOf(context).toString()).format(_selectedDateRange!.start)} - ${DateFormat('d MMM yyyy', Localizations.localeOf(context).toString()).format(_selectedDateRange!.end)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildDateChip(theme, l10n.dateToday, 'today'),
                    _buildDateChip(theme, l10n.dateWeek, 'week'),
                    _buildDateChip(theme, l10n.dateMonth, 'month'),
                    _buildDateChip(theme, l10n.date3Months, '3months'),
                    _buildCustomDateChip(theme, l10n.dateCustom),
                  ],
                ),

                const SizedBox(height: 24),
                // Kategoriler
                _buildSectionTitle(l10n.categoriesHeader),
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

                const SizedBox(height: 80),
              ],
            ),
          ),

          // 3. Sabit Alt Buton (Sticky Bottom)
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: GradientButton(
              text: l10n.showResultsButton,
              onPressed: _applyFilters,
              icon: Icons.check_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTypeSegment(
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
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
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
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme, String label, String presetKey) {
    final isSelected = _isRangePreset(presetKey);
    return ScaleButton(
      onTap: () => _setDateRange(presetKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.surface,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.passive,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateChip(ThemeData theme, String label) {
    final isCustom = _isCustomSelected();
    return ScaleButton(
      onTap: _pickCustomRange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCustom ? null : AppColors.surface,
          gradient: isCustom
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                )
              : null,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isCustom ? Colors.transparent : AppColors.passive,
            width: 1.5,
          ),
          boxShadow: isCustom
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCustom ? FontWeight.w700 : FontWeight.w500,
            color: isCustom ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, CategoryModel category) {
    final isSelected = _selectedCategories.contains(category.name);
    final categoryColor = Color(category.colorValue);

    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? categoryColor : AppColors.passive,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          category.getLocalizedName(context),
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.surface : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
