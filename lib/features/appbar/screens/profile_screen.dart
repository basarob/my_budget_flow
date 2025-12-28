import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

/// Dosya: profile_screen.dart
///
/// Amaç: Kullanıcı profil bilgilerini görüntüleme ve düzenleme ekranı.
///
/// Özellikler:
/// - (Şu an Placeholder) Gelecekte profil düzenleme formları eklenecek.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleProfile)),
      body: const Center(child: Placeholder()),
    );
  }
}
