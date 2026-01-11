import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../l10n/app_localizations.dart';

/// Dosya: settings_screen.dart
///
/// Amaç: Uygulama ayarlarını yapılandırma ekranı.
///
/// Özellikler:
/// - Dil Seçimi (Türkçe / İngilizce) değişimini sağlar.

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _changeLanguage(Locale locale) {
    final isEnglish = locale.languageCode == 'en';
    ref.read(languageProvider.notifier).changeLanguage(isEnglish);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleSettings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dil Ayarı Kartı
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.language,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.settingsLanguage,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.textPrimary.withValues(alpha: 0.05),
                  ),
                  const SizedBox(height: 8),
                  _buildLanguageOption(
                    context,
                    title: l10n.settingsLanguageTr,
                    flag: "🇹🇷",
                    value: const Locale('tr', 'TR'),
                    groupValue: currentLocale.value,
                    onChanged: (val) => _changeLanguage(val!),
                  ),
                  _buildLanguageOption(
                    context,
                    title: l10n.settingsLanguageEn,
                    flag: "🇬🇧",
                    value: const Locale('en', 'US'),
                    groupValue: currentLocale.value,
                    onChanged: (val) => _changeLanguage(val!),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String flag,
    required Locale value,
    required Locale? groupValue,
    required ValueChanged<Locale?> onChanged,
  }) {
    final isSelected =
        groupValue != null && value.languageCode == groupValue.languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        // ignore: deprecated_member_use
        child: RadioListTile<Locale>(
          value: value,
          // ignore: deprecated_member_use
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
