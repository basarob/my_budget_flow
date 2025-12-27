import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';

class PaginatedTransactionResult {
  final List<TransactionModel> items;
  final DocumentSnapshot? lastDocument;

  PaginatedTransactionResult(this.items, this.lastDocument);
}

/// Firestore üzerinde finansal işlemleri (gelir/gider) yöneten sınıf.
///
/// CRUD işlemleri, filtreleme, gerçek zamanlı dinleme ve düzenli işlemlerin
/// (recurring transactions) otomatik işlenmesini sağlar.
class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- İŞLEMLER (TRANSACTIONS) ---

  /// Yeni işlem ekler
  Future<void> addTransaction(TransactionModel transaction) async {
    final collection = _firestore
        .collection('users')
        .doc(transaction.userId)
        .collection('transactions');

    final docRef = collection.doc();
    final data = transaction.toMap();
    data['id'] = docRef.id;

    await docRef.set(data);
  }

  /// İşlem siler
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  /// Kategorisi silinen işlemlerin kategori adını günceller.
  /// Örn: "Eğlence" kategorisi silinirse, işlemler "Diğer" kategorisine geçer.
  Future<void> updateCategoryForAllTransactions(
    String userId,
    String oldCategoryName,
    String newCategoryName,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('categoryName', isEqualTo: oldCategoryName)
        .get();

    // Batch işlemi ile toplu güncelleme (Performans için)
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'categoryName': newCategoryName});
    }
    await batch.commit();
  }

  /// Gelişmiş İşlem Listeleme (Sayfalama ve Filtreleme)
  ///
  /// Firestore'un sorgu yeteneklerini ve yerel (client-side) filtrelemeyi
  /// birleştirerek optimum sonuç sağlar.
  Future<PaginatedTransactionResult> getTransactions({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
    TransactionType? filterType,
    List<String>? filterCategories,
    DateTimeRange? filterDateRange,
    String? searchQuery,
  }) async {
    // Strateji: Firestore Composite Index yükünden kaçınmak için
    // Temel sorguyu her zaman TARİH sıralı yaparız.
    // Tip, Kategori gibi filtreleri bellek içinde (client-side) uygularız.

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true);

    // Tarih Aralığı Filtresi (Firestore'da uygulanabilir)
    if (filterDateRange != null) {
      query = query
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(filterDateRange.start),
          )
          .where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(filterDateRange.end),
          );
    }

    // Client-side filtreleme yapılacaksa, veritabanından daha fazla veri çekmeliyiz
    // ki filtreledikten sonra elimizde yeterli veri kalsın.
    bool hasClientSideFilter =
        (searchQuery != null && searchQuery.isNotEmpty) ||
        (filterCategories != null && filterCategories.isNotEmpty) ||
        (filterType != null);

    // Filtre varsa limiti artırıyoruz (Okuma maliyetini göze alarak)
    int fetchLimit = hasClientSideFilter ? 500 : limit;

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    query = query.limit(fetchLimit);

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      return PaginatedTransactionResult([], null);
    }

    // Map ve Dönüşüm
    var transactions = snapshot.docs.map((doc) {
      return TransactionModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    // --- Client-Side Filtreleme ---

    // 1. İşlem Tipi
    if (filterType != null) {
      transactions = transactions.where((t) => t.type == filterType).toList();
    }

    // 2. Kategori (Çoklu Seçim)
    if (filterCategories != null && filterCategories.isNotEmpty) {
      transactions = transactions
          .where((t) => filterCategories.contains(t.categoryName))
          .toList();
    }

    // 3. Arama Sorgusu (Başlık veya Açıklama içinde)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      transactions = transactions.where((t) {
        return t.title.toLowerCase().contains(queryLower) ||
            (t.description?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    }

    // Sayfalama Notu: İstemci tarafı (client-side) filtreleme sebebiyle, dönen liste
    // istenen limitten (20) az olabilir. Bu normaldir.
    // Sayfalama için veritabanındaki son dökümanı referans almalıyız.

    return PaginatedTransactionResult(transactions, snapshot.docs.last);
  }

  /// Son İşlemler Akışı (Dashboard için)
  Stream<List<TransactionModel>> getRecentTransactionsStream(
    String userId, {
    int limit = 5,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Belirli bir ay için işlemleri getirir (Takvim ekranı için)
  Future<List<TransactionModel>> getTransactionsForMonth(
    String userId,
    DateTime month,
  ) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- DÜZENLİ İŞLEMLER (RECURRING) ---

  /// Yeni düzenli işlem tanımı ekler
  Future<void> addRecurringItem(RecurringTransactionModel item) async {
    final batch = _firestore.batch();

    // 1. Düzenli İşlem Dosyasını Oluştur
    final recurringRef = _firestore
        .collection('users')
        .doc(item.userId)
        .collection('recurring_transactions')
        .doc();

    final newItemId = recurringRef.id;
    final now = DateTime.now();
    DateTime? processedDate;

    // 2. Eğer lastProcessedDate zaten varsa (Undo işlemi), onu kullan ve işlem oluşturma.
    // Yoksa (Yeni işlem), başlangıç tarihi kontrolü yap.
    if (item.lastProcessedDate != null) {
      processedDate = item.lastProcessedDate;
    } else {
      final isTodayOrPast =
          item.startDate.isBefore(now) ||
          (item.startDate.year == now.year &&
              item.startDate.month == now.month &&
              item.startDate.day == now.day);

      if (isTodayOrPast && item.isActive) {
        final txRef = _firestore
            .collection('users')
            .doc(item.userId)
            .collection('transactions')
            .doc();

        final newTransaction = TransactionModel(
          id: txRef.id,
          userId: item.userId,
          title: item.title,
          amount: item.amount,
          type: item.type,
          categoryName: item.categoryName,
          date: item.startDate,
          description: item.description.isNotEmpty
              ? '${item.description} (Otomatik) '
              : '(Otomatik)',
          isRecurring: true,
        );

        batch.set(txRef, newTransaction.toMap());
        processedDate = item.startDate; // İşlendi olarak işaretle
      }
    }

    // 3. Düzenli İşlem Kaydını Hazırla
    final newItem = RecurringTransactionModel(
      id: newItemId,
      title: item.title,
      userId: item.userId,
      amount: item.amount,
      type: item.type,
      categoryName: item.categoryName,
      frequency: item.frequency,
      startDate: item.startDate,
      description: item.description,
      isActive: item.isActive,
      lastProcessedDate: processedDate,
    );

    batch.set(recurringRef, newItem.toMap());
    await batch.commit();
  }

  /// Düzenli işlemi günceller.
  /// Eğer işlem aktife çekiliyorsa, vadesi gelen işlemleri de oluşturur.
  Future<void> updateRecurringItem(
    RecurringTransactionModel item, {
    bool wasActivated = false,
  }) async {
    final batch = _firestore.batch();
    bool batchHasChanges = false;

    final docRef = _firestore
        .collection('users')
        .doc(item.userId)
        .collection('recurring_transactions')
        .doc(item.id);

    batch.update(docRef, item.toMap());
    batchHasChanges = true;

    // Eğer pasiften aktife çekildiyse ve vadesi gelmişse işlem oluştur
    if (wasActivated && item.isActive) {
      final now = DateTime.now();

      // Başlangıç tarihi gelmediyse atla
      if (!item.startDate.isAfter(now)) {
        DateTime lastRun = item.lastProcessedDate ?? item.startDate;

        DateTime nextDue;
        if (item.lastProcessedDate == null) {
          nextDue = item.startDate;
        } else {
          nextDue = RecurringTransactionModel.calculateNextDueDate(
            lastRun,
            item.frequency,
          );
        }

        int safetyCounter = 0;
        DateTime? lastCreatedDate;

        while (nextDue.isBefore(now) || isSameDay(nextDue, now)) {
          if (safetyCounter++ > 12) break;

          final newTxRef = _firestore
              .collection('users')
              .doc(item.userId)
              .collection('transactions')
              .doc();

          final newTransaction = TransactionModel(
            id: newTxRef.id,
            userId: item.userId,
            title: item.title.isNotEmpty ? item.title : item.categoryName,
            amount: item.amount,
            type: item.type,
            categoryName: item.categoryName,
            date: nextDue,
            description: item.description.isNotEmpty
                ? '${item.description} (Otomatik)'
                : '(Otomatik)',
            isRecurring: true,
          );
          batch.set(newTxRef, newTransaction.toMap());

          lastCreatedDate = nextDue;
          lastRun = nextDue;
          nextDue = RecurringTransactionModel.calculateNextDueDate(
            lastRun,
            item.frequency,
          );

          if (nextDue.isAfter(now) && !isSameDay(nextDue, now)) break;
        }

        // lastProcessedDate'i güncelle
        if (lastCreatedDate != null) {
          batch.update(docRef, {
            'lastProcessedDate': Timestamp.fromDate(lastCreatedDate),
          });
        }
      }
    }

    if (batchHasChanges) {
      await batch.commit();
    }
  }

  Future<void> deleteRecurringItem(String userId, String itemId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_transactions')
        .doc(itemId)
        .delete();
  }

  Future<void> updateCategoryForAllRecurringTransactions(
    String userId,
    String oldCategoryName,
    String newCategoryName,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_transactions')
        .where('categoryName', isEqualTo: oldCategoryName)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'categoryName': newCategoryName});
    }
    await batch.commit();
  }

  Stream<List<RecurringTransactionModel>> getRecurringStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_transactions')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RecurringTransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// Aktif düzenli işlemleri getirir (Takvim tahminleri için)
  Future<List<RecurringTransactionModel>> getActiveRecurringTransactions(
    String userId,
  ) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_transactions')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => RecurringTransactionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- OTOMATİK İŞLEM OLUŞTURMA MOTORU ---

  /// Zamanı gelen düzenli işlemleri kontrol eder ve oluşturur.
  Future<void> checkAndProcessRecurringTransactions(String userId) async {
    final now = DateTime.now();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_transactions')
        .where('isActive', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    bool batchHasChanges = false;

    for (var doc in snapshot.docs) {
      final item = RecurringTransactionModel.fromMap(doc.data(), doc.id);

      // En son işlem tarihini al.
      // Eğer daha önce işlenmemişse (null), startDate referans alınır.
      DateTime lastRun = item.lastProcessedDate ?? item.startDate;

      // Henüz başlangıç tarihi gelmediyse atla
      if (item.startDate.isAfter(now)) continue;

      DateTime nextDue;
      if (item.lastProcessedDate == null) {
        // İlk kez çalışacaksa, direkt başlangıç tarihi vadesidir.
        nextDue = item.startDate;
      } else {
        // Daha önce çalışmışsa, son işlem tarihinden sonrasını hesapla.
        nextDue = RecurringTransactionModel.calculateNextDueDate(
          lastRun,
          item.frequency,
        );
      }

      // Güvenlik Sayacı (Sonsuz döngüyü önlemek için)
      int safetyCounter = 0;

      // Eğer bir sonraki işlem tarihi bugün veya geçmişte ise, işlemi oluştur
      while (nextDue.isBefore(now) || isSameDay(nextDue, now)) {
        if (safetyCounter++ > 12) {
          debugPrint("Güvenlik sınırı aşıldı: ID ${item.id}");
          break;
        }

        // Yeni İşlemi Oluştur
        final newTxRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc();

        final newTransaction = TransactionModel(
          id: newTxRef.id,
          userId: userId,
          title: item.title.isNotEmpty ? item.title : item.categoryName,
          amount: item.amount,
          type: item.type,
          categoryName: item.categoryName,
          date: nextDue,
          description: item.description.isNotEmpty
              ? '${item.description} (Otomatik)'
              : '(Otomatik)',
          isRecurring: true,
        );
        batch.set(newTxRef, newTransaction.toMap());

        // Düzenli işlem kaydını güncelle
        final itemRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('recurring_transactions')
            .doc(item.id);

        batch.update(itemRef, {
          'lastProcessedDate': Timestamp.fromDate(nextDue),
        });

        // Döngü için güncelle
        lastRun = nextDue;
        nextDue = RecurringTransactionModel.calculateNextDueDate(
          lastRun,
          item.frequency,
        );
        batchHasChanges = true;

        // Eğer sonraki tarih geleceğe geçtiyse döngüden çık
        if (nextDue.isAfter(now) && !isSameDay(nextDue, now)) break;
      }
    }

    if (batchHasChanges) {
      await batch.commit();
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
