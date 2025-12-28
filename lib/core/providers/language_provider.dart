import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _languageCodeKey = 'languageCode';

/// Dosya: language_provider.dart
///
/// Uygulama dili yönetimini sağlayan Notifier sınıfı.
///
/// [Özellikler]
/// - Kullanıcının dil tercihini (Türkçe/İngilizce) yönetir.
/// - Tercihi cihaz hafızasına kaydeder ve açılışta hatırlar.
/// - Riverpod [AsyncNotifier] altyapısını kullanır.
class LanguageNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    // 1. Cihaz hafızasından kayıtlı dil tercihini oku.
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);

    // 2. Eğer kayıtlı dil 'en' ise İngilizce locale döndür.
    if (languageCode == 'en') {
      return const Locale('en', 'US');
    }

    // 3. Varsayılan olarak Türkçe döndür.
    return const Locale('tr', 'TR');
  }

  /// Dili değiştirir ve yeni tercihi kalıcı hafızaya kaydeder.
  ///
  /// [isEnglish]: true ise İngilizce, false ise Türkçe yapar.
  Future<void> changeLanguage(bool isEnglish) async {
    final Locale newLocale;
    if (isEnglish) {
      newLocale = const Locale('en', 'US');
    } else {
      newLocale = const Locale('tr', 'TR');
    }

    // State'i güncelle (UI anında tepki verir)
    state = AsyncValue.data(newLocale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, newLocale.languageCode);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Dil Sağlayıcısı (Provider)
///
/// Uygulamanın herhangi bir yerinden `ref.watch(languageProvider)` ile erişilebilir.
final languageProvider = AsyncNotifierProvider<LanguageNotifier, Locale>(() {
  return LanguageNotifier();
});
