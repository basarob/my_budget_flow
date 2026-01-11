import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';

/// Dosya: goal_type_segment.dart
///
/// Amaç: Hedef tipini (Yatırım/Harcama) seçmek için kullanılan özel segment widget.
class GoalTypeSegment extends StatelessWidget {
  final GoalType selectedType;
  final ValueChanged<GoalType> onTypeChanged;

  const GoalTypeSegment({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // YATIRIM (SAVINGS)
          Expanded(
            child: _buildSegmentButton(
              context: context,
              title: l10n.goalTypeSavings.toUpperCase(),
              isSelected: selectedType == GoalType.investment,
              color: AppColors.incomeGreen,
              onTap: () => onTypeChanged(GoalType.investment),
            ),
          ),

          // HARCAMA (EXPENSE)
          Expanded(
            child: _buildSegmentButton(
              context: context,
              title: l10n.goalTypeExpense.toUpperCase(),
              isSelected: selectedType == GoalType.expense,
              color: AppColors.expenseRed,
              onTap: () => onTypeChanged(GoalType.expense),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.passive.withValues(alpha: 0.3)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
