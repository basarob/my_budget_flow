import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'selection_card.dart';

/// İşlem Tarihi Seçici
///
/// Kullanıcının işlem tarihini seçmesi için kullanılan, animasyonlu kart bileşeni.
class TransactionDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;
  final int animKey; // Animasyonu tetiklemek için key

  const TransactionDatePicker({
    super.key,
    required this.selectedDate,
    required this.onTap,
    required this.animKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedDate = DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    ).format(selectedDate);

    final card = SelectionCard(
      title: l10n.dateLabel,
      selectedValue: formattedDate,
      icon: Icons.calendar_today_rounded,
      iconColor: AppColors.primary,
      onTap: onTap,
      placeholder: '',
    );

    // AnimKey değiştiğinde (örneğin otomatik tarih değişiminde) animasyon oynat
    if (animKey > 0) {
      return ElasticIn(key: ValueKey('date-anim-$animKey'), child: card);
    }

    return card;
  }
}
