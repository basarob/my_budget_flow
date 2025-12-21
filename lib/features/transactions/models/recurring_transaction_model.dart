import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_model.dart';

/// Düzenli (Tekrarlayan) İşlem Modeli
///
/// Belirli aralıklarla (günlük, haftalık, aylık vb.) otomatik oluşturulacak
/// işlemlerin şablonunu temsil eder.
class RecurringTransactionModel {
  final String id;
  final String title;
  final String userId;
  final double amount;
  final TransactionType type; // Gelir veya Gider
  final String categoryName;
  final String frequency; // Sıklık (örn: monthly)
  final DateTime startDate;
  final String description;
  final bool isActive; // Otomatik oluşturma açık mı?
  final DateTime? lastProcessedDate; // En son işlem ne zaman oluşturuldu?

  RecurringTransactionModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.frequency,
    required this.startDate,
    this.description = '',
    this.isActive = true,
    this.lastProcessedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryName': categoryName,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'description': description,
      'isActive': isActive,
      'lastProcessedDate': lastProcessedDate != null
          ? Timestamp.fromDate(lastProcessedDate!)
          : null,
    };
  }

  factory RecurringTransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return RecurringTransactionModel(
      id: documentId,
      title: map['title'] ?? map['categoryName'] ?? 'Düzenli İşlem',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: (map['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      categoryName: map['categoryName'] ?? 'categoryOther',
      frequency: map['frequency'] ?? 'monthly',
      startDate: (map['startDate'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      lastProcessedDate: map['lastProcessedDate'] != null
          ? (map['lastProcessedDate'] as Timestamp).toDate()
          : null,
    );
  }
}
