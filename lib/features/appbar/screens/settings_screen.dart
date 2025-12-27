import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../../core/widgets/gradient_app_bar.dart';
import '../../../core/providers/language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleSettings)),
      body: asyncLocale.when(
        data: (currentLocale) {
          final isEnglish = currentLocale.languageCode == 'en';
          return ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            children: [
              ListTile(
                title: Text(l10n.settingsLanguage),
                trailing: _buildLanguageSelector(ref, isEnglish),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorLoadingLanguageSettings)),
      ),
    );
  }

  Widget _buildLanguageSelector(WidgetRef ref, bool isEnglish) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageToggle(
            label: '🇹🇷 TR',
            isSelected: !isEnglish,
            onTap: () {
              if (isEnglish) {
                ref.read(languageProvider.notifier).changeLanguage(false);
              }
            },
          ),
          _buildLanguageToggle(
            label: '🇬🇧 EN',
            isSelected: isEnglish,
            onTap: () {
              if (!isEnglish) {
                ref.read(languageProvider.notifier).changeLanguage(true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
