import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/auth_service.dart';

import 'screens/login_screen.dart';
import '../budget/screens/budgetDash_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcının oturum durumunu dinle (authStateChangesProvider)
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      // 1. Durum: Firebase henüz yanıt vermedi (Yükleniyor)
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      // 2. Durum: Bir hata oluştu
      error: (err, stack) => Scaffold(body: Center(child: Text('Hata: $err'))),

      // 3. Durum: Veri geldi (Kullanıcı var ya da yok)
      data: (user) {
        if (user == null) {
          // Kullanıcı yok -> Giriş Ekranına git
          return const LoginScreen();
        } else {
          // Kullanıcı var -> Ana Ekrana git
          return const BudgetdashScreen();
        }
      },
    );
  }
}
