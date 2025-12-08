import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

import '../../drawer/aboutapp_screen.dart';
import '../../drawer/profile_screen.dart';
import '../../drawer/settings_screen.dart';
import 'budCalendar_screen.dart';
import 'budDashboard_body.dart';
import 'budGoals_screen.dart';
import 'budTransactions_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardBody(),
    TransactionsScreen(),
    CalendarScreen(),
    GoalsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: budgetAppBar(_selectedIndex),

      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.50,
        child: customDrawer(context),
      ),

      body: _widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        child: SizedBox(
          height: 75,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: AppColors.primaryDark,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                _buildNavItem(Icons.home_outlined, Icons.home, 'Ana Menü', 0),
                _buildNavItem(
                  Icons.swap_horiz_outlined,
                  Icons.swap_horiz,
                  'İşlemler',
                  1,
                ),
                _buildNavItem(
                  Icons.calendar_today_outlined,
                  Icons.calendar_today,
                  'Takvim',
                  2,
                ),
                _buildNavItem(
                  Icons.track_changes_outlined,
                  Icons.track_changes,
                  'Hedefler',
                  3,
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              onTap: _onItemTapped,
              showSelectedLabels: true,
              showUnselectedLabels: true,
            ),
          ),
        ),
      ),
    );
  }

  // !NavBar
  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }

  // !AppBar
  AppBar budgetAppBar(int page) {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/icon/app_icon_white1.png'),
      ),
      title: Text(_getTitleForPage(page)),
      centerTitle: false,
      actions: [
        // Bildirimler butonu
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Bildirimler sayfası veya paneli açılacak.
          },
          tooltip: "Bildirimler",
        ),
        // Menü butonunu eklemesi.
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ],
    );
  }

  // !Drawer
  Column customDrawer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 63, 20, 20),
          color: AppColors.primaryDark,
          child: Text(
            'My Budget Flow',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Profil'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Ayarlar'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Hakkında'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutAppScreen()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, weight: 700),
          iconColor: AppColors.expenseRed,
          title: const Text(
            'Çıkış Yap',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          textColor: AppColors.expenseRed,
          onTap: () {
            Navigator.pop(context); // Önce menüyü kapat
            ref.read(authServiceProvider).signOut();
          },
        ),
      ],
    );
  }
}

// !AppBar Başlıkları
String _getTitleForPage(int page) {
  switch (page) {
    case 0:
      return 'Bütçe Akışım';
    case 1:
      return 'İşlemler';
    case 2:
      return 'Takvim';
    case 3:
      return 'Hedefler';
    default:
      return 'My Budget Flow';
  }
}
