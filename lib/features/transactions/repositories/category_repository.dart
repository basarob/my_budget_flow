import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Kullanıcıya ait tüm kategorileri getirir.
  /// Varsayılan kategoriler ve kullanıcının eklediği özel kategoriler dahildir.
  Future<List<CategoryModel>> getCategories(String userId) async {
    // 1. Varsayılanları kopyala
    List<CategoryModel> allCategories = [...CategoryModel.defaultCategories];

    // 2. Kullanıcının özel kategorilerini çek
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      final customCategories = snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data());
      }).toList();

      allCategories.addAll(customCategories);
    } catch (e) {
      // Hata durumunda en azından varsayılanları döndür
      print("Kategori getirme hatası: $e");
    }

    return allCategories;
  }

  /// Yeni özel kategori ekler
  Future<void> addCustomCategory(String userId, CategoryModel category) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(); // Otomatik ID oluştur

    // ID'yi ata ve kaydet
    final newCategory = CategoryModel(
      id: docRef.id,
      name: category.name,
      iconCode: category.iconCode,
      colorValue: category.colorValue,
      isCustom: true,
    );

    await docRef.set(newCategory.toMap());
  }

  /// Özel kategoriyi siler
  Future<void> deleteCustomCategory(String userId, String categoryId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }
}
