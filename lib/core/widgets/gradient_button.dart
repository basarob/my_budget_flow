import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dosya: gradient_button.dart
///
/// Gradient (Geçişli) renkli, modern ana buton bileşeni.
///
/// [Özellikler]
/// - Yükleniyor (loading) durumunda Progress Indicator gösterir.
/// - Pasif (disabled) durumunda gri renk alır ve tıklanmaz.
/// - Opsiyonel ikon desteği bulunur.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed; // Tıklama aksiyonu
  final String text; // Buton metni
  final bool isLoading; // Yükleniyor animasyonu
  final IconData? icon; // Opsiyonel ikon

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: onPressed == null
              ? [AppColors.passive.withValues(alpha: 0.5), AppColors.passive]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
