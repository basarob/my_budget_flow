import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dosya: shared_prefs_service.dart
///
/// Amaç: Basit verileri (Ayarlar, Onboarding durumu vb.) cihazda saklamak.
///
/// Sağlayıcılar:
/// - `sharedPrefsServiceProvider`: Servise erişim sağlar.

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  throw UnimplementedError(
    'SharedPrefsService init edilmedi. main.dart içinde override edilmeli.',
  );
});

class SharedPrefsService {
  final SharedPreferences prefs;

  SharedPrefsService(this.prefs);
}
