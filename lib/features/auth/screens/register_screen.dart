import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../../../services/database_service.dart';
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
  bool _isButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _surnameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _surnameController.removeListener(_validateForm);
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);

    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isEnabled =
        _nameController.text.isNotEmpty &&
        _surnameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _selectedDate != null;

    if (isEnabled != _isButtonEnabled) {
      setState(() => _isButtonEnabled = isEnabled);
    }
  }

  // Kelimelerin baş harflerini büyüten yardımcı fonksiyon
  String _capitalizeWords(String text) {
    if (text.trim().isEmpty) {
      return '';
    }
    return text
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  // .Tarih Seçiciyi Açan Fonksiyon
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // .Temaya uygun renkler için builder
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
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(picked);
        _validateForm();
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

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
              firstName: _capitalizeWords(_nameController.text),
              lastName: _capitalizeWords(_surnameController.text),
              email: _emailController.text.trim(),
              birthDate: _selectedDate!,
            );
        // 2.5 ADIM: Kullanıcıyı oturumdan çıkar
        await ref.read(authServiceProvider).signOut();
      }

      // 3. ADIM: Başarı mesajı göster ve bir önceki ekrana dön
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarıyla oluşturuldu. Lütfen giriş yapın.'),
            backgroundColor: AppColors.incomeGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Kayıt sırasında bir hata oluştu.';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.expenseRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: Ekranın en üstündeki başlık çubuğu
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: const Text("Hesap Oluştur"),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
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
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final nameRegExp = RegExp(
                            r'^[a-zA-ZçÇğĞıİöÖşŞÜ\s]+$',
                          );
                          if (!nameRegExp.hasMatch(v)) {
                            return 'Sadece harf giriniz.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16), // Araya boşluk
                    Expanded(
                      child: TextFormField(
                        controller: _surnameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: "Soyad"),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final nameRegExp = RegExp(
                            r'^[a-zA-ZçÇğĞıİöÖşŞÜ\s]+$',
                          );
                          if (!nameRegExp.hasMatch(v)) {
                            return 'Sadece harf giriniz.';
                          }
                          return null;
                        },
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
                  validator: (v) => null,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // Buton zaten pasif olacak
                    }
                    // Email formatına uygun mu? (Regex)
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v != null && v.length < 6
                      ? 'En az 6 karakter olmalı'
                      : null,
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
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Şifreler eşleşmiyor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Kayıt Butonu
                SizedBox(
                  width: double.infinity, // Ekran genişliğini kapla
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled && !_isLoading
                        ? _register
                        : null,
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
      ),
    );
  }
}
