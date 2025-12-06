import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

class BudgetdashScreen extends ConsumerWidget {
  const BudgetdashScreen({super.key});

  @override
  // WidgetRef ref: Riverpod provider'larına erişim sağlayan anahtarımız.
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ana Ekran"),
        actions: [
          // Çıkış Yap Butonu (Sağ üstteki ikon)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // AuthService'i çağır ve signOut fonksiyonunu çalıştır.
              ref.read(authServiceProvider).signOut();
            },
            tooltip: "Çıkış Yap",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pie_chart,
              size: 100,
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 20),
            Text(
              "Hoşgeldin!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Bütçe akışını yönetmeye başlamak için hazırsın.\nVeriler ve grafikler yakında burada olacak.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
