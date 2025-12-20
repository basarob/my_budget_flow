import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';

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

  // Gelişmiş İşlem Listeleme (Pagination & Filtering)
  // Stream yerine Future kullanıyoruz çünkü infinite scroll manuel tetiklenir.
  // lastDocument: Sayfalamada "nerede kaldık?" bilgisini tutar.
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
    TransactionType? filterType, // Sadece Gelir veya Gider
    String? filterCategoryName, // Sadece 'Market' vb.
    DateTimeRange? filterDateRange, // Tarih Aralığı
  }) async {
    Query query = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true);

    // Filtreleri Uygula
    if (filterType != null) {
      final typeString = filterType == TransactionType.income
          ? 'income'
          : 'expense';
      query = query.where('type', isEqualTo: typeString);
    }

    if (filterCategoryName != null && filterCategoryName.isNotEmpty) {
      query = query.where('categoryName', isEqualTo: filterCategoryName);
    }

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

    // Sayfalama (Pagination)
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(limit);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      // Cast işlemi yaparak Type Safety sağla
      return TransactionModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  // Basit Stream (Takvim ve Dashboard için son işlemleri hızlı görmek adına)
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

  // Takvim İçin Tümünü Getir (Hafif Veri)
  // Not: Büyük veride sadece tarihleri çekmek daha performanslıdır ama şimdilik tümünü çekiyoruz.
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

  // --- DÜZENLİ İŞLEMLER (RECURRING) ---

  Future<void> addRecurringItem(RecurringTransactionModel item) async {
    final collection = _firestore
        .collection('users')
        .doc(item.userId)
        .collection('recurring_items');

    final docRef = collection.doc();
    final data = item.toMap();
    data['id'] = docRef.id;

    await docRef.set(data);
  }

  Future<void> deleteRecurringItem(String userId, String itemId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_items')
        .doc(itemId)
        .delete();
  }

  Stream<List<RecurringTransactionModel>> getRecurringStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recurring_items')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RecurringTransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
