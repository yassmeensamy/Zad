import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/force_update_dialog.dart';
import '../../../upgrade/presentation/cubit/upgrade_cubit.dart';
import '../../../upgrade/presentation/cubit/upgrade_state.dart';
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
      label: 'home_nav.categories',
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
    // Optional (dismissible) update check lives at the shell so it spans every
    // tab and survives branch switches; the blocking force-update path is
    // handled earlier at startup.
    // Read the locale here, not inside `create` — provider forbids inherited
    // widget lookups (context.locale) in the create callback.
    final languageCode = context.locale.languageCode;
    return BlocProvider<UpgradeCubit>(
      create: (_) =>
          sl<UpgradeCubit>()..checkForUpdate(languageCode: languageCode),
      child: BlocListener<UpgradeCubit, UpgradeState>(
        listenWhen: (previous, current) =>
            !previous.isUpdateAvailable && current.isUpdateAvailable,
        listener: _showUpgradeDialog,
        child: AppScaffold(
          extendBody: true,
          body: navigationShell,
          bottomNavigationBar: ZaadBottomNav(
            items: _items,
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, UpgradeState state) {
    final info = state.info;
    AppUpdateDialog.show(
      context,
      isForceUpdate: false,
      onUpdate: () => context.read<UpgradeCubit>().openStore(),
      currentVersion: info.installedVersion,
      newVersion: info.availableVersion,
      releaseNotes: info.releaseNotes,
    );
  }
}
