// Sprint 3 kapsamında geliştirilecek olan Hedefler Ekranı.
//
// Şu an sadece yer tutucu (placeholder) olarak bulunmaktadır.
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(child: Text(l10n.pageTitleGoals));
  }
}
