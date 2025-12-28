import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';

/// Dosya: forgot_password_screen.dart
///
/// Şifremi Unuttum Ekranı.
///
/// [Özellikler]
/// - Kullanıcıdan e-posta adresini alır.
/// - Firebase üzerinden şifre sıfırlama bağlantısı gönderir.
/// - Modern UI animasyonları (FadeInDown vb.) içerir.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _emailController.dispose();
    super.dispose();
  }

  /// Butonun aktif/pasif durumunu, inputun doluluğuna göre günceller.
  void _updateButtonState() {
    final isEnabled = _emailController.text.isNotEmpty;
    if (isEnabled != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isEnabled);
    }
  }

  /// Şifre sıfırlama isteğini başlatır.
  Future<void> _sendResetLink() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);
    try {
      // Servis üzerinden e-posta gönder
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        FocusScope.of(context).unfocus();

        // Başarı mesajı göster ve geri dön
        SnackbarUtils.showSuccess(context, message: l10n.successResetEmailSent);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: l10n.errorGeneric(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.resetPasswordTitle)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  l10n.resetPasswordDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        labelText: l10n.emailLabel,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(value);
                          if (!emailValid) return l10n.errorInvalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      GradientButton(
                        onPressed: _isButtonEnabled && !_isLoading
                            ? _sendResetLink
                            : null,
                        text: l10n.sendResetLinkButton,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
