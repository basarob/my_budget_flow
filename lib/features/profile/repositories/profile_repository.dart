import 'package:cloud_firestore/cloud_firestore.dart';

/// Dosya: profile_repository.dart
///
/// Amaç: Kullanıcı profili ile ilgili veritabanı işlemlerini yönetir.
///
/// Özellikler:
/// - Kullanıcı bilgilerini güncelleme

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
}
