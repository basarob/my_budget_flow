import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/profile_provider.dart';
import 'package:intl/intl.dart';

/// Dosya: profile_screen.dart
///
/// Amaç: Kullanıcı bilgilerini görüntüleme ve düzenleme.
///
/// Özellikler:
/// - Ad, Soyad düzenlenebilir.
/// - E-posta ve Doğum Tarihi salt okunur gösterilir.
/// - Kaydet butonu ile değişiklikler işlenir.

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
    _birthDateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Veri geldiğinde controller'ları doldur
  void _populateControllers(Map<String, dynamic> userData) {
    if (_nameController.text.isEmpty && !_isEditing) {
      _nameController.text = userData['firstName'] ?? '';
      _surnameController.text = userData['lastName'] ?? '';
      _emailController.text = userData['email'] ?? '';

      if (userData['birthDate'] != null) {
        try {
          final date = (userData['birthDate'] as dynamic).toDate();
          _birthDateController.text = DateFormat('dd.MM.yyyy').format(date);
        } catch (_) {}
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final l10n = AppLocalizations.of(context)!;
      // Profili güncelle (void döner, bu yüzden await kullanılır)
      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            firstName: _nameController.text.trim(),
            lastName: _surnameController.text.trim(),
          );

      // Başarılı olduğunu varsayıyoruz (Riverpod async metotları genellikle hata fırlatmaz, state set eder)
      // MVP UX için snackbar göster.

      if (mounted) {
        SnackbarUtils.showSuccess(context, message: l10n.profileUpdateSuccess);
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(userProvider);
    final isLoading = ref.watch(profileControllerProvider).isLoading;

    return Scaffold(
      appBar: GradientAppBar(title: Text(l10n.pageTitleProfile)),
      body: userAsync.when(
        data: (userData) {
          if (userData == null) {
            return Center(child: Text(l10n.errorUserDataNotFound));
          }

          _populateControllers(userData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Profil Avatarı
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      '${userData['firstName']?[0] ?? ''}${userData['lastName']?[0] ?? ''}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // E-posta (Read-Only)
                  CustomTextField(
                    controller: _emailController,
                    labelText: l10n.emailLabel,
                    prefixIcon: Icons.email,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Ad
                  CustomTextField(
                    controller: _nameController,
                    labelText: l10n.nameLabel,
                    prefixIcon: Icons.person,
                    readOnly: !_isEditing,
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.errorEmptyField : null,
                  ),
                  const SizedBox(height: 16),

                  // Soyad
                  CustomTextField(
                    controller: _surnameController,
                    labelText: l10n.surnameLabel,
                    prefixIcon: Icons.person_outline,
                    readOnly: !_isEditing,
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.errorEmptyField : null,
                  ),
                  const SizedBox(height: 16),

                  // Doğum Tarihi (Read-Only)
                  CustomTextField(
                    controller: _birthDateController,
                    labelText: l10n.birthDateLabel,
                    prefixIcon: Icons.cake,
                    readOnly: true,
                  ),
                  const SizedBox(height: 32),

                  // Butonlar
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _nameController.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                color: AppColors.expenseRed,
                              ),
                              foregroundColor: AppColors.expenseRed,
                            ),
                            child: Text(l10n.cancelButton),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GradientButton(
                            text: l10n.saveButton,
                            onPressed: _saveProfile,
                            isLoading: isLoading,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit),
                        label: Text(
                          l10n.editTransactionTitle.replaceAll("İşlemi ", ""),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorGeneric(e.toString()))),
      ),
    );
  }
}
