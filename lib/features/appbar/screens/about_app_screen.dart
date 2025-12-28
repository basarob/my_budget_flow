import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

/// Dosya: about_app_screen.dart
///
/// Amaç: Uygulama hakkında bilgiler içeren ekran (Versiyon, Geliştirici vb.).
///
/// Özellikler:
/// - (Şu an Placeholder) Gelecekte uygulama bilgileri eklenecek.

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleAbout)),
      body: const Center(child: Placeholder()),
    );
  }
}
