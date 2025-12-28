import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../../core/widgets/gradient_app_bar.dart';

/// Dosya: notifications_screen.dart
///
/// Amaç: Kullanıcı bildirimlerinin listelendiği ekran.
///
/// Özellikler:
/// - (Şu an Placeholder) Gelecekte bildirim listesi ve detayları eklenecek.

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleNotifications)),
      body: const Center(child: Placeholder()),
    );
  }
}
