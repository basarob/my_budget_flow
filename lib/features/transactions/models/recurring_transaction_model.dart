// Düzenli (Tekrarlayan) İşlem Modeli
// Örn: Kira, Netflix, Maaş gibi her ay belli bir günde tekrarlanan işlemler.

import 'transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// enum TransactionType { income, expense } // transaction_model.dart dosyasindan geliyor

class RecurringTransactionModel {
  final String id; // Firestore ID
  final String userId;
  final double amount;
  final TransactionType type; // Gelir/Gider
  final String categoryName;
  final String frequency; // Günlük, Haftalık, Aylık, Yıllık
  final DateTime startDate;
  final String description;
  final bool isActive; // Otomatik ekleme aktif mi?

  RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.frequency,
    required this.startDate,
    this.description = '',
    this.isActive = true,
  });

  // Firestore'a yazmak için Map çevirici
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryName': categoryName,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'description': description,
      'isActive': isActive,
    };
  }

  // Firestore'dan okumak için Factory kurucu
  factory RecurringTransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return RecurringTransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: (map['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      categoryName: map['categoryName'] ?? 'Diğer',
      frequency: map['frequency'] ?? 'Aylık',
      startDate: (map['startDate'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}
