import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_filter_state.dart';

// ... (Existing code) ...

// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Filtreleme State Notifier'ı (StateProvider yerine)
class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() {
    return const TransactionFilterState();
  }

  void update(TransactionFilterState newState) {
    state = newState;
  }

  void clear() {
    state = const TransactionFilterState();
  }
}

// Filtreleme Provider (NotifierProvider)
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
      TransactionFilterNotifier.new,
    );

// Recent Transactions (Dashboard için Özet - Stream)
final recentTransactionsProvider = StreamProvider<List<TransactionModel>>((
  ref,
) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();

  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getRecentTransactionsStream(user.uid);
});

// --- TRANSACTION CONTROLLER (CRUD) ---

class TransactionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.addTransaction(transaction);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final repository = ref.read(transactionRepositoryProvider);
        await repository.deleteTransaction(user.uid, transactionId);
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addRecurringItem(RecurringTransactionModel item) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.addRecurringItem(item);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteRecurringItem(String itemId) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final repository = ref.read(transactionRepositoryProvider);
        await repository.deleteRecurringItem(user.uid, itemId);
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, void>(() {
      return TransactionController();
    });

// Recurring List Stream
final recurringListProvider = StreamProvider<List<RecurringTransactionModel>>((
  ref,
) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getRecurringStream(user.uid);
});

// --- PAGINATED LIST LOGIC ---
// Pagination ve Filtering işlemleri biraz daha kompleks olduğu için
// bunu UI tarafında FutureBuilder veya bir StateNotifier ile yönetmek
// infinite scroll için daha pratiktir.
// Ancak temel bir "Filtreli Liste" provider'ı da sunalım (Pagination olmadan, ilk sayfa için).

final filteredTransactionListProvider =
    FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
      final user = ref.watch(authStateChangesProvider).value;
      if (user == null) return [];

      final filter = ref.watch(transactionFilterProvider);
      final repository = ref.watch(transactionRepositoryProvider);

      // Güvenlik Kontrolü: 6 Aydan uzun sorgulara izin verme
      if (filter.dateRange != null) {
        if (filter.dateRange!.duration.inDays > 185) {
          // ~6 Ay
          // UI tarafında bu hatayı yakalayıp kullanıcıya SnackBar ile göster
          throw Exception('Performans için tarih aralığı 6 ayı geçemez.');
        }
      }

      return repository.getTransactions(
        userId: user.uid,
        limit: 20, // İlk sayfa limiti
        filterType: filter.type,
        filterCategoryName: filter.categoryName,
        filterDateRange: filter.dateRange,
      );
    });
