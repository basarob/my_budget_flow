import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/services/auth_service.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_filter_state.dart';
import 'package:flutter/material.dart';

// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// Filtreleme State Notifier'ı
class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() {
    return const TransactionFilterState();
  }

  void update(TransactionFilterState newState) {
    state = newState;
  }

  void setSearchQuery(String query) {
    // String is non-nullable in method signature, so it's safe to update
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(TransactionType? type) {
    // Manual copy to allow setting null
    state = TransactionFilterState(
      type: type, // Can be null, and we want to set it to null if passed
      selectedCategories: state.selectedCategories,
      dateRange: state.dateRange,
      searchQuery: state.searchQuery,
    );
  }

  void setFilterDateRange(DateTimeRange? range) {
    // Manual copy to allow setting null
    state = TransactionFilterState(
      type: state.type,
      selectedCategories: state.selectedCategories,
      dateRange: range, // Can be null
      searchQuery: state.searchQuery,
    );
  }

  void setFilterCategories(List<String>? categories) {
    // Manual copy to allow setting null
    state = TransactionFilterState(
      type: state.type,
      selectedCategories: categories, // Can be null
      dateRange: state.dateRange,
      searchQuery: state.searchQuery,
    );
  }

  void clear() {
    state = const TransactionFilterState();
  }
}

// Filtreleme Provider
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
      TransactionFilterNotifier.new,
    );

// Recent Transactions
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
  Future<void> build() async {
    // Controller başlatıldığında otomatik işlemleri kontrol et
    final user = ref.watch(authStateChangesProvider).value;
    if (user != null) {
      final repository = ref.read(transactionRepositoryProvider);
      // Arka planda çalışsın, UI'ı bloklamasın, await etmeye gerek yok ama hata yakalamak iyi olur
      repository.checkAndProcessRecurringTransactions(user.uid).catchError((e) {
        debugPrint('Auto-process error: $e');
      });
    }
  }

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
      // Eklendiği anda (eğer bugünse) hemen bir kopya transaction oluşturulması gerekebilir
      // Ancak repository içindeki 'checkAndProcess' metodu bunu zaten halleder.
      // Sadece tetiklemek lazım:
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        await repository.checkAndProcessRecurringTransactions(user.uid);
      }
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

  Future<void> updateRecurringItem(RecurringTransactionModel item) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateRecurringItem(item);

      // Eğer pasiften aktife çekildiyse kontrol et
      if (item.isActive) {
        final user = ref.read(authStateChangesProvider).value;
        if (user != null) {
          await repository.checkAndProcessRecurringTransactions(user.uid);
        }
      }

      state = const AsyncValue.data(null);
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

// --- PAGINATED LIST NOTIFIER (Infinite Scroll) ---

class TransactionPaginationNotifier
    extends AsyncNotifier<List<TransactionModel>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<TransactionModel>> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    final filter = ref.watch(transactionFilterProvider);

    // Reset pagination state when dependencies change (filter/user)
    _lastDocument = null;
    _hasMore = true;
    _isLoadingMore = false;

    if (user == null) {
      return [];
    }

    final repository = ref.read(transactionRepositoryProvider);
    final result = await repository.getTransactions(
      userId: user.uid,
      limit: 20,
      filterType: filter.type,
      filterCategories: filter.selectedCategories,
      filterDateRange: filter.dateRange,
      searchQuery: filter.searchQuery,
    );

    _lastDocument = result.lastDocument;
    if (result.items.isEmpty) {
      _hasMore = false;
    }

    return result.items;
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    // Ensure we have current data and user
    if (!state.hasValue) return;
    final currentList = state.value!;

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final filter = ref.read(transactionFilterProvider);

    _isLoadingMore = true;

    try {
      final repository = ref.read(transactionRepositoryProvider);
      final result = await repository.getTransactions(
        userId: user.uid,
        lastDocument: _lastDocument,
        limit: 20,
        filterType: filter.type,
        filterCategories: filter.selectedCategories,
        filterDateRange: filter.dateRange,
        searchQuery: filter.searchQuery,
      );

      if (result.items.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = result.lastDocument;
        state = AsyncValue.data([...currentList, ...result.items]);
      }
    } catch (e) {
      debugPrint('LoadMore Error: $e');
      // We don't change state to error to avoid clearing the list on load more failure
    } finally {
      _isLoadingMore = false;
    }
  }

  void removeItem(String transactionId) {
    if (!state.hasValue) return;
    final currentList = state.value!;
    final updatedList = currentList
        .where((t) => t.id != transactionId)
        .toList();
    state = AsyncValue.data(updatedList);
  }
}

final paginatedTransactionProvider =
    AsyncNotifierProvider<
      TransactionPaginationNotifier,
      List<TransactionModel>
    >(TransactionPaginationNotifier.new);
