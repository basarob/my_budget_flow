import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_app_bar.dart';
import '../../appbar/screens/notifications_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../calendar/providers/calendar_provider.dart'; // Takvim Provider
import '../widgets/custom_drawer.dart';

/// Ana Ekran (Home Screen)
///
/// Uygulamanın temel iskeleti. Üstte Gradient AppBar, altta modern NavigationBar
/// ve sağdan açılan özel menü (CustomDrawer) bulunur.
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Uygulama başladığında düzenli işlem kontrolünü tetikle
    // Bu, vadesi gelen tekrarlayan işlemlerin otomatik olarak oluşturulmasını sağlar.
    Future.microtask(() {
      ref.read(transactionControllerProvider);
    });
  }

  // Sayfalar Listesi
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardBody(), // 0: Gösterge Paneli
    TransactionsScreen(), // 1: İşlemler
    CalendarScreen(), // 2: Takvim
    GoalsScreen(), // 3: Hedefler
  ];

  // Sayfa Değiştirme
  void _onItemTapped(int index) {
    // Sayfa değiştiğinde açık olan SnackBar'ları temizle (Örn: İşlem silindikten sonra geri al bildirimi)
    ScaffoldMessenger.of(context).clearSnackBars();

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: false,

      // 1. Üst Bar (Gradient Efektli)
      appBar: GradientAppBar(
        title: Text(
          _getTitleForPage(_selectedIndex, l10n),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'assets/icon/app_icon_white1.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          // Takvim Sayfası için "Bugün" Butonu
          if (_selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.today, color: Colors.white),
              tooltip: l10n.todayButtonTooltip,
              onPressed: () {
                // Takvimi bugüne getir
                final now = DateTime.now();
                ref.read(calendarProvider.notifier).selectDay(now);
                ref.read(calendarProvider.notifier).onPageChanged(now);
                HapticFeedback.mediumImpact();
              },
            ),

          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            tooltip: l10n.pageTitleNotifications,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),

      // Menü açılırken arka planı karartma
      drawerScrimColor: Colors.black54,

      // 2. Sağ Menü (Drawer)
      endDrawer: const CustomDrawer(),

      // 3. Ana İçerik
      body: _widgetOptions.elementAt(_selectedIndex),

      // 4. Alt Navigasyon (Modern Material 3)
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primaryDark,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.textSecondary,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: AppColors.surface, // Beyaz/Temiz zemin
          indicatorColor: AppColors.primaryLight.withOpacity(0.3), // Hap Rengi
          elevation: 2,
          shadowColor: Colors.black26,
          destinations: [
            NavigationDestination(
              icon: const Icon(
                Icons.home_outlined,
                color: AppColors.textSecondary,
              ),
              selectedIcon: const Icon(
                Icons.home,
                color: AppColors.primaryDark,
              ),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.swap_horiz_outlined,
                color: AppColors.textSecondary,
              ),
              selectedIcon: const Icon(
                Icons.swap_horiz,
                color: AppColors.primaryDark,
              ),
              label: l10n.navTransactions,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
              ),
              selectedIcon: const Icon(
                Icons.calendar_today,
                color: AppColors.primaryDark,
              ),
              label: l10n.navCalendar,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.track_changes_outlined,
                color: AppColors.textSecondary,
              ),
              selectedIcon: const Icon(
                Icons.track_changes,
                color: AppColors.primaryDark,
              ),
              label: l10n.navGoals,
            ),
          ],
        ),
      ),
    );
  }

  // Sayfa Başlığını Getir
  String _getTitleForPage(int page, AppLocalizations l10n) {
    switch (page) {
      case 0:
        return l10n.appTitle;
      case 1:
        return l10n.navTransactions;
      case 2:
        return l10n.navCalendar;
      case 3:
        return l10n.navGoals;
      default:
        return l10n.appTitle;
    }
  }
}
