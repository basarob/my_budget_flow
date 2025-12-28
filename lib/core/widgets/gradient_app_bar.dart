import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dosya: gradient_app_bar.dart
///
/// Uygulama genelinde kullanılan, geçişli (gradient) arka plana sahip özel AppBar.
///
/// [Özellikler]
/// - Material 3 uyumlu tasarım.
/// - Altına gölge efekti (Shadow) eklenmiş modern görünüm.
/// - SafeArea desteği ile çentikli cihazlarda düzgün görünüm.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const GradientAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary, // Açık Mavi
            AppColors.primaryDark, // Koyu Mavi
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: AppBar(
          backgroundColor:
              Colors.transparent, // Container gradient'i gösterecek
          elevation: 0,
          leading: leading,
          actions: actions,
          centerTitle: centerTitle,
          title: DefaultTextStyle(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
            child: title,
          ),
          bottom: bottom,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
