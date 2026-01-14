import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';

/// Dosya: goal_card.dart
///
/// Amaç: Tek bir hedefin özet bilgilerini ve ilerleme durumunu gösteren kart.
///
/// Özellikler:
/// - Otomatik hesaplanan ilerleme durumu
/// - Hedef Türüne göre sabit ikon
/// - Düzenleme (Tap) ve Sıfırlama (Long Press) etkileşimleri

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // Renk ve İkon
    final progressColor = Color(goal.colorValue);
    final iconData = goal.type == GoalType.investment
        ? Icons.savings
        : Icons.credit_card;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
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
                      color: progressColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: progressColor, size: 24),
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
                        Text(
                          '${l10n.startDate}: ${DateFormat('dd.MM.yyyy').format(goal.startDate)}',
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
                      color: progressColor.withValues(alpha: 0.3),
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

              // Tutarlar (Biriken / Hedef)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.type == GoalType.investment
                            ? l10n.collected
                            : l10n.spent,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        currencyFormat.format(goal.collectedAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  // Kalan Miktar
                  Column(
                    children: [
                      Text(
                        l10n.goalRemaining,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        currencyFormat.format(
                          (goal.targetAmount - goal.collectedAmount).clamp(
                            0,
                            goal.targetAmount,
                          ),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.goalTargetAmount,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        currencyFormat.format(goal.targetAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Tamamlanma Mesajı
              if (goal.progress >= 1.0) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: goal.type == GoalType.investment
                        ? AppColors.incomeGreen.withValues(alpha: 0.1)
                        : AppColors.expenseRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: goal.type == GoalType.investment
                          ? AppColors.incomeGreen.withValues(alpha: 0.3)
                          : AppColors.expenseRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        goal.type == GoalType.investment
                            ? Icons.celebration
                            : Icons.warning_amber_rounded,
                        size: 16,
                        color: goal.type == GoalType.investment
                            ? AppColors.incomeGreen
                            : AppColors.expenseRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.type == GoalType.investment
                              ? l10n.savingsGoalCompleted
                              : l10n.expenseGoalCompleted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: goal.type == GoalType.investment
                                ? AppColors.incomeGreen
                                : AppColors.expenseRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
