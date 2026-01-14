import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';
import '../widgets/goal_type_segment.dart';
import '../providers/goal_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/models/category_model.dart';

/// Dosya: add_goal_screen.dart
///
/// Amaç: Yeni hedef ekleme veya mevcut hedefi düzenleme ekranıdır.
///
/// Özellikler:
/// - Hedef Tipi Seçimi (Yatırım / Harcama)
/// - Tutar ve Başlık Girişi
/// - Kategori Seçimi (Çoklu Seçim)
/// - Tarih ve Renk Seçimi
class AddGoalScreen extends ConsumerStatefulWidget {
  final Goal? goalToEdit;

  const AddGoalScreen({super.key, this.goalToEdit});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  // State
  GoalType _selectedType = GoalType.investment;
  late DateTime _startDate;
  List<String> _selectedCategoryIds = [];
  int _selectedColor = AppColors.userSelectionColors[0].toARGB32();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);

    if (widget.goalToEdit != null) {
      final goal = widget.goalToEdit!;
      _selectedType = goal.type;
      _titleController = TextEditingController(text: goal.title);
      _amountController.text = goal.targetAmount.toStringAsFixed(0);
      _startDate = goal.startDate;
      _selectedCategoryIds = List.from(goal.categoryIds);
      _selectedColor = goal.colorValue;
    } else {
      _titleController = TextEditingController();
      _selectedColor = AppColors.userSelectionColors[4].toARGB32();
    }

    _amountFocusNode.addListener(() {
      setState(() {});
    });
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // --- Actions ---

  void _onTypeChanged(GoalType type) {
    setState(() {
      _selectedType = type;
      // Tür değişince varsayılan renk de değişsin (Eğer kullanıcı henüz elle seçmediyse...
      // ama basitlik için direkt atıyoruz)
      if (type == GoalType.investment) {
        _selectedColor = AppColors.userSelectionColors[4].toARGB32();
      } else {
        _selectedColor = AppColors.userSelectionColors[6].toARGB32();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showDatePicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _startDate,
            minimumDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
            maximumDate: DateTime.now().add(const Duration(days: 1)),
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _startDate = DateTime(newDate.year, newDate.month, newDate.day);
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryIds.isEmpty) {
      SnackbarUtils.showError(context, message: l10n.selectCategoriesError);
      return;
    }

    final title = _titleController.text.trim();
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;

    if (amount <= 0) {
      SnackbarUtils.showError(context, message: l10n.errorEnterAmount);
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final notifier = ref.read(goalControllerProvider.notifier);
      if (widget.goalToEdit == null) {
        await notifier.addGoal(
          title: title,
          targetAmount: amount,
          startDate: _startDate,
          type: _selectedType,
          categoryIds: _selectedCategoryIds,
          colorValue: _selectedColor,
        );
      } else {
        final updatedGoal = widget.goalToEdit!.copyWith(
          title: title,
          targetAmount: amount,
          startDate: _startDate,
          categoryIds: _selectedCategoryIds,
          colorValue: _selectedColor,
        );
        await notifier.updateGoal(updatedGoal);
      }

      if (mounted) {
        Navigator.pop(context, true); // Success signal
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, message: '${l10n.errorDefault}: $e');
      }
    }
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Color(_selectedColor);

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          widget.goalToEdit != null ? l10n.goalEditTitle : l10n.goalAddTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Hedef Tipi Segmenti
            GoalTypeSegment(
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
            ),
            const SizedBox(height: 32),

            // 2. Tutar Alanı (Büyük input)
            Column(
              children: [
                Text(
                  l10n.goalTargetAmount.toUpperCase(),
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
                    hintText: '0',
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
                    // Dengeleyici suffix
                    suffixIcon: const SizedBox(width: 40, height: 40),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.passive.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.passive.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.passive.withValues(alpha: 0.3),
                      ),
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

            // 3. Başlık
            CustomTextField(
              controller: _titleController,
              labelText: l10n.goalTitleLabel,
              prefixIcon: Icons.flag,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v?.isEmpty ?? true ? l10n.errorEnterTitle : null,
            ),
            const SizedBox(height: 16),

            // 4. Tarih Seçimi
            InkWell(
              onTap: _showDatePicker,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.passive.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.startDate,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'd MMMM yyyy',
                              Localizations.localeOf(context).toString(),
                            ).format(_startDate),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.passive),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Renk Seçimi
            Text(
              l10n.selectColorLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppColors.userSelectionColors.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final color = AppColors.userSelectionColors[index];
                  final isSelected = _selectedColor == color.toARGB32();
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColor = color.toARGB32()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 40 : 32,
                      height: isSelected ? 40 : 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.textPrimary, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 6. Kategoriler
            Text(
              l10n.selectCategories(_selectedCategoryIds.length),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildCategoryGrid(l10n),
            const SizedBox(height: 32),

            // Kaydet Butonu
            GradientButton(
              onPressed: _submit,
              text: widget.goalToEdit != null
                  ? l10n.updateButton
                  : l10n.addButton,
              icon: Icons.check_circle_outline,
              isLoading: ref.watch(goalControllerProvider).isLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(AppLocalizations l10n) {
    final categoryListAsync = ref.watch(categoryListProvider);

    return categoryListAsync.when(
      data: (allCategories) {
        final defaultCats = allCategories.where((c) => !c.isCustom).toList();
        final customCats = allCategories.where((c) => c.isCustom).toList();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.passive.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: defaultCats.length,
                itemBuilder: (context, index) =>
                    _buildCategoryItem(defaultCats[index]),
              ),
              if (customCats.isNotEmpty) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.userCategoriesTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.passive,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: customCats.length,
                  itemBuilder: (context, index) =>
                      _buildCategoryItem(customCats[index]),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('${l10n.categoriesLoadError}: $e'),
    );
  }

  Widget _buildCategoryItem(CategoryModel cat) {
    final isSelected = _selectedCategoryIds.contains(cat.name);
    final itemColor = Color(cat.colorValue);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategoryIds.remove(cat.name);
          } else {
            _selectedCategoryIds.add(cat.name);
          }
        });
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? itemColor.withValues(alpha: 0.2)
                  : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? itemColor
                    : AppColors.passive.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
              color: isSelected ? itemColor : AppColors.passive,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cat.getLocalizedName(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? itemColor : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
