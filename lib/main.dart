import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/wrapper.dart';
import 'core/providers/language_provider.dart';
import 'core/widgets/connection_wrapper.dart';

/// Rota değişikliklerini algılamak için kullanılan global gözlemci (RouteAware widget'lar için).
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyBudgetFlow()));
}

class MyBudgetFlow extends ConsumerWidget {
  const MyBudgetFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLocale = ref.watch(languageProvider);

    // Dil yüklenirken veya hata oluşursa bir bekleme ekranı göster
    return asyncLocale.when(
      data: (currentLocale) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.lightTheme,
          locale: currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [
            routeObserver,
          ], // RouteAware widget'ları izlemek için
          home: const ConnectionWrapper(child: AuthWrapper()),
        );
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('Uygulama başlatılamadı: $err')),
        ),
      ),
    );
  }
}
