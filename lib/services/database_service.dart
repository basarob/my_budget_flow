import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Dosya: database_service.dart
///
/// Amaç: Firestore veritabanı ile düşük seviyeli etkileşimleri yöneten servis.
///
/// Özellikler:
/// - Kullanıcı verilerini kaydetme (Kayıt olurken)
/// - Kullanıcı verilerini okuma
/// - Logger entegrasyonu ile hata yönetimi

// Servise erişim için Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Kullanıcı Verisini Kaydetme Fonksiyonu
  Future<void> saveUserData({
    required String uid, // Auth'dan gelen User ID
    required String firstName,
    required String lastName,
    required String email,
    required DateTime birthDate,
  }) async {
    try {
      // 'users' koleksiyonunun içine kullanıcının UID'si ile bir döküman açıyoruz.
      // Böylece her kullanıcının verisi kendi ID'si altında saklanır.
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'birthDate': Timestamp.fromDate(birthDate),
        'registrationDate': FieldValue.serverTimestamp(),
      });

      _logger.i("Kullanıcı verisi veritabanına kaydedildi: $uid");
    } catch (e) {
      _logger.e("Veritabanı Kayıt Hatası", error: e);
      rethrow; // Hatayı ekrana göndermek için fırlat
    }
  }

  // Kullanıcı Verisini Getirme
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      _logger.e("Veri Çekme Hatası: $uid", error: e);
      return null;
    }
  }
}
