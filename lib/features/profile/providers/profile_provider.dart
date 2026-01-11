import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/providers/user_provider.dart';
import '../repositories/profile_repository.dart';

/// Dosya: profile_provider.dart
///
/// Amaç: Profil yönetimi için state management.
///
/// Sağlayıcılar:
/// - `profileRepositoryProvider`: Repository erişimi
/// - `profileControllerProvider`: Güncelleme işlemleri için AsyncNotifier

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Başlangıçta boş
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);

      await repository.updateUserProfile(user.uid, {
        'firstName': firstName,
        'lastName': lastName,
      });

      // UserProvider'ı yenile ki UI güncellensin
      ref.invalidate(userProvider);
    });
  }
}
