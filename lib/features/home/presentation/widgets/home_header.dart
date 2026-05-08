import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.firstName,
    this.hasNotifications = true,
    this.onBellTap,
  });

  /// User's first name to weave into the greeting line.
  final String firstName;

  final bool hasNotifications;
  final VoidCallback? onBellTap;

  String _greetingKey() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home.greeting_morning';
    if (hour < 17) return 'home.greeting_afternoon';
    return 'home.greeting_evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '${_greetingKey().tr()} $firstName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.oliveDeep,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _BellButton(
            hasDot: hasNotifications,
            onTap: onBellTap,
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.hasDot, this.onTap});

  final bool hasDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.oliveDeep.withValues(alpha: 0.14),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 18,
                color: colors.oliveDeep,
              ),
              if (hasDot)
                Positioned(
                  top: 7,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accent,
                      border: Border.all(
                        color: colors.canvas,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
