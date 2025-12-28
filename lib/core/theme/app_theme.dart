import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dosya: app_theme.dart
///
/// Uygulamanın merkezi renk paleti ve tema tanımları.
///
/// [Özellikler]
/// - Tüm renk sabitleri (Primary, Secondary, Background vb.)
/// - Material 3 tabanlı Işık Teması (Light Theme) ayarları.
/// - Özel widget stilleri (Card, InputDecoration, Button vb.)
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
  static const Color textSecondary = Color(0xFF627D98); // Alt Bilgiler

  // --- DURUM RENKLERİ ---
  static const Color incomeGreen = Color(0xFF2E7D32); // Gelir İşlemleri (Yeşil)
  static const Color expenseRed = Color(
    0xFFC62828,
  ); // Gider İşlemleri (Kırmızı)
  static const Color passive = Colors.grey; // Pasif / Devre Dışı Durum
  static const Color warning = Color(0xFFEF6C00); // Uyarı / Dikkat (Turuncu)
  static const Color info = Color(0xFF00897B); // Bilgi / Detay (Teal)

  // --- KATEGORİ RENK PALETİ ---
  static const List<Color> categoryColors = [
    Color(0xFFFFA726), // 0: Turuncu     -> (YEMEK)
    Color(0xFFFF7043), // 1: Mercan      -> (FATURA - Aciliyet hissi)
    Color(0xFF29B6F6), // 2: Gök Mavisi  -> (ULAŞIM - Hareket hissi)
    Color(0xFF5C6BC0), // 3: İndigo      -> (KİRA - Güven hissi)
    Color(0xFF7E57C2), // 4: Derin Mor   -> (EĞLENCE)
    Color(0xFFEC407A), // 5: Pembe       -> (ALIŞVERİŞ)
    Color(0xFFEF5350), // 6: Soft Kırmızı-> (SAĞLIK)
    Color(0xFF42A5F5), // 7: Mavi        -> (Yedek/Boşta)
    Color(0xFF78909C), // 8: Mavi Gri    -> (DİĞER - Nötr)
    Color(0xFF66BB6A), // 9: Yeşil       -> (MAAŞ - Para rengi)
    Color(0xFFD4E157), // 10: Lime       -> (Yedek/Boşta)
    Color(0xFF26A69A), // 11: Teal       -> (YATIRIM - Büyüme rengi)
    Color(0xFFFFEE58), // 12: Sarı       -> (Yedek/Boşta)
  ];

  // --- KULLANICI SEÇİM RENKLERİ ---
  static const List<Color> userSelectionColors = [
    Color(0xFF8D6E63), // 0: Kakao Kahve
    Color(0xFF26C6DA), // 1: Parlak Turkuaz
    Color(0xFFFFB300), // 2: Bal/Amber
    Color(0xFFAB47BC), // 3: Canlı Menekşe
    Color(0xFF7CB342), // 4: Limon Yeşili
    Color(0xFF546E7A), // 5: Arduvaz Grisi
    Color(0xFFFF5252), // 6: Neon Kırmızı
  ];
}

class AppTheme {
  /// Uygulamanın tek ve varsayılan teması (Light Mode).
  ///
  /// Material 3 tasarım dilini kullanır ve [AppColors] sınıfındaki
  /// renk paletiyle uyumlu şekilde tüm bileşenleri stillendirir.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Renk Şeması Tanımları (Material 3)
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.expenseRed,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
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
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Input (Yazı Alanı) Teması
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

    // Kart Teması
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
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
