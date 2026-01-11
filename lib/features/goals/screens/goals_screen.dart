import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import 'add_goal_screen.dart';
import '../widgets/goal_card.dart';

/// Dosya: goals_screen.dart
///
/// Amaç: Kullanıcının hedeflerini listelediği ve yönettiği ekran.
///
/// Özellikler:
/// - Hedef Listesi (GoalsWithProgressProvider)
/// - Sola kaydırarak silme (Undo özellikli)
/// - Basılı tutarak sıfırlama (Tarihi bugüne çekme)
/// - Tıklayarak düzenleme

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  void _showAddGoalScreen(BuildContext context, {Goal? goal}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddGoalScreen(goalToEdit: goal)),
    );
  }

  Future<void> _onResetGoal(BuildContext context, Goal goal) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetGoal),
        content: Text(l10n.resetGoalConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(goalControllerProvider.notifier).resetGoal(goal);
      if (context.mounted) {
        SnackbarUtils.showStandard(context, message: l10n.goalReset);
      }
    }
  }

  Future<void> _onDeleteGoal(BuildContext context, Goal goal) async {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;

    final notifier = ref.read(goalControllerProvider.notifier);

    // 1. Silme işlemini başlat
    await notifier.deleteGoal(goal.id);

    // 4. Kesin kapanma garantisi (TransactionList ile uyum)
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });

    // 2. Undo SnackBar göster (SnackbarUtils kullanarak)
    if (context.mounted) {
      SnackbarUtils.showStandard(
        context,
        message: l10n.goalDeleted,
        onUndo: () {
          notifier.addGoal(
            title: goal.title,
            targetAmount: goal.targetAmount,
            startDate: goal.startDate,
            type: goal.type,
            categoryIds: goal.categoryIds,
            colorValue: goal.colorValue,
          );
        },
        undoLabel: l10n.undoAction,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(goalsWithProgressProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalScreen(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: AppColors.passive.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.goalsEmptyTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.goalsEmptyMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Dismissible(
                key: Key(goal.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _onDeleteGoal(context, goal),
                child: GoalCard(
                  goal: goal,
                  onTap: () => _showAddGoalScreen(context, goal: goal),
                  onLongPress: () => _onResetGoal(context, goal),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorGeneric(e.toString()))),
      ),
    );
  }
}
