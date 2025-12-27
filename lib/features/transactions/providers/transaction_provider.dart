import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_filter_state.dart';

/// İşlem Repository Sağlayıcısı
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// İşlem Listesi Filtreleme Yöneticisi
class TransactionFilterNotifier extends Notifier<TransactionFilterState> {
  @override
  TransactionFilterState build() {
    return const TransactionFilterState();
  }

  void update(TransactionFilterState newState) {
    state = newState;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(TransactionType? type) {
    // Null değer atanabilsin diye yeni nesne oluşturuyoruz
    state = TransactionFilterState(
      type: type,
      selectedCategories: state.selectedCategories,
      dateRange: state.dateRange,
      searchQuery: state.searchQuery,
    );
  }

  void setFilterDateRange(DateTimeRange? range) {
    state = TransactionFilterState(
      type: state.type,
      selectedCategories: state.selectedCategories,
      dateRange: range,
      searchQuery: state.searchQuery,
    );
  }

  void setFilterCategories(List<String>? categories) {
    state = TransactionFilterState(
      type: state.type,
      selectedCategories: categories,
      dateRange: state.dateRange,
      searchQuery: state.searchQuery,
    );
  }

  void clear() {
    state = const TransactionFilterState();
  }
}

/// Filtreleme Durumu Sağlayıcısı
final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilterState>(
      TransactionFilterNotifier.new,
    );

/// Son İşlemler (Dashboard vb. için kısa liste - Stream)
final recentTransactionsProvider = StreamProvider<List<TransactionModel>>((
  ref,
) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();

  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getRecentTransactionsStream(user.uid);
});

/// İşlem Yönetimi (CRUD) Kontrolcüsü
class TransactionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Başlangıçta düzenli (otomatik) işlemleri kontrol et
    final user = ref.watch(authStateChangesProvider).value;
    if (user != null) {
      final repository = ref.read(transactionRepositoryProvider);
      // Hata olsa bile UI'ı bölmemesi için catchError kullanıyoruz
      repository.checkAndProcessRecurringTransactions(user.uid).catchError((e) {
        debugPrint('Otomatik işlem hatası: $e');
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

      // Yeni eklenen düzenli işlemin günü bugünse hemen işlenmesi için tetikle
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

  Future<void> updateRecurringItem(
    RecurringTransactionModel item, {
    bool wasActivated = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.updateRecurringItem(item, wasActivated: wasActivated);

      // Aktifleştirme sonrası işlem listesini yenile
      if (wasActivated) {
        ref.invalidate(paginatedTransactionProvider);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// CRUD Kontrolcüsü Sağlayıcısı
final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, void>(
      TransactionController.new,
    );

/// Düzenli İşlemler Listesi (Stream)
final recurringListProvider = StreamProvider<List<RecurringTransactionModel>>((
  ref,
) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getRecurringStream(user.uid).map((items) {
    // Tarihi en yakın olan (nextDueDate) en üstte görünsün
    final sortedItems = List<RecurringTransactionModel>.from(items);
    sortedItems.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return sortedItems;
  });
});

/// Sayfalı (Pagination) İşlem Listesi Yöneticisi
class TransactionPaginationNotifier
    extends AsyncNotifier<List<TransactionModel>> {
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  Future<List<TransactionModel>> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    final filter = ref.watch(transactionFilterProvider);

    // Filtre veya kullanıcı değiştiğinde sayfalamayı sıfırla
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

  /// Daha fazla veri yükle (Infinite Scroll)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
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
      debugPrint('Daha fazla yükleme hatası: $e');
      // Hata durumunda mevcut listeyi koru
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Listeden eleman sil (Optimistik güncelleme için)
  void removeItem(String transactionId) {
    if (!state.hasValue) return;
    final currentList = state.value!;
    final updatedList = currentList
        .where((t) => t.id != transactionId)
        .toList();
    state = AsyncValue.data(updatedList);
  }
}

/// Sayfalı Liste Sağlayıcısı
final paginatedTransactionProvider =
    AsyncNotifierProvider<
      TransactionPaginationNotifier,
      List<TransactionModel>
    >(TransactionPaginationNotifier.new);
