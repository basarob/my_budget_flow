import 'package:cloud_firestore/cloud_firestore.dart';

/// Dosya: goal_model.dart
///
/// Amaç: Kullanıcının birikim hedeflerini temsil eden veri modeli.
///
/// Özellikler:
/// - Hedef adı, tutarı, mevcut birikim, ikon ve renk bilgilerini tutar.
/// - İlerleme durumu (progress) hesaplar.
/// - Firestore dönüşümlerini yönetir.

class Goal {
  final String id;
  final String userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final int iconCode; // IconData.codePoint
  final int colorValue; // Color.value

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    required this.iconCode,
    required this.colorValue,
  });

  /// İlerleme yüzdesi (0.0 - 1.0 arası)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    final p = currentAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  /// Firestore'a yazmak için Map dönüşümü
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'iconCode': iconCode,
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
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : null,
      iconCode: map['iconCode'] ?? 0,
      colorValue: map['colorValue'] ?? 0xFF000000,
    );
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    int? iconCode,
    int? colorValue,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, current: $currentAmount, target: $targetAmount)';
  }
}
