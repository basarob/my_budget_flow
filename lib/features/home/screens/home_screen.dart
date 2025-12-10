import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';

import '../../appbar/screens/about_app_screen.dart';
import '../../appbar/screens/profile_screen.dart';
import '../../appbar/screens/settings_screen.dart';
import '../../appbar/screens/notifications_screen.dart';
import '../../calendar/screens/calendar_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../goals/screens/goals_screen.dart';
import '../../transactions/screens/transactions_screen.dart';

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

      drawerScrimColor: Colors.transparent,
      endDrawer: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 60.0, right: 3.0),
          child: SizedBox(
            height: 200,
            child: Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                side: BorderSide(color: Colors.white, width: 2),
              ),
              backgroundColor: AppColors.primaryDark,
              width: 160,
              child: customDrawer(context),
            ),
          ),
        ),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
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
        // ! Ekleme yapmadan önce yüksekliği büyüt.
        _buildDrawerItem(
          context,
          Icons.person_outline,
          'Profil',
          const ProfileScreen(),
        ),
        _buildDrawerItem(
          context,
          Icons.settings_outlined,
          'Ayarlar',
          const SettingsScreen(),
        ),
        _buildDrawerItem(
          context,
          Icons.info_outline,
          'Hakkında',
          const AboutAppScreen(),
        ),

        const Spacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.0),
          child: Divider(color: Colors.white54, height: 10),
        ),

        Padding(
          padding: const EdgeInsets.all(11.0),
          child: Material(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pop(context);
                ref.read(authServiceProvider).signOut();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppColors.blueRed),
                    const SizedBox(width: 9),
                    const Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueRed,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// !Drawer butonları
Widget _buildDrawerItem(
  BuildContext context,
  IconData icon,
  String title,
  Widget page,
) {
  return ListTile(
    dense: true,
    visualDensity: VisualDensity.compact,
    leading: Icon(icon, color: Colors.white),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
    ),
    textColor: Colors.white,
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    },
  );
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
