import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism Etkili Özel Container Widget'ı
///
/// Arka planı bulanıklaştırarak (blur) buzlu cam efekti verir.
/// Modern ve premium bir görünüm için Dashboard, Takvim ve Özet kartlarında kullanılır.
///
/// Özellikler:
/// - Özelleştirilebilir opaklık ve bulanıklık.
/// - Tema duyarlı (Koyu/Açık mod) otomatik renk uyumu.
/// - Entegre tıklama (onTap) desteği.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final double blur;
  final Gradient? borderGradient;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.opacity = 0.1, // Varsayılan: Hafif şeffaf
    this.blur = 10.0, // Varsayılan: Orta bulanıklık
    this.borderGradient,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        // Yarı saydam arka plan rengi (Tema duyarlı)
        color:
            color ??
            (theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: opacity)
                : Colors.white.withValues(alpha: opacity * 4)),
        // İnce kenarlık (Border) - Premium hissi için
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
          width: 1.0,
        ),
        // Hafif gölge (Derinlik algısı)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          // Blur (Bulanıklaştırma) Efekti
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );

    // Eğer tıklama özelliği varsa GestureDetector ile sarmala
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
