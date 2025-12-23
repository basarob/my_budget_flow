import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../main.dart'; // For routeObserver

import '../../../core/providers/language_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with RouteAware {
  final _formKey = GlobalKey<FormState>(); // Form anahtarı

  // Controller'lar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Bu rota, üstündeki bir rota kapandığında (pop) tetiklenir.
  @override
  void didPopNext() {
    // Bu ekrana geri dönüldüğünde klavyeyi ve focus'u kapat
    FocusScope.of(context).unfocus();
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _updateButtonState() {
    final isEnabled =
        _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return; // Boş alan varsa durdur

    setState(() => _isLoading = true); // Yükleme animasyonu ile ekranı kitle

    try {
      // Riverpod ile AuthService'e ulaş ve signIn fonksiyonunu çağır.
      await ref
          .read(authServiceProvider)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;

        String errorMessage = l10n.errorLoginGeneral;
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            errorMessage = l10n.errorLoginWrongCredentials;
            break;
          case 'invalid-email':
            errorMessage = l10n.errorInvalidEmail;
            break;
          default:
            errorMessage = l10n.errorLoginGeneral;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.expenseRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      // 5. Adım: İşlem bitince (başarılı veya hatalı) yükleniyor animasyonunu durdur.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              // Arkaplan Deseni (Opsiyonel: Hafif Gradient)
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- BAŞLIK VE LOGO ---
                      ElasticIn(
                        duration: const Duration(
                          milliseconds: 1000,
                        ), // Slightly longer for elastic effect
                        child: Hero(
                          tag: 'app_icon',
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              height: 130,
                              width: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            Text(
                              l10n.appTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.welcomeBack,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // --- GİRİŞ FORMU ---
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 800),
                        child: loginForm(context),
                      ),

                      const SizedBox(height: 32),

                      // --- KAYIT OL YÖNLENDİRMESİ ---
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        duration: const Duration(milliseconds: 800),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccountQuestion,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                await Future.delayed(
                                  const Duration(milliseconds: 200),
                                );
                                if (!context.mounted) return;
                                _clearForm();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.registerButton,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Dil Seçimi
              Positioned(
                top: 16,
                right: 16,
                child: PopupMenuButton<bool>(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  offset: const Offset(0, 45),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onSelected: (isEnglish) {
                    ref
                        .read(languageProvider.notifier)
                        .changeLanguage(isEnglish);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: false, // isEnglish = false
                      child: Center(
                        child: Text(
                          '🇹🇷 Türkçe',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: true, // isEnglish = true
                      child: Center(
                        child: Text(
                          '🇬🇧 English',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Form loginForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Alanı
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
          const SizedBox(height: 16),

          // Şifre Alanı
          CustomTextField(
            controller: _passwordController,
            labelText: l10n.passwordLabel,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (val) => null,
          ),

          // Şifremi Unuttum Linki
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                await Future.delayed(const Duration(milliseconds: 200));
                if (!context.mounted) return;
                _clearForm();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                l10n.forgotPasswordQuestion,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Giriş Butonu
          GradientButton(
            onPressed: _isButtonEnabled ? _login : null,
            text: l10n.loginButton,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
