import 'package:flutter/material.dart';
import '../core/theme/zen_theme.dart';
import 'zen_hifz_screen.dart';
import 'halaqa_screen.dart';
import 'alarms_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _isFocusMode = false;

  void _onFocusChanged(bool isFocus) {
    setState(() {
      _isFocusMode = isFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sageColor = isDark ? ZenTheme.darkSage : ZenTheme.lightSage;

    final screens = [
      ZenHifzScreen(onFocusModeChanged: _onFocusChanged),
      const HalaqaScreen(),
      const AlarmsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _isFocusMode
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface,
              indicatorColor: sageColor.withValues(alpha: 0.2),
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'الحفظ والمصحف',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups),
                  label: 'حلقة الأصدقاء',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_active_outlined),
                  selectedIcon: Icon(Icons.notifications_active),
                  label: 'الجدول والمنبهات',
                ),
              ],
            ),
    );
  }
}
