import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tüm uygulama genelinde kullanılan Gradient (Geçişli) Arka Planlı AppBar.
///
/// Material 3 tasarımına uygun, özel olarak tasarlanmış başlık çubuğu.
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
            color: AppColors.primaryDark.withOpacity(0.3),
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
              fontSize: 20, // AppBar varsayılan yazı boyutu
            ),
            child: title,
          ),
          bottom: bottom,
          foregroundColor: Colors.white, // Geri butonu ve ikonlar beyaz renk
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
