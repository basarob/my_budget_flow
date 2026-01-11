import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

/// Dosya: goal_repository.dart
///
/// Amaç: Firestore veritabanı ile Hedef (Goal) işlemlerini yönetir.
///
/// Özellikler:
/// - Hedef ekleme, güncelleme, silme
/// - Hedefleri listeleme (Real-time stream)

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Yeni hedef ekler
  Future<void> addGoal(Goal goal) async {
    final collection = _firestore
        .collection('users')
        .doc(goal.userId)
        .collection('goals');

    final docRef = collection.doc(); // Otomatik ID
    final data = goal.toMap();
    data['id'] = docRef.id;

    await docRef.set(data);
  }

  /// Mevcut hedefi günceller
  Future<void> updateGoal(Goal goal) async {
    await _firestore
        .collection('users')
        .doc(goal.userId)
        .collection('goals')
        .doc(goal.id)
        .update(goal.toMap());
  }

  /// Hedefi siler
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  /// Kullanıcının hedeflerini dinler (Stream)
  Stream<List<Goal>> getGoalsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Goal.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
