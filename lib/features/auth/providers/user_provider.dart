import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../../services/database_service.dart';

/// Dosya: user_provider.dart
///
/// Kullanıcı verisinin önbelleğe (cache) alınmasını sağlayan Provider.
///
/// [Özellikler]
/// - Veritabanından (Firestore) kullanıcı profilini (Ad, Soyad vb.) çeker.
/// - Dashboard ve Menü gibi yerlerde tekrar tekrar veritabanı okuması yapılmasını engeller.
/// - Sadece [authStateChangesProvider] değiştiğinde (örn: giriş yapıldığında) tetiklenir.
final userProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // 1. Oturum açmış kullanıcıyı al
  final authState = ref.watch(authStateChangesProvider);
  final user = authState.value;

  if (user == null) {
    return null;
  }

  // 2. Veritabanından detaylı bilgileri çek ve döndür
  final databaseService = ref.read(databaseServiceProvider);
  final userData = await databaseService.getUserData(user.uid);

  return userData;
});
