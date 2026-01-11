import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../l10n/app_localizations.dart';

/// Dosya: about_app_screen.dart
///
/// Amaç: Uygulama hakkında bilgi veren ekran.
///
/// Özellikler:
/// - Uygulama Sürümü
/// - Geliştirici Bilgisi
/// - Yasal Metinler (Gizlilik Politikası vb.)

class AboutAppScreen extends ConsumerStatefulWidget {
  const AboutAppScreen({super.key});

  @override
  ConsumerState<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends ConsumerState<AboutAppScreen> {
  final String _version = "1.0";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleAbout)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(10),
              child: ClipOval(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Uygulama Adı
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),

            // Sürüm
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                "v$_version",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bilgi Kartları
            _buildInfoCard(
              context,
              icon: Icons.info_outline,
              title: l10n.aboutAppDescriptionTitle,
              content: l10n.aboutAppDescription,
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              context,
              icon: Icons.security,
              title: l10n.aboutPrivacyTitle,
              content: l10n.aboutPrivacyContent,
            ),

            const SizedBox(height: 48),

            // Alt Bilgi
            const Text(
              "Başar Orhanbulucu",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const Text(
              "© 2026 My Budget Flow",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
