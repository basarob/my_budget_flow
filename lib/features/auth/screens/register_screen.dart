import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import '../../../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../core/utils/snackbar_utils.dart';

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

  /// Tarih Seçicisi (Cupertino stili)
  Future<void> _pickDate(BuildContext context) async {
    // Klavye açıksa kapat
    FocusScope.of(context).unfocus();

    final l10n = AppLocalizations.of(context)!;

    // Varsayılan tarih
    final initialDate = _selectedDate ?? DateTime.now();

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: AppColors.surface, // Tema arka plan rengi
          child: Column(
            children: [
              // Üstteki "Tamam" butonu çubuğu
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.commonOk,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tarih Seçici Tekerleği
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      _birthDateController.text = DateFormat(
                        'dd.MM.yyyy',
                      ).format(newDate);
                      _validateForm();
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
        SnackbarUtils.showSuccess(context, message: l10n.successRegister);
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      // Hata mesajını yerelleştirme anahtarlarına göre ayarla
      if (mounted) {
        String errorMessage = l10n.errorRegisterGeneral;
        if (e.code == 'email-already-in-use') {
          errorMessage = l10n.errorRegisterEmailInUse;
        }
        SnackbarUtils.showError(context, message: errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.createAccountTitle)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Hero(
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
              const SizedBox(height: 24),

              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _nameController,
                              labelText: l10n.nameLabel,
                              prefixIcon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return l10n.errorEmptyField;
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _surnameController,
                              labelText: l10n.surnameLabel,
                              prefixIcon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return l10n.errorEmptyField;
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: () => _pickDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _birthDateController.text.isEmpty
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: IgnorePointer(
                            child: CustomTextField(
                              controller: _birthDateController,
                              labelText: l10n.birthDateLabel,
                              prefixIcon: Icons.calendar_month,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return l10n.errorEmptyField;
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

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

                      CustomTextField(
                        controller: _passwordController,
                        labelText: l10n.passwordLabel,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.length < 6)
                            return l10n.errorPasswordShort;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: l10n.passwordConfirmLabel,
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return l10n.errorPasswordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      GradientButton(
                        onPressed: _isButtonEnabled && !_isLoading
                            ? _register
                            : null,
                        text: l10n.registerButton,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccountQuestion,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.loginButton,
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
    );
  }
}
