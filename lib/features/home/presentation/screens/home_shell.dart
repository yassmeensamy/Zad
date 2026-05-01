import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/zaad_bottom_nav.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <ZaadBottomNavItem>[
    ZaadBottomNavItem(
      label: 'home_nav.home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    ZaadBottomNavItem(
      label: 'home_nav.learn',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
    ),
    ZaadBottomNavItem(
      label: 'home_nav.leaderboard',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
    ),
    ZaadBottomNavItem(
      label: 'home_nav.profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: ZaadBottomNav(
        items: _items,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
