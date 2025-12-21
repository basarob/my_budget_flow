import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';

class PaginatedTransactionResult {
  final List<TransactionModel> items;
  final DocumentSnapshot? lastDocument;

  PaginatedTransactionResult(this.items, this.lastDocument);
}

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- İŞLEMLER (TRANSACTIONS) ---

  // İşlem Ekleme
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

  // İşlem Silme
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // Kategorisi silinen işlemleri güncelle
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

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'categoryName': newCategoryName});
    }
    await batch.commit();
  }

  // --- İŞLEMLER (TRANSACTIONS) ---

  // Gelişmiş İşlem Listeleme (Pagination & Filtering)
  Future<PaginatedTransactionResult> getTransactions({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
    TransactionType? filterType,
    List<String>? filterCategories, // Çoklu Kategori
    DateTimeRange? filterDateRange, // Tarih Aralığı
    String? searchQuery, // Arama Sorgusu
  }) async {
    // Firestore İndeks Sorununu Aşmak İçin Tam Optimizasyon
    // Eğer hem Tip hem Tarih filtresi varsa composite index gerekir.
    // Kullanıcıya indeks oluşturma yükü bindirmemek için:
    // 1. Sorguyu her zaman TARİH veya DEFAULT (tarih sıralı) yapıyoruz.
    // 2. Tip filtresini tamamen CLIENT-SIDE (bellek içi) yapıyoruz.

    // NOT: Client-side filtreleme varsa, sayfalama bozulabilir.
    // Çünkü 20 veri çekip 18'ini elersek kullanıcıya 2 veri gider.
    // Bu durumda "limit" kavramı "işlenen döküman sayısı" olur.
    // Eğer filtreler çok katıysa sonsuz döngüye girmemek için "limit"i artırıyoruz.

    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy(
          'date',
          descending: true,
        ); // Her zaman tarihe göre sıralı çekelim

    // Tarih filtresi varsa ekle (Date range + orderBy date sorun çıkarmaz)
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

    // Eğer client-side filtreleme yapılacaksa, veritabanından daha fazla veri çekmeliyiz
    // ki filtre sonrası elde anlamlı sayıda veri kalsın.
    bool hasClientSideFilter =
        (searchQuery != null && searchQuery.isNotEmpty) ||
        (filterCategories != null && filterCategories.isNotEmpty) ||
        (filterType != null);

    // Client-side filtre varsa limiti artır (Verimlilik için 100 diyelim, 500 fazla olabilir)
    // Ama kullanıcı "en verimli" dedi, 500 iyidir, az read yapar.
    int fetchLimit = hasClientSideFilter ? 500 : limit;

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    query = query.limit(fetchLimit);

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      return PaginatedTransactionResult([], null);
    }

    var transactions = snapshot.docs.map((doc) {
      return TransactionModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    // Client-Side Filtreleme (Memory)
    if (filterType != null) {
      transactions = transactions.where((t) => t.type == filterType).toList();
    }
    if (filterCategories != null && filterCategories.isNotEmpty) {
      transactions = transactions
          .where((t) => filterCategories.contains(t.categoryName))
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      transactions = transactions.where((t) {
        return t.title.toLowerCase().contains(queryLower) ||
            (t.description?.toLowerCase().contains(queryLower) ?? false);
      }).toList();
    }

    // Eğer client-side filtreleme sonucu elimizde istenen limit'ten (örn 20) fazla veri varsa
    // fazlasını kesebiliriz ama sonsuz kaydırmada kullanıcıya hepsini göstermek daha iyi.
    // Ancak, sonraki sayfa için "lastDocument" belirlememiz lazım.
    // Sorun: Filtreleme sonucu son döküman, çektiğimiz snapshot'ın son dökümanı olmayabilir.
    // Ama pagination sorgusu veritabanındaki sıraya göre çalışır.
    // Bu yüzden pagination için snapshot.docs.last kullanılmalıdır, filtrelenmiş listenin sonuncusu DEĞİL.

    return PaginatedTransactionResult(transactions, snapshot.docs.last);
  }

  // Basit Stream (Takvim ve Dashboard için)
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

  Stream<List<TransactionModel>> getAllTransactionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // --- RECURRING TRANSACTIONS (DÜZENLİ ÖDEMELER) MANUELLER ---

  Future<void> addRecurringItem(RecurringTransactionModel item) async {
    final batch = _firestore.batch();

    // 1. Düzenli İşlemi Oluştur
    final recurringRef = _firestore
        .collection('users')
        .doc(item.userId)
        .collection('recurring_transactions')
        .doc(); // Auto-ID

    final newItemId = recurringRef.id;

    // 2. Bugün (veya geçmiş) ise hemen ilk işlemi de ekle
    final now = DateTime.now();
    DateTime? processedDate;

    // Sadece saat/dakika farkını yoksaymak için gün bazlı karşılaştırma
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
        date: item.startDate, // Başlangıç tarihi işlemin tarihi olur
        description: '${item.description} (Otomatik: ${item.frequency})',
        isRecurring: true,
      );

      batch.set(txRef, newTransaction.toMap());
      processedDate = item.startDate; // Bu tarihi işledik
    }

    // 3. Düzenli işlem verisini hazırla
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
      lastProcessedDate:
          processedDate, // Eğer işlem oluşturduysak buraya tarihi yaz
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

  // Kategorisi silinen düzenli işlemleri güncelle
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

  // --- AUTOMATIC PROCESSING MAGIC ---
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

      // En son ne zaman işlem yapıldı? (Yoksa başlangıç tarihinden hemen öncesi kabul et ki ilkini yapsın)
      // Ancak "lastProcessedDate" null ise ve "startDate" gelecekteyse işlem yapma.
      // Eğer "lastProcessedDate" null ve "startDate" geçmişte veya bugünse, işlem yapmalıyız.

      DateTime lastRun =
          item.lastProcessedDate ??
          item.startDate.subtract(const Duration(days: 1));

      // Başlangıç tarihi bugünden büyükse (gelecekse) henüz başlama.
      if (item.startDate.isAfter(now)) continue;

      // Sıklığa göre bir sonraki tarihi hesapla
      DateTime nextDue = _calculateNextDueDate(lastRun, item.frequency);

      // Eğer nextDue bugün veya daha önce ise, işlemi oluştur.
      // Döngü ile birden fazla kaçırılmış işlem varsa hepsini ekle (Opsiyonel: Sadece sonuncuyu ekle)
      // Burada sadece "bugün gelmiş veya geçmiş ama işlenmemiş" olan TEK bir işlemi ekleyelim.
      // Ya da lastProcessedDate'i sürekli ileri atarak kaçanları da ekleyebiliriz.
      // Kullanıcı deneyimi için: Çok eski tarihliyse (örn 1 yıl) hepsini eklemek spam olabilir.
      // Şimdilik: while döngüsü ile kaçanları ekleyelim ama bir limit koyalım.

      // Güvenlik limiti: Sonsuz döngüden kaçın (örn. 12 işlemden fazla ekleme)
      int safetyCounter = 0;
      while (nextDue.isBefore(now) || isSameDay(nextDue, now)) {
        if (safetyCounter++ > 12) {
          debugPrint(
            "Recurring transaction safety break hit for item: ${item.id}",
          );
          break;
        }

        // İşlemi Oluştur (Normal işlemler zaten user subcollection altında)
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

        // Düzenli İşlemi Güncelle: lastProcessedDate = nextDue
        // nextDue artık islendi.
        final itemRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('recurring_transactions')
            .doc(item.id);

        batch.update(itemRef, {
          'lastProcessedDate': Timestamp.fromDate(nextDue),
        });

        lastRun = nextDue; // Döngü için güncelle
        nextDue = _calculateNextDueDate(lastRun, item.frequency);
        batchHasChanges = true;

        // Güvenlik limiti: Sonsuz döngüden kaçın (örn. 10 işlemden fazla ekleme)
        // ya da nextDue geleceğe geçene kadar devam et.
        if (nextDue.isAfter(now) && !isSameDay(nextDue, now)) break;
      }
    }

    if (batchHasChanges) {
      await batch.commit();
    }
  }

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
        // Doğru ay ekleme mantığı:
        // 31 Ocak + 1 Ay -> 28/29 Şubat (veya Mart'a kaymadan o ayın son günü)
        // DateTime(year, month + 1, day) yaparsak Dart otomatik taşır (31 Ocak -> 3 Mart).
        // Bunu engellemek için:
        // 1. Hedef ayı bul (month + 1)
        // 2. Hedef ayın kaç gün çektiğini bul
        // 3. Eğer mevcut gün (day), hedef ayın gün sayısından büyükse, hedef ayın son gününü al.

        final desiredMonth = lastRun.month + 1;
        final desiredYear = lastRun.year + (desiredMonth > 12 ? 1 : 0);
        final normalizedMonth = desiredMonth > 12 ? 1 : desiredMonth;

        // Hedef ayın son gününü bulmak için: (normalizedMonth + 1, gün 0)
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
        // Şubatm 29 sorunu (Artık yıl -> Normal Yıl): 29 Şubat 2024 -> 28 Şubat 2025
        // Dart DateTime(year+1, 2, 29) yaparsa 1 Mart 2025 verir.
        // Genelde 28 Şubat olması istenir veya 1 Mart. Dart 1 Mart yapar.
        // Özel bir kontrol ekleyelim:
        if (lastRun.month == 2 && lastRun.day == 29) {
          // Gelecek yıl artık yıl değilse 28 Şubat olsun
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
        // Fallback for unknown frequency: default to 30 days
        debugPrint('Unknown frequency: $frequency, defaulting to 30 days.');
        return lastRun.add(const Duration(days: 30));
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
