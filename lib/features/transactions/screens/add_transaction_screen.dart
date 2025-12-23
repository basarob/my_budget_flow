import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/transaction_type_segment.dart';
import '../widgets/selection_card.dart';
import '../widgets/category_selection_modal.dart';
import '../widgets/recurring_selection_modal.dart';
import '../../auth/services/auth_service.dart';
import '../../../l10n/app_localizations.dart';

/// Yeni İşlem Ekleme veya Mevcut İşlemi Düzenleme Ekranı
///
/// Kullanıcının gelir veya gider kaydı oluşturduğu form ekranıdır.
/// Hem yeni kayıt ekleme hem de var olan kaydı güncelleme amacıyla kullanılır.
///
/// Özellikler:
/// - **Dinamik Form**: Tutar, Başlık, Kategori, Tarih ve Açıklama alanları.
/// - **Düzenli İşlem Desteği**: İşlemi tekrar eden bir talimata dönüştürme seçeneği.
/// - **Animasyonlar**: Tarih değişimi ve form geçişlerinde akıcı animasyonlar (animate_do).
/// - **Hızlı Seçim**: Önceki düzenli işlemlerden kopyalayarak hızlı giriş yapabilme.
///
/// Parametreler:
/// - [transactionToEdit]: Eğer düzenleme modunda ise dolu gelir, yoksa null'dur.
/// - [initialIsRecurring]: Ekranın doğrudan "Düzenli İşlem Ekle" modunda açılmasını sağlar.
class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;
  final RecurringTransactionModel? recurringTransactionToEdit;
  final bool initialIsRecurring;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.recurringTransactionToEdit,
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
  final FocusNode _amountFocusNode = FocusNode(); // Tutar odak takibi
  final TextEditingController _titleController = TextEditingController();
  String? _categoryName;
  late DateTime _selectedDate;
  String _description = '';

  // UI Durumu
  bool _isNoteVisible = false; // Not alanı görünürlüğü

  // Düzenli İşlem Durumu
  late bool _isRecurring;
  String _recurringFrequency = 'monthly';
  int _dateAnimKey = 0; // Tarih değişimi animasyonu için

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Tutar alanı odak değişimi ve metin değişimi takibi
    _amountFocusNode.addListener(() {
      setState(() {}); // Odak değişince UI yenile (İkon görünürlüğü için)
    });
    _amountController.addListener(() {
      setState(() {}); // Metin değişince UI yenile (Renk değişimi için)
    });

    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _isExpense = t.type == TransactionType.expense;
      _amountController.text = t.amount.toString();
      _titleController.text = t.title;
      _categoryName = t.categoryName;
      _selectedDate = t.date;
      _description = t.description ?? '';
      _isNoteVisible = _description.isNotEmpty; // Açıklama varsa alanı aç
      _isRecurring = false;
    } else if (widget.recurringTransactionToEdit != null) {
      final t = widget.recurringTransactionToEdit!;
      _isExpense = t.type == TransactionType.expense;
      _amountController.text = t.amount.toString();
      _titleController.text = t.title;
      _categoryName = t.categoryName;
      // Düzenli işlemde başlangıç tarihi önemlidir
      _selectedDate = t.startDate;
      _description = t.description;
      _isNoteVisible = _description.isNotEmpty;
      _isRecurring = true;
      _recurringFrequency = t.frequency;
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
    _amountFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// İşlemi Kaydet (Ekle veya Güncelle)
  ///
  /// Form validasyonunu kontrol eder ve verileri veritabanına yazar.
  ///
  /// İşleyiş:
  /// 1. Formu doğrula (Tutar ve Başlık zorunlu).
  /// 2. Kullanıcı oturumunu kontrol et.
  /// 3. [TransactionController] üzerinden Firestore'a yazma işlemini başlat.
  ///    - Eğer [isRecurring] seçiliyse `RecurringTransaction` koleksiyonuna ekler.
  ///    - Aksi takdirde normal `Transaction` koleksiyonuna ekler.
  /// 4. Düzenleme modundaysa, eski kaydı silip yenisini ekler (Update mantığı).
  /// 5. Başarılı ise ekranı kapatır ve listeyi yenilemesi için sinyal (true) döner.
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
        // Düzenli İşlem Ekle veya Güncelle
        final recurringItem = RecurringTransactionModel(
          id: widget.recurringTransactionToEdit?.id ?? '', // Varsa ID koru
          title: title,
          userId: user.uid,
          amount: amount,
          type: _isExpense ? TransactionType.expense : TransactionType.income,
          categoryName: categoryToSave,
          frequency: _recurringFrequency,
          startDate: _selectedDate,
          description: description,
          // Güncelleme yapıyorsak eski verileri koru
          lastProcessedDate:
              widget.recurringTransactionToEdit?.lastProcessedDate,
          isActive: widget.recurringTransactionToEdit?.isActive ?? true,
        );

        if (widget.recurringTransactionToEdit != null) {
          await ref
              .read(transactionControllerProvider.notifier)
              .updateRecurringItem(recurringItem);
        } else {
          await ref
              .read(transactionControllerProvider.notifier)
              .addRecurringItem(recurringItem);
        }
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
        SnackbarUtils.showError(
          context,
          message: l10n.errorMessagePrefix(e.toString()),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Arkaplanı şeffaf yap
      builder: (context) {
        return CategorySelectionModal(
          currentCategoryName: _categoryName,
          onCategorySelected: (category) {
            setState(() {
              _categoryName = category.name;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showRecurringSelectionModal() async {
    final selectedItem = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const RecurringSelectionModal();
      },
    );

    if (!mounted) return;

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
          colorValue: AppColors.passive.value,
        ),
      ),
      orElse: () => CategoryModel(
        id: '',
        name: 'categoryOther',
        iconCode: Icons.category.codePoint,
        colorValue: AppColors.passive.value,
      ),
    );

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          (widget.transactionToEdit != null ||
                  widget.recurringTransactionToEdit != null)
              ? l10n.editTransactionTitle
              : (_isExpense ? l10n.addExpenseTitle : l10n.addIncomeTitle),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // 1. Gelir / Gider Segmenti
            TransactionTypeSegment(
              isExpense: _isExpense,
              onTypeChanged: (isExpense) {
                setState(() {
                  _isExpense = isExpense;
                });
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(height: 32),

            // 2. Tutar Alanı (Genişletildi)
            Column(
              children: [
                Text(
                  l10n.amountLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 40,
                    color: _amountController.text.isEmpty
                        ? AppColors.textPrimary
                        : primaryColor,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    // TL İkonu solda, diğer inputlar gibi
                    prefixIcon: Container(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        Icons.currency_lira,
                        color: _amountController.text.isEmpty
                            ? AppColors.passive
                            : primaryColor,
                        size: 32,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    // Metni tam ortalamak için görünmez suffix (Dengeleyici)
                    suffixIcon: Container(
                      padding: const EdgeInsets.only(left: 8, right: 12),
                      child: const Icon(
                        Icons.currency_lira,
                        color: Colors.transparent,
                        size: 32,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.passive.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.passive.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.passive.withOpacity(0.3),
                      ), // Mavi çerçeve yok
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorEnterAmount;
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. Başlık (CustomTextField)
            CustomTextField(
              controller: _titleController,
              labelText: l10n.titleHint,
              prefixIcon: Icons.edit_note_rounded,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.errorEnterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 4. Kategori & Tarih (Alt Alta Geniş Kartlar)
            SelectionCard(
              title: l10n.categoryLabel,
              selectedValue: _categoryName != null
                  ? selectedCategory.getLocalizedName(context)
                  : null,
              icon: IconData(
                selectedCategory.iconCode,
                fontFamily: 'MaterialIcons',
              ),
              iconColor: _categoryName != null
                  ? Color(selectedCategory.colorValue)
                  : AppColors.passive,
              onTap: _showCategorySelectionModal,
              placeholder: l10n.selectCategoryHint,
            ),
            const SizedBox(height: 16),
            _dateAnimKey > 0
                ? ElasticIn(
                    key: ValueKey('date-anim-$_dateAnimKey'),
                    child: SelectionCard(
                      title: l10n.dateLabel,
                      selectedValue: DateFormat.yMMMMd(
                        Localizations.localeOf(context).toString(),
                      ).format(_selectedDate),
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppColors.primary,
                      onTap: _showDatePicker,
                      placeholder: '',
                    ),
                  )
                : SelectionCard(
                    title: l10n.dateLabel,
                    selectedValue: DateFormat.yMMMMd(
                      Localizations.localeOf(context).toString(),
                    ).format(_selectedDate),
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primary,
                    onTap: _showDatePicker,
                    placeholder: '',
                  ),
            const SizedBox(height: 16),

            // 5. Düzenli İşlem Seçeneği (Sadece yeni eklemede)
            if (widget.transactionToEdit == null) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.passive.withOpacity(0.3)),
                ),
                child: SwitchListTile.adaptive(
                  value: _isRecurring,
                  onChanged: (val) {
                    setState(() {
                      _isRecurring = val;
                      if (_isRecurring) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        if (_selectedDate.isBefore(today)) {
                          _selectedDate = now;
                          _dateAnimKey++; // Animasyonu tetikle
                        }
                      }
                    });
                  },
                  title: Text(
                    l10n.recurringSwitchLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  secondary: Icon(
                    Icons.repeat,
                    color: _isRecurring
                        ? theme.primaryColor
                        : AppColors.passive,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  activeColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 6. Düzenli işlem sıklık seçimi
            if (_isRecurring) ...[
              DropdownButtonFormField<String>(
                value: _recurringFrequency,
                decoration: InputDecoration(
                  labelText: l10n.frequencyLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.passive.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.passive.withOpacity(0.3),
                    ),
                  ),
                  prefixIcon: const Icon(Icons.update),
                  filled: true,
                  fillColor: AppColors.surface,
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
              const SizedBox(height: 16),
            ],

            // 7. Not / Açıklama (Açılır Kapanır)
            if (!_isNoteVisible) ...[
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isNoteVisible = true;
                    });
                  },
                  icon: const Icon(Icons.add_comment_outlined, size: 20),
                  label: Text(l10n.addNoteLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Stack(
                children: [
                  TextFormField(
                    initialValue: _description,
                    onChanged: (val) => _description = val,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.descriptionLabel,
                      prefixIcon: Icon(Icons.notes, color: AppColors.passive),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.passive.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.passive.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    maxLines: 2,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: AppColors.passive,
                      onPressed: () {
                        setState(() {
                          _isNoteVisible = false;
                          _description = ''; // İsteğe bağlı temizleme
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // 6. Kaydet Butonu
            GradientButton(
              onPressed: _saveTransaction,
              text:
                  (widget.transactionToEdit != null ||
                      widget.recurringTransactionToEdit != null)
                  ? l10n.saveButton
                  : l10n.addButton,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
