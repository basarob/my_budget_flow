import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
          SnackBar(
            content: Text(l10n.successRegister),
            backgroundColor: AppColors.incomeGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      // Hata mesajını yerelleştirme anahtarlarına göre ayarla
      if (mounted) {
        String errorMessage = l10n.errorRegisterGeneral;
        if (e.code == 'email-already-in-use') {
          errorMessage = l10n.errorRegisterEmailInUse;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // AppBar: Ekranın en üstündeki başlık çubuğu
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        title: Text(l10n.createAccountTitle),
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
                Text(
                  l10n.joinUsTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.joinUsSubtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 30),

                // Ad ve Soyadı yan yana göstermek için Row (Satır) kullandık
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.nameLabel,
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
                            return l10n.errorOnlyLetters;
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
                        decoration: InputDecoration(
                          labelText: l10n.surnameLabel,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final nameRegExp = RegExp(
                            r'^[a-zA-ZçÇğĞıİöÖşŞÜ\s]+$',
                          );
                          if (!nameRegExp.hasMatch(v)) {
                            return l10n.errorOnlyLetters;
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
                  decoration: InputDecoration(
                    labelText: l10n.birthDateLabel,
                    hintText: l10n.dateHint,
                    prefixIcon: const Icon(
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
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    prefixIcon: const Icon(
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
                      return l10n.errorInvalidEmail;
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
                    labelText: l10n.passwordLabel,
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
                      ? l10n.errorPasswordShort
                      : null,
                ),
                const SizedBox(height: 16),

                // Şifre Tekrar Alanı
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.passwordConfirmLabel,
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
                      return l10n.errorPasswordMismatch;
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
                        : Text(l10n.registerButton),
                  ),
                ),

                const SizedBox(height: 20),

                // Zaten hesabın var mı butonu
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.alreadyHaveAccountQuestion,
                      style: const TextStyle(color: AppColors.primary),
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
