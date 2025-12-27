import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

/// Düzenli İşlem Seçenekleri Kartı
///
/// İşlemin tekrarlı olup olmadığını ve sıklığını belirleyen bileşen.
class RecurringOptionsCard extends StatelessWidget {
  final bool isRecurring;
  final ValueChanged<bool> onRecurringChanged;
  final String frequency;
  final ValueChanged<String?> onFrequencyChanged;

  const RecurringOptionsCard({
    super.key,
    required this.isRecurring,
    required this.onRecurringChanged,
    required this.frequency,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Sıklık Seçenekleri (Yerelleştirilmiş)
    final frequencyOptions = [
      {'value': 'daily', 'label': l10n.frequencyDaily},
      {'value': 'weekly', 'label': l10n.frequencyWeekly},
      {'value': 'monthly', 'label': l10n.frequencyMonthly},
      {'value': 'yearly', 'label': l10n.frequencyYearly},
    ];

    return Column(
      children: [
        // 1. Recurring Switch
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.passive.withValues(alpha: 0.3)),
          ),
          child: SwitchListTile.adaptive(
            value: isRecurring,
            onChanged: onRecurringChanged,
            title: Text(
              l10n.recurringSwitchLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            secondary: Icon(
              Icons.repeat,
              color: isRecurring ? AppColors.warning : AppColors.passive,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            activeTrackColor: AppColors.warning,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Frequency Dropdown (Sadece isRecurring ise göster)
        if (isRecurring)
          DropdownButtonFormField<String>(
            initialValue: frequency,
            decoration: InputDecoration(
              labelText: l10n.frequencyLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.passive.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.passive.withValues(alpha: 0.3),
                ),
              ),
              prefixIcon: Icon(Icons.event_repeat, color: AppColors.warning),
              filled: true,
              fillColor: AppColors.surface,
            ),
            dropdownColor: AppColors.surface,
            items: frequencyOptions.map((opt) {
              return DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(opt['label']!),
              );
            }).toList(),
            onChanged: onFrequencyChanged,
          ),
      ],
    );
  }
}
