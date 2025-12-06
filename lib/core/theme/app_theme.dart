import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- ANA RENKLER (PRIMARY) ---
  static const Color primary = Color(0xFF1565C0); // Blue 800
  static const Color primaryLight = Color(0xFF42A5F5); // Blue 400
  static const Color primaryDark = Color(0xFF0D47A1); // Blue 900

  // --- ARKA PLAN (BACKGROUND) ---
  static const Color background = Color(0xFFF4F6F8);

  // Kartlar ve listeler için tam beyaz yüzey
  static const Color surface = Color(0xFFFFFFFF);

  // --- METİN RENKLERİ (TYPOGRAPHY) ---
  static const Color textPrimary = Color(0xFF1C2431);
  // İkincil yazılar (tarih, açıklama) için orta gri
  static const Color textSecondary = Color(0xFF627D98);

  // --- DURUM RENKLERİ ---
  static const Color incomeGreen = Color(0xFF2E7D32); // Gelir (Yeşil)
  static const Color expenseRed = Color(0xFFC62828); // Gider (Kırmızı)
  static const Color warningYellow = Color(0xFFEF6C00); // Uyarı (Turuncu)
}

class AppTheme {
  // Uygulamanın tek ve varsayılan teması
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Renk Şeması Tanımları
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.expenseRed,
      onPrimary: Colors.white, // Primary üzerindeki yazı rengi
      onSurface: AppColors.textPrimary, // Kart üzerindeki yazı rengi
    ),

    // Arka plan rengini sabitle
    scaffoldBackgroundColor: AppColors.background,

    // Yazı Stilleri (Google Fonts - Roboto veya Inter önerilir)
    // Not: pubspec.yaml'a 'google_fonts' paketini eklemeyi unutma.
    // Eklemek için terminale: flutter pub add google_fonts
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      titleLarge: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),

    // Buton Stilleri
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0, // Düz tasarım (gölgesiz)
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
          ), // Hafif yuvarlatılmış köşeler
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Input (Yazı Alanı) Stilleri
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),

    // Kart Stilleri
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05), // Çok hafif gölge
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
    ),

    // AppBar Stili
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
