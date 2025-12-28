import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_model.dart';

/// Dosya: recurring_transaction_model.dart
///
/// Amaç: Düzenli (tekrarlayan) işlem şablonunu tanımlar.
///
/// Özellikler:
/// - Düzenli işlem detaylarını (sıklık, başlangıç tarihi vb.) tutar
/// - Bir sonraki işlem tarihini hesaplar (calculateNextDueDate)
/// - Otomatik oluşturma durumunu (aktif/pasif) yönetir
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

  /// Bir sonraki işlem tarihini hesaplar (Helper)
  static DateTime calculateNextDueDate(DateTime lastRun, String frequency) {
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
        // Aylık artış mantığı
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
        return lastRun.add(const Duration(days: 30));
    }
  }

  /// Görüntülenmesi gereken sıradaki tarihi döner
  DateTime get nextDueDate {
    // Eğer hiç işlenmemişse, başlangıç tarihi gösterilir.
    if (lastProcessedDate == null) {
      return startDate;
    }
    // İşlenmişse, son işlenme tarihinden bir sonraki periyodu hesaplar.
    return calculateNextDueDate(lastProcessedDate!, frequency);
  }
}
