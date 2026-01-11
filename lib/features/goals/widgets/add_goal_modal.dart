import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import 'package:intl/intl.dart';

/// Dosya: add_goal_modal.dart
///
/// Amaç: Yeni hedef ekleme veya mevcut hedefi düzenleme formu.

class AddGoalModal extends ConsumerStatefulWidget {
  final Goal? goalToEdit;

  const AddGoalModal({super.key, this.goalToEdit});

  @override
  ConsumerState<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends ConsumerState<AddGoalModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  DateTime? _selectedDate;
  int _selectedColor = 0xFF4CAF50; // Default Green
  int _selectedIcon = Icons.savings.codePoint;

  final List<Color> _colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  final List<IconData> _icons = [
    Icons.savings,
    Icons.home,
    Icons.directions_car,
    Icons.flight,
    Icons.school,
    Icons.computer,
    Icons.shopping_bag,
    Icons.fitness_center,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goalToEdit?.title);
    _amountController = TextEditingController(
      text: widget.goalToEdit?.targetAmount.toStringAsFixed(0) ?? '',
    );
    _selectedDate = widget.goalToEdit?.deadline;
    if (widget.goalToEdit != null) {
      _selectedColor = widget.goalToEdit!.colorValue;
      _selectedIcon = widget.goalToEdit!.iconCode;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount =
          double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;

      if (amount <= 0) {
        return;
      }

      FocusScope.of(context).unfocus();

      if (widget.goalToEdit == null) {
        await ref
            .read(goalControllerProvider.notifier)
            .addGoal(
              title: title,
              targetAmount: amount,
              iconCode: _selectedIcon,
              colorValue: _selectedColor,
              deadline: _selectedDate,
            );
      } else {
        final updatedGoal = widget.goalToEdit!.copyWith(
          title: title,
          targetAmount: amount,
          iconCode: _selectedIcon,
          colorValue: _selectedColor,
          deadline: _selectedDate,
        );
        await ref.read(goalControllerProvider.notifier).updateGoal(updatedGoal);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.goalToEdit != null;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? l10n.goalEditTitle : l10n.goalAddTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _titleController,
                labelText: l10n.goalTitleLabel,
                prefixIcon: Icons.title,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.errorEnterTitle : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                labelText: l10n.goalTargetAmount,
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.errorEnterAmount : null,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.passive), // Fixed color
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? l10n.goalDeadline
                            : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.selectColorLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = _selectedColor == color.toARGB32();
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedColor = color.toARGB32()),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.textPrimary,
                                  width: 3,
                                )
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

              Text(
                l10n.selectIconLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    final isSelected = _selectedIcon == icon.codePoint;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedIcon = icon.codePoint),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(_selectedColor)
                              : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.passive,
                          ), // Fixed color
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              GradientButton(
                text: isEditing ? l10n.updateButton : l10n.addButton,
                onPressed: _submit,
                isLoading: ref.watch(goalControllerProvider).isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
