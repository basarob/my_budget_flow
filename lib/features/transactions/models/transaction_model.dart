import 'package:cloud_firestore/cloud_firestore.dart';

// İşlem Tipi için Enum (Gelir veya Gider)
// Veritabanında String olarak saklanacak ('income' veya 'expense')
enum TransactionType { income, expense }

class TransactionModel {
  final String id; // Firestore Belge ID'si
  final String userId; // İşlemi yapan kullanıcının ID'si
  final String title; // İşlem başlığı (Örn: Market Harcaması, KYK Kredisi)
  final double amount; // .Tutar
  final TransactionType type; // Gelir mi Gider mi?
  final String categoryName; // Kategori adı (Örn: Market, Fatura, Burs)
  final DateTime date; // İşlem tarihi
  final String? description; // Açıklama (Opsiyonel)

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryName,
    required this.date,
    this.description,
  });

  // Firestore'a veri gönderirken Map'e çevirme işlemi
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryName': categoryName,
      'date': Timestamp.fromDate(date), // DateTime -> Firestore Timestamp
      'description': description,
    };
  }

  // Firestore'dan gelen veriyi Dart nesnesine çevirme işlemi
  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId, // Belge ID'sini buradan alıyoruz
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: (map['type'] == 'income')
          ? TransactionType.income
          : TransactionType.expense,
      categoryName: map['categoryName'] ?? 'Diğer',
      date: (map['date'] as Timestamp)
          .toDate(), // Firestore Timestamp -> DateTime
      description: map['description'],
    );
  }

  // Debug için yazdırma
  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, type: $type, date: $date)';
  }
}
