import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../providers/transaction_provider.dart';
import '../../auth/services/auth_service.dart';

/// Dosya: category_provider.dart
///
/// Amaç: Kategori verilerini ve işlemlerini yöneten Riverpod sağlayıcılarını tanımlar.
///
/// Özellikler:
/// - Kategori listesini getirir (varsayılan + özel)
/// - Kategori ekleme ve silme işlemlerini yönetir (CategoryController)
/// - Kategori Repository erişimini sağlar

/// Kategori Repository Sağlayıcısı
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Kategori Listesi Sağlayıcısı
///
/// Varsayılan kategoriler ile kullanıcının eklediği özel kategorileri birleştirerek sunar.
final categoryListProvider = FutureProvider.autoDispose<List<CategoryModel>>((
  ref,
) async {
  final user = ref.watch(authStateChangesProvider).value;
  // Kullanıcı giriş yapmamışsa sadece varsayılanları göster
  if (user == null) {
    return CategoryModel.defaultCategories;
  }

  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories(user.uid);
});

/// Kategori İşlemleri (Ekleme/Silme/Güncelleme) Yöneticisi
class CategoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Başlangıç durumu
  }

  /// Yeni özel kategori ekler
  Future<void> addCategory(String name, int colorValue, int iconCode) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final repository = ref.read(categoryRepositoryProvider);

        final newCategory = CategoryModel(
          id: '', // Repository tarafından atanacak
          name: name,
          iconCode: iconCode,
          colorValue: colorValue,
          isCustom: true,
        );

        await repository.addCustomCategory(user.uid, newCategory);

        // Listeyi yenile
        ref.invalidate(categoryListProvider);

        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Özel kategoriyi siler
  ///
  /// Silinen kategoriye ait işlemler otomatik olarak "Diğer" kategorisine taşınır.
  Future<void> deleteCategory(String categoryId, String categoryName) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        // 1. İlgili işlemleri "Diğer" kategorisine taşı
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

        // 2. Kategoriyi veritabanından sil
        final repository = ref.read(categoryRepositoryProvider);
        await repository.deleteCustomCategory(user.uid, categoryId);

        // 3. İlgili listeleri yenile
        ref.invalidate(categoryListProvider);
        ref.invalidate(paginatedTransactionProvider);
        ref.invalidate(recurringListProvider);

        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Kategori Controller Sağlayıcısı
final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, void>(CategoryController.new);
