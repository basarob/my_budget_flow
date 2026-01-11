import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';

/// Dosya: goal_card.dart
///
/// Amaç: Tek bir hedefin özet bilgilerini ve ilerleme durumunu gösteren kart.

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onAddMoney;
  final VoidCallback onWithdrawMoney;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onAddMoney,
    required this.onWithdrawMoney,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    final progressColor = Color(goal.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: İkon ve Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      IconData(goal.iconCode, fontFamily: 'MaterialIcons'),
                      color: progressColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (goal.deadline != null)
                          Text(
                            DateFormat('dd.MM.yyyy').format(goal.deadline!),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Yüzde Göstergesi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '%${(goal.progress * 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // İlerleme Çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: AppColors.background,
                  color: progressColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),

              // Tutarlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(goal.currentAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    currencyFormat.format(goal.targetAmount),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Alt Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onWithdrawMoney,
                    icon: const Icon(
                      Icons.remove,
                      size: 18,
                      color: AppColors.expenseRed,
                    ),
                    label: Text(
                      l10n.withdrawMoneyTitle,
                      style: const TextStyle(
                        color: AppColors.expenseRed,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: onAddMoney,
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.incomeGreen,
                    ),
                    label: Text(
                      l10n.addMoneyTitle,
                      style: const TextStyle(
                        color: AppColors.incomeGreen,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
