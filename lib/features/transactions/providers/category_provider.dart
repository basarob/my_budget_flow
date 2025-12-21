import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../providers/transaction_provider.dart'; // TransactionRepository erişimi için
import '../../auth/services/auth_service.dart';

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// Kategorileri Listeleme Provider'ı (FutureProvider)
// Varsayılan + Özel kategorileri getirir.
final categoryListProvider = FutureProvider.autoDispose<List<CategoryModel>>((
  ref,
) async {
  final user = ref.watch(authStateChangesProvider).value;
  // Eğer kullanıcı giriş yapmamışsa sadece varsayılanları dön
  if (user == null) {
    return CategoryModel.defaultCategories;
  }

  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories(user.uid);
});

// Kategori Ekleme Controller'ı
class CategoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state is void
  }

  Future<void> addCategory(String name, int colorValue, int iconCode) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final repository = ref.read(categoryRepositoryProvider);

        final newCategory = CategoryModel(
          id: '', // Repository halledecek
          name: name,
          iconCode: iconCode,
          colorValue: colorValue,
          isCustom: true,
        );

        await repository.addCustomCategory(user.uid, newCategory);

        // Listeyi yenile ki UI güncellensin
        ref.invalidate(categoryListProvider);

        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCategory(String categoryId, String categoryName) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        // 1. İşlemleri güncelle (categoryOther'a taşı)
        final transactionRepo = ref.read(transactionRepositoryProvider);
        await transactionRepo.updateCategoryForAllTransactions(
          user.uid,
          categoryName,
          'categoryOther',
        );
        await transactionRepo.updateCategoryForAllRecurringTransactions(
          user.uid,
          categoryName,
          'categoryOther',
        );

        // 2. Kategoriyi sil
        final repository = ref.read(categoryRepositoryProvider);
        await repository.deleteCustomCategory(user.uid, categoryId);

        // 3. Listeleri yenile
        ref.invalidate(categoryListProvider);
        // İşlemlerin de yenilenmesi lazım çünkü kategori değişti
        ref.invalidate(paginatedTransactionProvider);
        ref.invalidate(recurringListProvider);

        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, void>(CategoryController.new);
