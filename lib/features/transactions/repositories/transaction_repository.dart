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

    // Pagination not: Client-side filtreleme sebebiyle, dönen liste
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
          description: '${item.description} (Otomatik: ${item.frequency})',
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

  Future<void> updateRecurringItem(RecurringTransactionModel item) async {
    await _firestore
        .collection('users')
        .doc(item.userId)
        .collection('recurring_transactions')
        .doc(item.id)
        .update(item.toMap());
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

      // En son işlem tarihini al (Yoksa başlangıcın bir gün öncesini al)
      DateTime lastRun =
          item.lastProcessedDate ??
          item.startDate.subtract(const Duration(days: 1));

      // Henüz başlangıç tarihi gelmediyse atla
      if (item.startDate.isAfter(now)) continue;

      // Sıklığa göre bir sonraki tarihi hesapla
      DateTime nextDue = _calculateNextDueDate(lastRun, item.frequency);

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
          description: '${item.description} (Otomatik: ${item.frequency})',
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
        nextDue = _calculateNextDueDate(lastRun, item.frequency);
        batchHasChanges = true;

        // Eğer sonraki tarih geleceğe geçtiyse döngüden çık
        if (nextDue.isAfter(now) && !isSameDay(nextDue, now)) break;
      }
    }

    if (batchHasChanges) {
      await batch.commit();
    }
  }

  /// Bir sonraki işlem tarihini hesaplar
  DateTime _calculateNextDueDate(DateTime lastRun, String frequency) {
    switch (frequency) {
      case 'daily':
      case 'Günlük':
      case 'Daily':
        return lastRun.add(const Duration(days: 1));
      case 'weekly':
      case 'Haftalık':
      case 'Weekly':
        return lastRun.add(const Duration(days: 7));
      case 'monthly':
      case 'Aylık':
      case 'Monthly':
        // Aylık artış mantığı (31 Ocak -> 28 Şubat gibi durumları yönetir)
        final desiredMonth = lastRun.month + 1;
        final desiredYear = lastRun.year + (desiredMonth > 12 ? 1 : 0);
        final normalizedMonth = desiredMonth > 12 ? 1 : desiredMonth;

        final lastDayOfDesiredMonth = DateTime(
          desiredYear,
          normalizedMonth + 1,
          0,
        ).day;
        final desiredDay = lastRun.day > lastDayOfDesiredMonth
            ? lastDayOfDesiredMonth
            : lastRun.day;

        return DateTime(
          desiredYear,
          normalizedMonth,
          desiredDay,
          lastRun.hour,
          lastRun.minute,
        );

      case 'yearly':
      case 'Yıllık':
      case 'Yearly':
        // Yıllık artış (Artık yıl kontrolü)
        if (lastRun.month == 2 && lastRun.day == 29) {
          final isLeapNext =
              (lastRun.year + 1) % 4 == 0 &&
              ((lastRun.year + 1) % 100 != 0 || (lastRun.year + 1) % 400 == 0);
          if (!isLeapNext) {
            return DateTime(
              lastRun.year + 1,
              2,
              28,
              lastRun.hour,
              lastRun.minute,
            );
          }
        }
        return DateTime(
          lastRun.year + 1,
          lastRun.month,
          lastRun.day,
          lastRun.hour,
          lastRun.minute,
        );
      default:
        debugPrint('Bilinmeyen sıklık: $frequency, 30 gün varsayılıyor.');
        return lastRun.add(const Duration(days: 30));
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
