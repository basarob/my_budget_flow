import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _obscurePassword = true;

  // Controller temizleyici
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
    } catch (e) {
      // 4. Adım: Hata olursa (örn: yanlış şifre) kullanıcıya alt tarafta bilgi mesajı (SnackBar) göster.
      if (mounted) {
        // mounted: Ekran hala açık mı kontrolü (hata almamak için)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
      }
    } finally {
      // 5. Adım: İşlem bitince (başarılı veya hatalı) yükleniyor animasyonunu durdur.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- BAŞLIK KISMI ---
                const Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: AppColors.primary,
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

                // --- FORM KARTI ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey, // Form anahtarını buraya bağlıyoruz
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch, // Yatayda tam genişle
                        children: [
                          // Email Alanı
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType
                                .emailAddress, // Klavye türü (@ işareti getirir)
                            decoration: InputDecoration(
                              labelText: "E-posta Adresi",
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            // Validator: Kullanıcı butona basınca burası çalışır. Null dönerse geçerli, yazı dönerse hata mesajıdır.
                            validator: (value) {
                              // 1. Kontrol: Boş mu?
                              if (value == null || value.isEmpty) {
                                return 'Lütfen e-posta giriniz';
                              }
                              // 2. Kontrol: Email formatına uygun mu? (Regex)
                              // Bu desen; @ işareti, öncesinde ve sonrasında metin ve nokta olmasını şart koşar.
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
                            obscureText:
                                _obscurePassword, // Şifreyi gizle/göster durumu
                            decoration: InputDecoration(
                              labelText: "Şifre",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primaryLight,
                              ), // Göz ikonu: Tıklanınca şifreyi gösterir/gizler
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ), // setState ile ekranı yenileyip ikonu değiştiriyoruz
                              ),
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Lütfen şifre giriniz' : null,
                          ),

                          // Şifremi Unuttum Linki
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
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
                            // Eğer yükleniyorsa butonu devre dışı bırak (null), değilse _login fonksiyonunu bağla
                            onPressed: _isLoading ? null : _login,
                            // Butonun içi: Yükleniyorsa dönen halka, değilse Yazı göster
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text("Giriş Yap"),
                          ),
                        ],
                      ),
                    ),
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
                        // Kayıt ekranına git
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
    );
  }
}
