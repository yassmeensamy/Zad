import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

enum TeamTab { home, members, progress }

extension on TeamTab {
  String get route => switch (this) {
    TeamTab.home => AppRoutes.teamHomeName,
    TeamTab.members => AppRoutes.teamMembersName,
    TeamTab.progress => AppRoutes.teamProgressName,
  };

  String get label => switch (this) {
    TeamTab.home => 'teams.tabs.home',
    TeamTab.members => 'teams.tabs.members',
    TeamTab.progress => 'teams.tabs.progress',
  };

  IconData get icon => switch (this) {
    TeamTab.home => Icons.home_rounded,
    TeamTab.members => Icons.people_alt_outlined,
    TeamTab.progress => Icons.bar_chart_rounded,
  };
}

/// Cream-paper tab bar that sits inside the team-home/members/progress
/// screens, mirroring the design's `.tabbar` block.
class TeamTabBar extends StatelessWidget {
  const TeamTabBar({super.key, required this.active});

  final TeamTab active;

  void _go(BuildContext context, TeamTab tab) {
    if (tab == active) return;
    context.goNamed(tab.route);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: ZaadRadii.xlAll,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.creamSurfaceTop.withValues(alpha: 0.92),
                colors.creamSurfaceBottom.withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: colors.olive.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.oliveDeep.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              for (final tab in TeamTab.values)
                Expanded(
                  child: _TabItem(
                    tab: tab,
                    active: tab == active,
                    onTap: () => _go(context, tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final TeamTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = active ? colors.accentDeep : colors.oliveSoft;

    return InkWell(
      onTap: onTap,
      borderRadius: ZaadRadii.xlAll,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (active)
            Positioned(
              top: 0,
              child: Container(
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tab.icon, size: 18, color: fg),
              const SizedBox(height: 4),
              ResponsiveText(
                tab.label.tr().toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: fg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
