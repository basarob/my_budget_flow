import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _languageCodeKey = 'languageCode';

// Dili değiştirmek ve durumunu tutmak için Notifier sınıfı
class LanguageNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    // Cihaz hafızasından dil tercihini yükle
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);

    if (languageCode == 'en') {
      return const Locale('en', 'US');
    }

    // Kayıtlı dil yoksa veya 'tr' ise varsayılan olarak Türkçe ata
    return const Locale('tr', 'TR');
  }

  // Dili değiştiren ve hafızaya kaydeden fonksiyon
  Future<void> changeLanguage(bool isEnglish) async {
    final Locale newLocale;
    if (isEnglish) {
      newLocale = const Locale('en', 'US');
    } else {
      newLocale = const Locale('tr', 'TR');
    }

    // Yeni durumu hemen ayarla ki UI güncellensin
    state = AsyncValue.data(newLocale);

    // Yeni dil tercihini cihaz hafızasına kaydet
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, newLocale.languageCode);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider Tanımı
final languageProvider = AsyncNotifierProvider<LanguageNotifier, Locale>(() {
  return LanguageNotifier();
});
