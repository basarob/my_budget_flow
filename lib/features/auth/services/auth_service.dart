import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Dosya: auth_service.dart
///
/// Firebase Authentication işlemlerini yöneten servis sınıfı.
///
/// [Özellikler]
/// - Giriş Yapma (SignIn)
/// - Kayıt Olma (SignUp)
/// - Çıkış Yapma (SignOut)
/// - Şifre Sıfırlama (Password Reset)
/// - Oturum durumunu dinleme (AuthStateChanges)
class AuthService {
  final _logger = Logger();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Kullanıcı Oturum Akışı (Stream)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// E-posta ve şifre ile giriş yapma işlemi.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i("Kullanıcı giriş yaptı: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Giriş Hatası: ${e.code}', error: e);
      rethrow;
    }
  }

  /// Yeni kullanıcı oluşturma işlemi.
  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.i("Yeni kullanıcı oluşturuldu: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Kayıt Hatası: ${e.code}', error: e);
      rethrow;
    }
  }

  /// Şifre sıfırlama bağlantısı gönderme isteği.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _logger.e('Şifre Sıfırlama Hatası: ${e.code}', error: e);
      rethrow;
    }
  }

  /// Oturumu kapatma işlemi.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _logger.i("Kullanıcı çıkış yaptı");
  }
}
