import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../services/auth_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

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

  void _updateButtonState() {
    final isEnabled = _emailController.text.isNotEmpty;
    if (isEnabled != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isEnabled);
    }
  }

  Future<void> _sendResetLink() async {
    // Önce kontrol: Kullanıcı email yazmış mı?
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);
    try {
      // Servise git ve reset maili gönder
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(_emailController.text.trim());

      if (mounted) {
        // Klavye kapansın
        FocusScope.of(context).unfocus();

        // Kullanıcıya başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.successResetEmailSent),
            backgroundColor: AppColors.incomeGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(
          context,
        ); // İşlem bitince kullanıcıyı Login ekranına geri at.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
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
