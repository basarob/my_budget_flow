import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/models/recurring_transaction_model.dart';

/// Günlük Özet Kartı
///
/// Seçili günün toplam gelir, gider, net bakiye ve yaklaşan ödemelerini gösteren kart.
class DaySummaryCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<RecurringTransactionModel> upcomingPayments;

  const DaySummaryCard({
    super.key,
    required this.transactions,
    required this.upcomingPayments,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      symbol: '₺',
    );

    // Toplam gelir hesapla
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Toplam gider hesapla
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Net Bakiye
    final netBalance = totalIncome - totalExpense;

    // Yaklaşan ödeme toplamı
    final totalUpcoming = upcomingPayments.fold(
      0.0,
      (sum, r) => sum + r.amount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Üst Satır: Gelir - Gider - Yaklaşan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Gelir
              _buildSummaryItem(
                context,
                icon: Icons.arrow_downward_rounded,
                color: AppColors.incomeGreen,
                label: l10n.incomeType,
                amount: totalIncome,
                formatter: currencyFormat,
              ),

              // Ayırıcı
              Container(
                height: 24, // Smaller height
                width: 1,
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),

              // Gider
              _buildSummaryItem(
                context,
                icon: Icons.arrow_upward_rounded,
                color: AppColors.expenseRed,
                label: l10n.expenseType,
                amount: totalExpense,
                formatter: currencyFormat,
              ),
            ],
          ),

          const SizedBox(height: 8), // Reduced spacing
          Divider(color: AppColors.textSecondary.withValues(alpha: 0.1)),
          const SizedBox(height: 8),

          // Alt Satır: Net Bakiye (ve varsa Yaklaşan)
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centered
            children: [
              // Net Bakiye
              Text(
                '${l10n.netBalanceLabel}:',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.textSecondary, // Gray color requested
                ),
              ),
              const SizedBox(width: 6),
              Text(
                currencyFormat.format(netBalance),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: netBalance >= 0
                      ? AppColors.incomeGreen
                      : AppColors.expenseRed,
                ),
              ),

              // Yaklaşan varsa sağda göster (Kompakt ayırıcı ile)
              if (upcomingPayments.isNotEmpty) ...[
                Container(
                  height: 14,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  '~${currencyFormat.format(totalUpcoming)}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13, // Smaller font
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required double amount,
    required NumberFormat formatter,
  }) {
    return Row(
      // Changed to Row for more compact look if preferred, or keep Column but smaller
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // Small icon circle background
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            Text(
              formatter.format(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
