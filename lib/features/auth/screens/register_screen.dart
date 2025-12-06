import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Her girdi alanı için ayrı bir yönetici (Controller) tanımlıyoruz
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _birthDateController = TextEditingController();
  DateTime? _selectedDate;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Tarih Seçiciyi Açan Fonksiyon
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Varsayılan açılış yılı
      firstDate: DateTime(1900), // En eski tarih
      lastDate: DateTime.now(), // En yeni tarih (bugün)
      // Temaya uygun renkler için builder
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Ekrana kullanıcı dostu formatta yaz (Örn: 24.10.1995)
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Ekstra kontrol: Tarih seçildi mi?
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen doğum tarihinizi seçiniz.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. ADIM: Firebase Authentication ile kullanıcıyı oluştur
      final user = await ref
          .read(authServiceProvider)
          .signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. ADIM: Eğer Auth başarılıysa, detayları Firestore'a kaydet
      if (user != null) {
        await ref
            .read(databaseServiceProvider)
            .saveUserData(
              uid: user.uid, // Auth'dan gelen benzersiz ID
              firstName: _nameController.text.trim(),
              lastName: _surnameController.text.trim(),
              email: _emailController.text.trim(),
              birthDate: _selectedDate!,
            );
      }

      // 3. ADIM: Her şey başarılı, çıkış yap
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: Ekranın en üstündeki başlık çubuğu
      appBar: AppBar(title: const Text("Hesap Oluştur")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hemen Aramıza Katıl!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Gelir ve giderlerini kolayca takip et, hedeflerini koy!",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),

              // Ad ve Soyadı yan yana göstermek için Row (Satır) kullandık
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: "Ad",
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    ),
                  ),
                  const SizedBox(width: 16), // Araya boşluk
                  Expanded(
                    child: TextFormField(
                      controller: _surnameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: "Soyad"),
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Yaş Alanı
              TextFormField(
                controller: _birthDateController,
                readOnly: true, // Elle yazmayı engelle, sadece tıklanabilsin
                onTap: _pickDate, // Tıklanınca takvimi aç
                decoration: const InputDecoration(
                  labelText: "Doğum Tarihi",
                  hintText: "GG.AA.YYYY",
                  prefixIcon: Icon(
                    Icons.calendar_month,
                    color: AppColors.primaryLight,
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Lütfen tarih seçiniz' : null,
              ),

              const SizedBox(height: 16),

              // Email Alanı
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-posta Adresi",
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryLight,
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),

              // Şifre Alanı
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword, // Şifreyi yıldızlı göster
                decoration: InputDecoration(
                  labelText: "Şifre",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.primaryLight,
                  ),
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
                validator: (v) =>
                    v!.length < 6 ? 'En az 6 karakter olmalı' : null,
              ),
              const SizedBox(height: 16),

              // Şifre Tekrar Alanı
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Şifre Tekrar",
                  prefixIcon: const Icon(
                    Icons.lock_clock_outlined,
                    color: AppColors.primaryLight,
                  ),
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
                // ÖZEL KONTROL: Buradaki şifre, yukarıdaki şifreyle aynı mı?
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  if (v == null || v.isEmpty) {
                    return 'Lütfen e-posta giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Kayıt Butonu
              SizedBox(
                width: double.infinity, // Ekran genişliğini kapla
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Kayıt Ol"),
                ),
              ),

              const SizedBox(height: 20),

              // Zaten hesabın var mı butonu
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Zaten hesabın var mı? Giriş Yap",
                    style: TextStyle(color: AppColors.primary),
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
