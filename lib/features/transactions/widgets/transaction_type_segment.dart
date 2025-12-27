import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// İşlem Tipi Seçim Segmenti (Gelir / Gider)
///
/// Kullanıcının işlem eklerken veya filtrelerken "Gelir" veya "Gider"
/// seçenekleri arasında geçiş yapmasını sağlayan özel toggle butonu.
///
/// Görünüm:
/// - Seçili olmayan taraf şeffaf, seçili taraf kendi rengiyle (Yeşil/Kırmızı) dolgulu görünür.
class TransactionTypeSegment extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onTypeChanged;

  const TransactionTypeSegment({
    super.key,
    required this.isExpense,
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
          // GELİR BUTONU
          Expanded(
            child: _buildSegmentButton(
              context: context,
              title: l10n.incomeType.toUpperCase(),
              isSelected: !isExpense,
              color: AppColors.incomeGreen,
              onTap: () => onTypeChanged(false),
            ),
          ),

          // GİDER BUTONU
          Expanded(
            child: _buildSegmentButton(
              context: context,
              title: l10n.expenseType.toUpperCase(),
              isSelected: isExpense,
              color: AppColors.expenseRed,
              onTap: () => onTypeChanged(true),
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
