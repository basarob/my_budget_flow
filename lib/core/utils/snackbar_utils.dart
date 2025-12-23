import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tüm uygulama genelinde standart SnackBar kullanımı için yardımcı sınıf.
class SnackbarUtils {
  /// Standart bilgilendirme mesajı gösterir (Siyah/Gri).
  /// [onUndo] verilirse "Geri Al" butonu eklenir.
  static void showStandard(
    BuildContext context, {
    required String message,
    VoidCallback? onUndo,
    String undoLabel = 'Geri Al', // Varsayılan label
  }) {
    _show(
      context,
      message: message,
      backgroundColor: null, // Tema varsayılanı veya koyu gri
      onUndo: onUndo,
      undoLabel: undoLabel,
    );
  }

  /// Başarılı işlem mesajı gösterir (Yeşil).
  static void showSuccess(BuildContext context, {required String message}) {
    _show(context, message: message, backgroundColor: AppColors.incomeGreen);
  }

  /// Hata mesajı gösterir (Kırmızı).
  static void showError(BuildContext context, {required String message}) {
    _show(context, message: message, backgroundColor: AppColors.expenseRed);
  }

  /// Temel SnackBar gösterim mantığı
  static void _show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Varsa önceki mesajları temizle
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: onUndo != null
            ? SnackBarAction(
                label: undoLabel ?? 'Geri Al',
                textColor: AppColors.surface, // Genelde beyaz iyi durur
                onPressed: onUndo,
              )
            : null,
      ),
    );
  }
}
