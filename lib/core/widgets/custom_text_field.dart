import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dosya: custom_text_field.dart
///
/// Özelleştirilmiş Metin Giriş Alanı (Text Field).
///
/// [Özellikler]
/// - Şifre alanları için gizle/göster butonu.
/// - Otomatik odaklanma ve ikon desteği.
/// - Standart tema ile uyumlu kenarlık ve renk tasarımları.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
  });

  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(widget.prefixIcon, color: AppColors.primary),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,

        filled: true,
        fillColor: AppColors.surface,

        // Kenarlık Stilleri
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.passive, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.passive, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expenseRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.expenseRed, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
