import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../../l10n/app_localizations.dart'; // Import eklendi

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;
  final bool initialIsRecurring; // Context-aware Add (User Feedback #5)

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
  // Form State
  late bool _isExpense;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String? _categoryName;
  late DateTime _selectedDate;
  String _description = '';

  // Recurring State
  late bool _isRecurring;
  String _recurringFrequency = 'monthly';

  final _formKey = GlobalKey<FormState>();

  // Shake Animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Hardcoded _categories listesi silindi. Provider'dan gelecek.

  @override
  void initState() {
    super.initState();
    // Animation Setup
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
      // Default: Diğer
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

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    // Fallback if null (shouldn't be due to init logic, but safe guard)
    // Fallback if null (shouldn't be due to init logic, but safe guard)
    // Build context here is valid, so we can localize defaults if needed,
    // but better to save consistent keys. Let's use 'Diğer' as key for now or l10n checks.
    // Actually, saving localized strings to DB is bad practice, but current app design seems to stick to it.
    // For now we will check if _categoryName is null, if so we use a non-localized 'Other' or 'Diğer' as key.
    // Ideally we should use IDs.
    final categoryToSave = _categoryName ?? 'categoryOther';

    HapticFeedback.mediumImpact();

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final amount = double.parse(_amountController.text);
    final title = _titleController.text.trim(); // Boşlukları temizle
    final description = _description.trim(); // Boşlukları temizle

    try {
      if (_isRecurring) {
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
          await ref
              .read(transactionControllerProvider.notifier)
              .deleteTransaction(widget.transactionToEdit!.id);
        }

        await ref
            .read(transactionControllerProvider.notifier)
            .addTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true); // Signal refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorMessagePrefix(e.toString()))),
        );
      }
    }
  }

  // --- UI METOTLARI ---

  // Tarih seçici göster
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

  // Kategori Seçim Modalı (Varsayılan ve Kullanıcı Kategorileri)
  void _showCategorySelectionModal() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Tam ekran hissi için
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
                      // Drag Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Modal Başlığı ve Ekleme Butonu
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
                            // Kategorileri ayır: Varsayılan ve Özel
                            final defaultCategories = allCategories
                                .where((c) => !c.isCustom)
                                .toList();
                            final customCategories = allCategories
                                .where((c) => c.isCustom)
                                .toList();

                            return CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                // 1. Varsayılan Kategoriler Başlığı
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

                                // 2. Varsayılan Kategoriler (Wrap ile Ortalanmış)
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

                                // 3. Kullanıcı Kategorileri Başlığı ve Ayırıcı
                                if (customCategories.isNotEmpty)
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

                                // 4. Kullanıcı Kategorileri
                                if (customCategories.isNotEmpty)
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

  // Kategori Öğesi Yapıcı
  Widget _buildCategoryItem(CategoryModel cat) {
    final isSelected = _categoryName == cat.name;
    return InkWell(
      onTap: () {
        setState(() {
          _categoryName = cat.name;
        });
        HapticFeedback.selectionClick();
        Navigator.pop(context); // Seçim yapınca kapat
      },
      onLongPress: cat.isCustom
          ? () => _showDeleteCategoryDialog(cat)
          : null, // Sadece özeller silinebilir
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
            cat.getLocalizedName(context), // Localized Name
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Kategori Silme Onay Dialogu
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
                // Eğer seçili olanı sildiysek seçimi sıfırla
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

  // Yeni Kategori Ekleme Dialogu
  void _showAddCategoryDialog() {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController _nameController = TextEditingController();
    Color _selectedColor = AppColors.userSelectionColors.first;
    IconData _selectedIcon = Icons.shopping_cart;

    // Kullanıcıya sunulan renkler (Tema'dan)
    final List<Color> colors = AppColors.userSelectionColors;

    // Kullanıcıya sunulan ikonlar
    final List<IconData> icons = [
      Icons.shopping_cart, // Market/Alışveriş
      Icons.receipt_long, // Fatura/Fiş
      Icons.restaurant, // Yemek/Restoran
      Icons.directions_bus, // Ulaşım
      Icons.home, // Kira/Ev
      Icons.movie, // Eğlence/Sinema
      Icons.fitness_center, // Spor/Sağlık
      Icons.school, // Eğitim/Okul
      Icons.pets, // Evcil Hayvan
      Icons.flight, // Seyahat/Tatil
      Icons.redeem, // Hediye
      Icons.child_care, // Çocuk/Bakım
      Icons.gamepad, // Oyun/Hobi
      Icons.more_horiz, // Diğer
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
                    // Renk Seçimi
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
                    // İkon Seçimi
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

  // Düzenli işlemden kopyalama modalı
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
          _selectedDate = DateTime.now(); // Bugün için ekle (kopya)
          _isRecurring = false; // Tek seferlik
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Localization ve Theme erişimi
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Gelir/Gider durumuna göre ana renk belirleme
    final primaryColor = _isExpense
        ? AppColors.expenseRed
        : AppColors.incomeGreen;

    // Kategori bilgisini göstermek için helper (Provider ile uyumlu)
    final categoryListAsync = ref.watch(categoryListProvider);
    // Loading veya Error durumunda default bir placeholder döner
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
          // User Feedback #1: Butonu AppBar sağ tarafına taşı (Metinli)
          // Düzenliden Ekle Butonu
          if (widget.transactionToEdit == null && !_isRecurring)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _showRecurringSelectionModal,
                icon: const Icon(Icons.playlist_add, size: 20),
                label: Text(l10n.addFromRecurring), // Localized
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
            // Removed Align widget from body

            // Gelir / Gider Toggle Buttons
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

            // Tutar Alanı
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

            // Başlık Alanı (User Feedback #3: Karakter Sınırı Önerisi)
            // 30 Karakterlik bir sınır koymak, listeleme sırasında taşmaları önler.
            // 10-13 çok kısa olabilir.
            TextFormField(
              controller: _titleController,
              maxLength: 30, // Karakter sınırlandırması
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
            const SizedBox(height: 24),

            // User Feedback #3: Kategori Seçimi (ListTile)
            // Kategori Seçimi
            ListTile(
              title: Text(l10n.categoryLabel),
              subtitle: Text(
                _categoryName == null
                    ? l10n.selectLabel
                    : selectedCategory.getLocalizedName(context),
              ),
              leading: CircleAvatar(
                backgroundColor: Color(
                  selectedCategory.colorValue,
                ).withOpacity(0.2),
                child: Icon(
                  IconData(
                    selectedCategory.iconCode,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: Color(selectedCategory.colorValue),
                  size: 20,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showCategorySelectionModal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: theme.cardColor,
            ),
            const SizedBox(height: 16),

            // Tarih Seçimi
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * 2, 0),
                  child: child,
                );
              },
              child: ListTile(
                title: Text(l10n.dateLabel),
                subtitle: Text(
                  DateFormat.yMMMd(
                    Localizations.localeOf(context).toString(),
                  ).format(_selectedDate),
                  style: TextStyle(
                    color:
                        _isRecurring &&
                            _selectedDate.isBefore(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                              ),
                            )
                        ? Colors.red
                        : null,
                  ), // Hata durumunda renk değişimi (Optional)
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: theme.cardColor,
                onTap: _showDatePicker,
              ),
            ),
            const SizedBox(height: 16),

            // Not Ekle
            ExpansionTile(
              key: ValueKey(_description.isNotEmpty),
              title: Text(l10n.addNoteLabel),
              initiallyExpanded: _description.isNotEmpty,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    initialValue: _description,
                    minLines: 1,
                    maxLines: 5, // User Feedback: Not alanı genişlesin
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      hintText: l10n.noteHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) => _description = val,
                  ),
                ),
              ],
            ),

            // Düzenli Ödeme
            if (widget.transactionToEdit == null) ...[
              SwitchListTile(
                title: Text(l10n.makeRecurringLabel),
                subtitle: Text(l10n.recurringDescription),
                value: _isRecurring,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val;
                    if (_isRecurring) {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      // Eğer seçili tarih geçmişteyse bugüne çek
                      if (_selectedDate.isBefore(today)) {
                        _selectedDate = now;
                        // Kullanıcıya bildirmek için animasyon
                        _shakeController.forward(from: 0);
                        HapticFeedback.heavyImpact();
                      }
                    }
                  });
                },
              ),

              if (_isRecurring) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    value: _recurringFrequency,
                    decoration: InputDecoration(labelText: l10n.frequencyLabel),
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
                ),
              ],
            ],

            const SizedBox(height: 32),

            // Kaydet
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  l10n.saveButton.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
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

class _RecurringSelectionList extends ConsumerWidget {
  const _RecurringSelectionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(recurringListProvider);
    final categoryListAsync = ref.watch(
      categoryListProvider,
    ); // Watch categories
    final l10n = AppLocalizations.of(context)!;

    // Helper to find category and localized name
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.selectRecurringTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: listAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Center(child: Text(l10n.noRecurringFound));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  // isExpense unused
                  final category = findCategory(item.categoryName);

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                          category.colorValue,
                        ).withOpacity(0.2),
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
                            : category.getLocalizedName(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${item.amount} ₺ • ${item.frequency}",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context, item);
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) =>
                Center(child: Text(l10n.errorMessagePrefix(e.toString()))),
          ),
        ),
      ],
    );
  }
}
