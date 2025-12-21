import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../../l10n/app_localizations.dart';

/// Yeni İşlem Ekleme veya Mevcut İşlemi Düzenleme Ekranı
class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;
  final bool initialIsRecurring;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.initialIsRecurring = false,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  // Form Durumu
  late bool _isExpense;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String? _categoryName;
  late DateTime _selectedDate;
  String _description = '';

  // Düzenli İşlem Durumu
  late bool _isRecurring;
  String _recurringFrequency = 'monthly';

  final _formKey = GlobalKey<FormState>();

  // Animasyon
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    // Animasyon Kurulumu (Tarih düzeltme uyarısı için)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation =
        Tween<double>(
            begin: 0,
            end: 10,
          ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _shakeController.reverse();
            }
          });

    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _isExpense = t.type == TransactionType.expense;
      _amountController.text = t.amount.toString();
      _titleController.text = t.title;
      _categoryName = t.categoryName;
      _selectedDate = t.date;
      _description = t.description ?? '';
      _isRecurring = false;
    } else {
      _isExpense = true;
      _selectedDate = DateTime.now();
      _isRecurring = widget.initialIsRecurring;
      _categoryName = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// İşlemi Kaydet (Ekle veya Güncelle)
  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // Kategori adı null ise varsayılan 'categoryOther' anahtarını kullan
    final categoryToSave = _categoryName ?? 'categoryOther';

    HapticFeedback.mediumImpact();

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final amount = double.parse(_amountController.text);
    final title = _titleController.text.trim();
    final description = _description.trim();

    try {
      if (_isRecurring) {
        // Düzenli İşlem Ekle
        final recurringItem = RecurringTransactionModel(
          id: '',
          title: title,
          userId: user.uid,
          amount: amount,
          type: _isExpense ? TransactionType.expense : TransactionType.income,
          categoryName: categoryToSave,
          frequency: _recurringFrequency,
          startDate: _selectedDate,
          description: description,
        );

        await ref
            .read(transactionControllerProvider.notifier)
            .addRecurringItem(recurringItem);
      } else {
        // Tek Seferlik İşlem Ekle/Guncelle
        final transaction = TransactionModel(
          id: widget.transactionToEdit?.id ?? '',
          userId: user.uid,
          title: title,
          amount: amount,
          type: _isExpense ? TransactionType.expense : TransactionType.income,
          categoryName: categoryToSave,
          date: _selectedDate,
          description: description,
        );

        if (widget.transactionToEdit != null &&
            widget.transactionToEdit!.id.isNotEmpty) {
          // Güncelleme: Önce sil, sonra ekle
          await ref
              .read(transactionControllerProvider.notifier)
              .deleteTransaction(widget.transactionToEdit!.id);
        }

        await ref
            .read(transactionControllerProvider.notifier)
            .addTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true); // Yenileme sinyali
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorMessagePrefix(e.toString()))),
        );
      }
    }
  }

  // --- UI BİLEŞENLERİ ---

  /// Tarih Seçim Aracı
  void _showDatePicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedDate,
            maximumDate: DateTime.now().add(const Duration(days: 365)),
            minimumDate: _isRecurring
                ? DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  )
                : DateTime(2020),
            minimumYear: 2020,
            maximumYear: 2030,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });
              HapticFeedback.selectionClick();
            },
          ),
        );
      },
    );
  }

  /// Kategori Seçim Modalı
  void _showCategorySelectionModal() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Consumer(
              builder: (context, ref, child) {
                final categoryListAsync = ref.watch(categoryListProvider);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Tutamaç
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.selectCategoryTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddCategoryDialog();
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.blue,
                              size: 28,
                            ),
                            tooltip: l10n.addNewCategoryTooltip,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: categoryListAsync.when(
                          data: (allCategories) {
                            final defaultCategories = allCategories
                                .where((c) => !c.isCustom)
                                .toList();
                            final customCategories = allCategories
                                .where((c) => c.isCustom)
                                .toList();

                            return CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                // 1. Varsayılan Kategoriler
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      l10n.defaultCategoriesTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Center(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 12,
                                      alignment: WrapAlignment.center,
                                      children: defaultCategories.map((cat) {
                                        return SizedBox(
                                          width: 80,
                                          child: _buildCategoryItem(cat),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),

                                // 2. Özel Kategoriler
                                if (customCategories.isNotEmpty) ...[
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 24,
                                        bottom: 12,
                                      ),
                                      child: Column(
                                        children: [
                                          const Divider(
                                            thickness: 1,
                                            indent: 40,
                                            endIndent: 40,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            l10n.userCategoriesTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.touch_app,
                                                size: 14,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                l10n.deleteCategoryHint,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Center(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 12,
                                        alignment: WrapAlignment.center,
                                        children: customCategories.map((cat) {
                                          return SizedBox(
                                            width: 80,
                                            child: _buildCategoryItem(cat),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],

                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 32),
                                ),
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('${l10n.errorGeneric(err)}')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryItem(CategoryModel cat) {
    final isSelected = _categoryName == cat.name;
    return InkWell(
      onTap: () {
        setState(() {
          _categoryName = cat.name;
        });
        HapticFeedback.selectionClick();
        Navigator.pop(context);
      },
      onLongPress: cat.isCustom ? () => _showDeleteCategoryDialog(cat) : null,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(cat.colorValue).withOpacity(0.2)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Color(cat.colorValue), width: 2)
                  : null,
            ),
            child: Icon(
              IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
              color: Color(cat.colorValue),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cat.getLocalizedName(context),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(CategoryModel category) {
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
                if (_categoryName == category.name) {
                  setState(() {
                    _categoryName = l10n.categoryOther;
                  });
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.deleteButton),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController _nameController = TextEditingController();
    Color _selectedColor = AppColors.userSelectionColors.first;
    IconData _selectedIcon = Icons.shopping_cart;

    final List<Color> colors = AppColors.userSelectionColors;
    final List<IconData> icons = [
      Icons.shopping_cart,
      Icons.receipt_long,
      Icons.restaurant,
      Icons.directions_bus,
      Icons.home,
      Icons.movie,
      Icons.fitness_center,
      Icons.school,
      Icons.pets,
      Icons.flight,
      Icons.redeem,
      Icons.child_care,
      Icons.gamepad,
      Icons.more_horiz,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.addNewCategoryTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.categoryNameLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.selectColorLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: colors.map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: CircleAvatar(
                            backgroundColor: color,
                            radius: 18,
                            child: _selectedColor == color
                                ? const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.selectIconLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: icons.map((icon) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            radius: 22,
                            child: Icon(
                              icon,
                              size: 24,
                              color: _selectedIcon == icon
                                  ? _selectedColor
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancelButton),
                ),
                TextButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      ref
                          .read(categoryControllerProvider.notifier)
                          .addCategory(
                            _nameController.text,
                            _selectedColor.value,
                            _selectedIcon.codePoint,
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(l10n.addButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRecurringSelectionModal() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _RecurringSelectionList();
      },
    ).then((selectedItem) {
      if (selectedItem != null && selectedItem is RecurringTransactionModel) {
        setState(() {
          _amountController.text = selectedItem.amount.toString();
          _categoryName = selectedItem.categoryName;
          _isExpense = selectedItem.type == TransactionType.expense;
          _titleController.text = selectedItem.title;
          _description = selectedItem.description;
          _selectedDate = DateTime.now();
          _isRecurring = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = _isExpense
        ? AppColors.expenseRed
        : AppColors.incomeGreen;
    final categoryListAsync = ref.watch(categoryListProvider);

    // Seçili kategori modeli (Icon vb. için)
    final CategoryModel selectedCategory = categoryListAsync.maybeWhen(
      data: (categories) => categories.firstWhere(
        (c) => c.name == _categoryName,
        orElse: () => CategoryModel(
          id: '',
          name: 'categoryOther',
          iconCode: Icons.category.codePoint,
          colorValue: Colors.grey.value,
        ),
      ),
      orElse: () => CategoryModel(
        id: '',
        name: 'categoryOther',
        iconCode: Icons.category.codePoint,
        colorValue: Colors.grey.value,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit != null
              ? l10n.editTransactionTitle
              : (_isExpense ? l10n.addExpenseTitle : l10n.addIncomeTitle),
        ),
        actions: [
          // Düzenli İşlemden Kopya Oluşturma Butonu
          if (widget.transactionToEdit == null && !_isRecurring)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _showRecurringSelectionModal,
                icon: const Icon(Icons.playlist_add, size: 20),
                label: Text(l10n.addFromRecurring),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Gelir / Gider Değiştirici
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  isSelected: [!_isExpense, _isExpense],
                  fillColor: primaryColor.withOpacity(0.1),
                  selectedColor: primaryColor,
                  color: Colors.grey.shade600,
                  selectedBorderColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    minHeight: 40,
                  ),
                  onPressed: (index) {
                    setState(() {
                      _isExpense = index == 1;
                    });
                    HapticFeedback.lightImpact();
                  },
                  children: [
                    Text(
                      l10n.incomeType.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      l10n.expenseType.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tutar
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 32,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '₺',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.errorEnterAmount;
                }
                if (double.tryParse(value) == null) {
                  return l10n.errorInvalidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Başlık
            TextFormField(
              controller: _titleController,
              maxLength: 30, // Karakter Sınırı
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: l10n.titleHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
                counterText: "",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.errorEnterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kategori Seçimi
            ListTile(
              onTap: _showCategorySelectionModal,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(selectedCategory.colorValue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconData(
                    selectedCategory.iconCode,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Color(selectedCategory.colorValue),
                ),
              ),
              title: Text(l10n.categoryLabel),
              subtitle: Text(
                _categoryName == null
                    ? l10n.selectCategoryHint
                    : selectedCategory.getLocalizedName(context),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(height: 16),

            // Tarih ve Düzenli İşlem Anahtarı
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: ListTile(
                      onTap: _showDatePicker,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(l10n.dateLabel),
                      subtitle: Text(
                        DateFormat(
                          'dd MMMM yyyy',
                          'tr_TR',
                        ).format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                // Düzenleme modunda değilsek 'Düzenli' switch'ini göster
                if (widget.transactionToEdit == null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.recurringSwitchLabel,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Switch(
                          value: _isRecurring,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            setState(() {
                              _isRecurring = val;
                              if (_isRecurring) {
                                // Geçmiş tarih + Düzenli seçilemez -> Bugüne çek
                                final now = DateTime.now();
                                final today = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                );
                                if (_selectedDate.isBefore(today)) {
                                  _selectedDate = now;
                                  _shakeController.forward(from: 0);
                                  HapticFeedback.heavyImpact();
                                }
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            // Düzenli işlem sıklık seçimi
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _recurringFrequency,
                decoration: InputDecoration(
                  labelText: l10n.frequencyLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.repeat),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'daily',
                    child: Text(l10n.frequencyDaily),
                  ),
                  DropdownMenuItem(
                    value: 'weekly',
                    child: Text(l10n.frequencyWeekly),
                  ),
                  DropdownMenuItem(
                    value: 'monthly',
                    child: Text(l10n.frequencyMonthly),
                  ),
                  DropdownMenuItem(
                    value: 'yearly',
                    child: Text(l10n.frequencyYearly),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _recurringFrequency = val);
                  }
                },
              ),
            ],

            const SizedBox(height: 16),

            // Açıklama
            TextFormField(
              initialValue: _description,
              decoration: InputDecoration(
                labelText: l10n.descriptionLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
              onChanged: (val) => _description = val,
            ),
            const SizedBox(height: 32),

            // Kaydet Butonu
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  widget.transactionToEdit != null
                      ? l10n.updateButton
                      : l10n.saveButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Düzenli İşlemlerden Seçim Listesi (Modal İçeriği)
class _RecurringSelectionList extends ConsumerWidget {
  const _RecurringSelectionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recurringListAsync = ref.watch(recurringListProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Text(
              l10n.selectRecurringTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: recurringListAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(child: Text(l10n.noRecurringFound));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Icon(
                        item.type == TransactionType.expense
                            ? Icons.arrow_circle_down
                            : Icons.arrow_circle_up,
                        color: item.type == TransactionType.expense
                            ? Colors.red
                            : Colors.green,
                      ),
                      title: Text(
                        item.title.isNotEmpty ? item.title : item.categoryName,
                      ),
                      subtitle: Text('${item.amount} ₺ - ${item.frequency}'),
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text(l10n.errorGeneric(e))),
            ),
          ),
        ],
      ),
    );
  }
}
