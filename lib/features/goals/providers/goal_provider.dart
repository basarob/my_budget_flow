import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';

/// Dosya: goal_provider.dart
///
/// Amaç: Hedefler (Goals) özelliği için state management.
///
/// Özellikler:
/// - [goalsWithProgressProvider]: Hedefleri ve ilişkili işlemlerden hesaplanan ilerlemeyi sunar.
/// - [goalControllerProvider]: Ekleme/Silme/Güncelleme/Sıfırlama işlemlerini yönetir.

// 1. Repository Sağlayıcısı
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

// 2. Stream Sağlayıcısı (Hedefleri Listeleme) - Firestore'dan Ham Veri Akışı
final baseGoalsProvider = StreamProvider<List<Goal>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();

  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoalsStream(user.uid);
});

// 3. Hesaplanmış Sağlayıcı (Hedefler + İlerleme)
final goalsWithProgressProvider = Provider<AsyncValue<List<Goal>>>((ref) {
  final goalsAsync = ref.watch(baseGoalsProvider);

  return goalsAsync.when(
    data: (goals) {
      if (goals.isEmpty) return const AsyncValue.data([]);

      // Hedeflerin ilerlemesini hesaplamak için işlemleri al
      final txStream = ref.watch(allTransactionsStreamProvider);

      return txStream.when(
        data: (transactions) {
          return AsyncValue.data(
            goals.map((goal) {
              double collected = 0.0;
              for (final tx in transactions) {
                // 1. Tarih Kontrolü
                if (tx.date.isBefore(goal.startDate)) continue;

                // 2. Kategori Kontrolü
                // TransactionModel'de categoryName tutuluyor.
                if (!goal.categoryIds.contains(tx.categoryName)) continue;

                // 3. Tip Kontrolü: Sadece 'expense' (Harcama) tipli işlemler hesaba katılır.
                // Birikim hedefi için: "Yatırım" kategorisindeki harcamalar (investment expense).
                if (tx.type == TransactionType.expense) {
                  collected += tx.amount;
                }
              }
              return goal.copyWith(collectedAmount: collected);
            }).toList(),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Helper Provider for Transactions Stream
final allTransactionsStreamProvider = StreamProvider<List<TransactionModel>>((
  ref,
) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref
      .watch(transactionRepositoryProvider)
      .getTransactionsStream(userId: user.uid, limit: 2000);
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
    required DateTime startDate,
    required GoalType type,
    required List<String> categoryIds,
    required int colorValue,
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
        startDate: startDate,
        type: type,
        categoryIds: categoryIds,
        colorValue: colorValue,
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

  /// Hedefi sıfırlar (Başlangıç tarihini bugüne çeker)
  Future<void> resetGoal(Goal goal) async {
    // Bugünün başlangıcı (00:00:00) yerine şu anı kullanabiliriz
    // veya gün bazlı tam kontrol istersek startOfDay.
    // Şimdilik DateTime.now() yeterli.
    final updatedGoal = goal.copyWith(startDate: DateTime.now());
    await updateGoal(updatedGoal);
  }
}
