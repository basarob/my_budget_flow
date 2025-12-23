import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // --- ANA RENKLER (PRIMARY) ---
  static const Color primary = Color(0xFF64B5F6); // Ana Mavi Tonu
  static const Color primaryLight = Color(0xFF90CAF9); // Açık Mavi
  static const Color primaryDark = Color(0xFF1E88E5); // Koyu Mavi

  // --- ARKA PLAN (BACKGROUND) ---
  static const Color background = Color(0xFFF4F6F8); // Genel Arka Plan Grisi

  // --- YÜZEYLER (SURFACE) ---
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Kartlar ve Paneller için Beyaz

  // --- METİN RENKLERİ (TYPOGRAPHY) ---
  static const Color textPrimary = Color(
    0xFF1C2431,
  ); // Ana Başlıklar ve Metinler
  static const Color textSecondary = Color(
    0xFF627D98,
  ); // Alt Bilgiler ve Açıklamalar

  // --- DURUM RENKLERİ ---
  static const Color incomeGreen = Color(0xFF2E7D32); // Gelir İşlemleri (Yeşil)
  static const Color expenseRed = Color(
    0xFFC62828,
  ); // Gider İşlemleri (Kırmızı)
  static const Color passive = Colors.grey; // Pasif / Devre Dışı Durum
  static const Color warningYellow = Color(
    0xFFEF6C00,
  ); // Uyarı / Dikkat (Turuncu)

  // --- KATEGORİ RENK PALETİ ---
  // İşlem kategorileri için kullanılan geniş renk yelpazesi
  static const List<Color> categoryColors = [
    Color(0xFFFFB74D), // 0: Turuncu
    Color(0xFF4DB6AC), // 1: Teal
    Color(0xFFF06292), // 2: Pembe
    Color(0xFF9575CD), // 3: Mor
    Color(0xFF4FC3F7), // 4: Açık Mavi
    Color(0xFFBA68C8), // 5: Eflatun
    Color(0xFFE57373), // 6: Kırmızımsı
    Color(0xFF7986CB), // 7: İndigo
    Color(0xFF90A4AE), // 8: Mavi Gri
    Color(0xFF81C784), // 9: Yeşil
    Color(0xFFAED581), // 10: Açık Yeşil
    Color(0xFF4DD0E1), // 11: Cyan
    Color(0xFFFFD54F), // 12: Sarı
  ];

  // --- KULLANICI SEÇİM RENKLERİ ---
  // Kullanıcının yeni kategori eklerken seçebileceği temel renkler
  static const List<Color> userSelectionColors = [
    Color(0xFFE57373), // Kırmızı (Soft)
    Color(0xFF64B5F6), // Mavi
    Color(0xFF81C784), // Yeşil
    Color(0xFFFFB74D), // Turuncu
    Color(0xFF9575CD), // Mor
    Color(0xFFF06292), // Pembe
    Color(0xFF90A4AE), // Gri / BlueGrey
  ];
}

class AppTheme {
  /// Uygulamanın tek ve varsayılan teması
  ///
  /// Material 3 tasarım dilini kullanır.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Renk Şeması Tanımları (Material 3)
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.expenseRed,
      onPrimary: Colors.white, // Primary üzerindeki yazı rengi
      onSurface:
          AppColors.textPrimary, // Yüzey (Kart vb.) üzerindeki yazı rengi
    ),

    // Scaffold (Sayfa) Arka Plan Rengi
    scaffoldBackgroundColor: AppColors.background,

    // Yazı Stilleri (Google Fonts - Inter)
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

    // Buton Stilleri (ElevatedButton)
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

    // Input (Yazı Alanı) Teması
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // Normal Durum Çerçevesi
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      // Aktif Değilken (Enabled) Çerçeve
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      // Odaklanıldığında (Focused) Çerçeve
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),

    // Kart Teması
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05), // Çok hafif, modern gölge
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
    ),

    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
