import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/screens/wrapper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyBudgetFlow()));
}

class MyBudgetFlow extends StatelessWidget {
  const MyBudgetFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Budget Flow',

      theme: AppTheme.lightTheme,
      // .Takvimin ve diğer bileşenlerin Türkçe olması için eklendi
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // .Turkish
        Locale('en', 'US'), // English
      ],
      locale: const Locale('tr', 'TR'),

      // Wrapper'a yönlendir
      home: const AuthWrapper(),
    );
  }
}
