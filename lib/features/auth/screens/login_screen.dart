import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'forgotp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Form anahtarı

  // Controller'lar
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        String errorMessage = 'Giriş sırasında bir hata oluştu.';
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            errorMessage = 'Hatalı e-posta veya şifre girdiniz.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz bir e-posta adresi giriniz.';
            break;
          default:
            errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.expenseRed,
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
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- BAŞLIK VE LOGO ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50), // Köşeleri yuvarla
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 16), // Boşluk

                  const Text(
                    "My Budget Flow",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Tekrar Hoşgeldiniz",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- GİRİŞ FORMU ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: loginForm(context),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- KAYIT OL YÖNLENDİRMESİ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Hesabın yok mu?",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus(); // Odağı kaldır
                          _clearForm();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Form loginForm(BuildContext context) {
    return Form(
      key: _formKey, // Form anahtarını buraya bağlıyoruz
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Alanı
          TextFormField(
            controller: _emailController,
            autofocus: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "E-posta Adresi",
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.primaryLight,
              ),
            ),
            // Validator: Kullanıcı butona basınca burası çalışır. Null dönerse geçerli, yazı dönerse hata mesajıdır.
            validator: (value) {
              // 1. Kontrol: Boş mu? - Buton durumu ile kontrol edildi.
              if (value == null || value.isEmpty) {
                return null; // Buton zaten pasif olacak
              }
              // 2. Kontrol: Email formatına uygun mu? (Regex)
              final bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
              ).hasMatch(value);

              if (!emailValid) {
                return 'Geçerli bir e-posta adresi giriniz.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Şifre Alanı
          TextFormField(
            controller: _passwordController,
            autofocus: false,
            obscureText: _obscurePassword, // Şifreyi gizle/göster durumu
            decoration: InputDecoration(
              labelText: "Şifre",
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primaryLight,
              ), // Göz ikonu: Tıklanınca şifreyi gösterir/gizler
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (val) => null,
          ),

          // Şifremi Unuttum Linki
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                FocusScope.of(context).unfocus(); // Odağı kaldır
                _clearForm();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                "Şifremi Unuttum?",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Giriş Butonu
          ElevatedButton(
            onPressed: _isButtonEnabled && !_isLoading ? _login : null,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Giriş Yap"),
          ),
        ],
      ),
    );
  }
}
