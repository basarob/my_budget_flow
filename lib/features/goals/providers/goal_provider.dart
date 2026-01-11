import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';

/// Dosya: goal_provider.dart
///
/// Amaç: Hedefler (Goals) özelliği için state management.
///
/// Sağlayıcılar:
/// - `goalRepositoryProvider`: Repository erişimi
/// - `goalsProvider`: Hedef listesini dinleyen StreamProvider
/// - `goalControllerProvider`: Ekleme/Silme işlemleri için AsyncNotifier

// 1. Repository Provider
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

// 2. Stream Provider (Hedefleri Listeleme)
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();

  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoalsStream(user.uid);
});

// 3. Controller Provider (İşlem Yönetimi)
final goalControllerProvider = AsyncNotifierProvider<GoalController, void>(
  GoalController.new,
);

class GoalController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Başlangıçta boş state
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required int iconCode,
    required int colorValue,
    DateTime? deadline,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalRepositoryProvider);
      final newGoal = Goal(
        id: '', // Repository'de atanacak
        userId: user.uid,
        title: title,
        targetAmount: targetAmount,
        iconCode: iconCode,
        colorValue: colorValue,
        deadline: deadline,
      );
      await repository.addGoal(newGoal);
    });
  }

  Future<void> updateGoal(Goal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalRepositoryProvider);
      await repository.updateGoal(goal);
    });
  }

  Future<void> deleteGoal(String goalId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(goalRepositoryProvider);
      await repository.deleteGoal(user.uid, goalId);
    });
  }

  /// Hedefe para ekleme veya çıkarma
  Future<void> updateAmount(Goal goal, double amountToAdd) async {
    double newAmount = goal.currentAmount + amountToAdd;
    if (newAmount < 0) newAmount = 0;

    final updatedGoal = goal.copyWith(currentAmount: newAmount);
    await updateGoal(updatedGoal);
  }
}
