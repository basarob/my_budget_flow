import 'package:cloud_firestore/cloud_firestore.dart';

/// Dosya: goal_model.dart
///
/// Amaç: Kullanıcının birikim ve harcama hedeflerini temsil eden veri modeli.
///
/// Özellikler:
/// - Hedef tipi (Yatırım/Harcama)
/// - Başlangıç tarihi ve dahil edilen kategoriler
/// - Otomatik hesaplanan ilerleme durumu
/// - Firestore dönüşümleri
///

enum GoalType {
  investment, // Birikim Hedefi
  expense, // Harcama Hedefi
}

class Goal {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final DateTime startDate;
  final GoalType type;
  final List<String> categoryIds; // Hedefe dahil edilen kategoriler
  final int colorValue; // Color.value

  // Hesaplanmış alanlar (Veritabanında tutulmaz)
  final double collectedAmount;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.startDate,
    required this.type,
    required this.categoryIds,
    required this.colorValue,
    this.collectedAmount = 0.0,
  });

  /// İlerleme yüzdesi (0.0 - 1.0 arası)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    final p = collectedAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  /// Firestore'a yazmak için Map dönüşümü
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'startDate': Timestamp.fromDate(startDate),
      'type': type.name, // 'investment' veya 'expense'
      'categoryIds': categoryIds,
      'colorValue': colorValue,
    };
  }

  /// Firestore'dan okumak için Factory metodu
  factory Goal.fromMap(Map<String, dynamic> map, String documentId) {
    return Goal(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      type: GoalType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'investment'),
        orElse: () => GoalType.investment,
      ),
      categoryIds: List<String>.from(map['categoryIds'] ?? []),
      colorValue: map['colorValue'] ?? 0xFF000000,
      collectedAmount: 0.0, // Provider'da hesaplanacak
    );
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    DateTime? startDate,
    GoalType? type,
    List<String>? categoryIds,
    int? colorValue,
    double? collectedAmount,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      startDate: startDate ?? this.startDate,
      type: type ?? this.type,
      categoryIds: categoryIds ?? this.categoryIds,
      colorValue: colorValue ?? this.colorValue,
      collectedAmount: collectedAmount ?? this.collectedAmount,
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, type: $type, collected: $collectedAmount, target: $targetAmount)';
  }
}
