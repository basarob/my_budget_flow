/// Sprint 2 kapsamında geliştirilecek olan Takvim Ekranı.
///
/// Şu an sadece yer tutucu (placeholder) olarak bulunmaktadır.
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(child: Text(l10n.pageTitleCalendar));
  }
}
