import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Genel Amaçlı Seçim Kartı Kartı
///
/// Kullanıcının bir listeden veya modalden seçim yapması gereken alanlarda kullanılır.
/// (Örn: Kategori seçimi, Tarih seçimi).
///
/// Görünüm:
/// - Sol tarafta renkli ikon
/// - Ortada başlık ve seçilen değer (veya placeholder)
/// - Sağ tarafta ok ikonu
class SelectionCard extends StatelessWidget {
  final String title;
  final String? selectedValue;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final String placeholder;

  const SelectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.placeholder,
    this.selectedValue,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Seçili değer yoksa placeholder rengi, varsa normal metin rengi
    final isSelected = selectedValue != null && selectedValue!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.passive.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // İkon Alanı
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Metin Alanı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? selectedValue! : placeholder,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.passive,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Ok İşareti
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.passive,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
