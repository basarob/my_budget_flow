import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../services/auth_service.dart';

import 'login_screen.dart';
import '../../home/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Kullanıcının oturum durumunu dinle (authStateChangesProvider)
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      // 1. Durum: Yükleniyor
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      // 2. Durum: Hata
      error: (err, stack) => Scaffold(
        body: Center(child: Text(l10n.errorGeneric(err.toString()))),
      ),

      // 3. Durum: Veri geldi
      data: (user) {
        if (user == null) {
          // Kullanıcı yok -> Giriş Ekranına git
          return const LoginScreen();
        } else {
          // Kullanıcı var -> Ana Ekrana git
          return const BudgetScreen();
        }
      },
    );
  }
}
