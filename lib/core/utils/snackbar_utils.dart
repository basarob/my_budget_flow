import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Dosya: snackbar_utils.dart
///
/// Uygulama genelinde standart SnackBar (Bildirim Çubuğu) gösterimi için yardımcı sınıf.
///
/// [Özellikler]
/// - Başarı, Hata ve Standart bilgi mesajları için hazır metodlar.
/// - "Geri Al" (Undo) butonu desteği.
class SnackbarUtils {
  /// Standart bilgilendirme mesajı gösterir.
  ///
  /// [onUndo] parametresi verilirse, mesajın yanında bir "Geri Al" butonu belirir.
  static void showStandard(
    BuildContext context, {
    required String message,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: null, // null = Tema varsayılanı veya koyu gri
      onUndo: onUndo,
      undoLabel: undoLabel,
    );
  }

  /// Başarılı işlem mesajı gösterir (Yeşil Arkaplan).
  static void showSuccess(BuildContext context, {required String message}) {
    _show(context, message: message, backgroundColor: AppColors.incomeGreen);
  }

  /// Hata mesajı gösterir (Kırmızı Arkaplan).
  static void showError(BuildContext context, {required String message}) {
    _show(context, message: message, backgroundColor: AppColors.expenseRed);
  }

  /// Temel SnackBar gösterim mantığı (Private).
  static void _show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    VoidCallback? onUndo,
    String? undoLabel,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Varsa önceki mesajları temizle, yeni mesajın hemen görünmesini sağla
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
                label: undoLabel ?? l10n.undoAction,
                textColor: AppColors.surface,
                onPressed: onUndo,
              )
            : null,
      ),
    );
  }
}
