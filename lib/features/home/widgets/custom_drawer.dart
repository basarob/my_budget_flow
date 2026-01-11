import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/providers/user_provider.dart'; // UserProvider eklendi
import '../../profile/screens/profile_screen.dart';
import '../../appbar/screens/settings_screen.dart';
import '../../appbar/screens/about_app_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

/// Özel Menü (Drawer) Bileşeni
///
/// Kullanıcı profilini, ayarları ve çıkış işlemini barındıran
/// modern, kompakt ve tema ile uyumlu sağ menü.
///
/// Performans Notu:
/// - Kullanıcı bilgileri `userProvider` üzerinden önbellekten alınır.
/// - Menü açıldığında tekrar veritabanı sorgusu yapılmaz.
class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yerelleştirme ve Kimlik Doğrulama verisine erişim
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(
          top: kToolbarHeight + 10,
          right: 6,
          bottom: 16,
        ),
        child: Material(
          color: Colors.transparent, // Arkaplan şeffaf, container hallediyor
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.75, // Genişlik %75
              maxHeight:
                  MediaQuery.of(context).size.height * 0.8, // Yükseklik %80
            ),
            child: Container(
              decoration: BoxDecoration(
                // Tema ile uyumlu hafif gradient arkaplan
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surface.withValues(
                      alpha: 0.95,
                    ), // Hafif saydamlık
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                // Derinlik hissi veren gölgelendirme
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                // İnce, zarif kenarlık
                border: Border.all(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Profil ve Başlık Alanı
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.08),
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: _buildUserHeader(context, ref, user, l10n),
                      ),

                      // 2. Menü Seçenekleri
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        child: Column(
                          children: [
                            _buildDrawerItem(
                              context,
                              Icons.settings_outlined,
                              l10n.pageTitleSettings,
                              const SettingsScreen(),
                            ),
                            const SizedBox(height: 4),
                            _buildDrawerItem(
                              context,
                              Icons.info_outline,
                              l10n.pageTitleAbout,
                              const AboutAppScreen(),
                            ),
                          ],
                        ),
                      ),

                      // 3. Ayırıcı Çizgi (Tema ile uyumlu)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),

                      // 4. Çıkış Butonu
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildLogoutButton(context, ref, l10n),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kullanıcı başlık alanını oluşturur (Profil fotosu, isim, email)
  ///
  /// `userProvider` kullanarak verileri önbellekten çeker.
  Widget _buildUserHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    AppLocalizations l10n,
  ) {
    // Kullanıcı detay verilerini (isim, vb.) dinle
    final userAsync = ref.watch(userProvider);

    return InkWell(
      onTap: () {
        Navigator.pop(context); // Menüyü kapat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Profil İkonu Kutusu
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface, // Hardcode yerine tema rengi
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),

            // Kullanıcı Bilgileri (İsim & E-posta)
            Expanded(
              child: userAsync.when(
                data: (userData) {
                  // İsim bilgisini oluştur
                  String displayName = l10n.appTitle;
                  if (userData != null) {
                    displayName =
                        "${userData['firstName']} ${userData['lastName']}";
                  } else if (user != null && user.email != null) {
                    displayName = user.email!.split('@').first;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
                // Yüklenirken veya Hata durumunda minimal görünüm
                loading: () => const Text('...'),
                error: (_, _) => Text(user?.email ?? ''),
              ),
            ),

            // Tıklanabilir göstergesi
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textPrimary.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Çıkış Yap butonu
  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Önce menüyü kapat
        ref.read(authServiceProvider).signOut(); // Sonra çıkış yap
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.expenseRed.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.expenseRed.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.expenseRed,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              l10n.logoutButton,
              style: const TextStyle(
                color: AppColors.expenseRed,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menü elemanı oluşturucu yardımcı fonksiyon
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () {
        Navigator.pop(context); // Sayfayı açmadan önce menüyü kapat
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}
