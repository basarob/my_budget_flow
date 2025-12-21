import 'package:cloud_firestore/cloud_firestore.dart';

/// İşlem Tipi (Gelir / Gider)
enum TransactionType { income, expense }

/// Tekil İşlem Modeli
///
/// Gelir veya gider işleminin tüm detaylarını tutar.
class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryName;
  final DateTime date;
  final String? description;
  final bool isRecurring; // Düzenli işlemden mi üretildi?

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.date,
    this.description,
    this.isRecurring = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryName': categoryName,
      'date': Timestamp.fromDate(date),
      'description': description,
      'isRecurring': isRecurring,
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: (map['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      categoryName: map['categoryName'] ?? 'categoryOther',
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
      isRecurring: map['isRecurring'] ?? false,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, type: $type, date: $date)';
  }
}
