import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../widgets/add_goal_modal.dart';
import '../widgets/goal_card.dart';

/// Dosya: goals_screen.dart
///
/// Amaç: Kullanıcının hedeflerini listelediği ve yönettiği ekran.
///
/// Özellikler:
/// - Hedef Listesi
/// - Yeni Hedef Ekleme
/// - Para Ekleme / Çıkarma Diyaloğu

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  void _showAddGoalModal(BuildContext context, {Goal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGoalModal(goalToEdit: goal),
    );
  }

  void _showAmountDialog(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
    bool isAdding,
  ) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdding ? l10n.addMoneyTitle : l10n.withdrawMoneyTitle),
        content: CustomTextField(
          controller: controller,
          labelText: l10n.amountLabel,
          prefixIcon: isAdding ? Icons.add : Icons.remove,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              final amount =
                  double.tryParse(controller.text.replaceAll(',', '.')) ?? 0.0;
              if (amount > 0) {
                final newAmount = isAdding
                    ? goal.currentAmount + amount
                    : goal.currentAmount - amount;

                final updatedGoal = goal.copyWith(currentAmount: newAmount);
                await ref
                    .read(goalControllerProvider.notifier)
                    .updateGoal(updatedGoal);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Text(isAdding ? l10n.addButton : l10n.saveButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalModal(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.goalsPlaceholder,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return GoalCard(
                goal: goal,
                onTap: () => _showAddGoalModal(context, goal: goal),
                onAddMoney: () => _showAmountDialog(context, ref, goal, true),
                onWithdrawMoney: () =>
                    _showAmountDialog(context, ref, goal, false),
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
