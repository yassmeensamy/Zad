import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.firstName, this.onBellTap});

  final String? firstName;
  final VoidCallback? onBellTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name =
        (firstName?.trim().isNotEmpty ?? false) ? firstName!.trim() : 'Zayd';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.36, -0.44),
              radius: 0.9,
              colors: [colors.accentSoft, colors.accent, colors.accentDeep],
              stops: const [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.45),
                spreadRadius: 1.5,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: ResponsiveText(
            name[0].toUpperCase(),
            style: AppTextStyles.headlineMedium.copyWith(
              height: 1,
              color: colors.goldInk,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                'Assalāmu ʿalaykum · 21 Dhū\'l-Qaʿdah',
                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.2,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                'Morning, $name.',
                style: AppTextStyles.displaySmall.copyWith(
                  fontSize: 20,
                  height: 1.1,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onBellTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.overlayLight,
              border: Border.all(color: colors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Badge(
              smallSize: 7,
              backgroundColor: colors.accent,
              child: Icon(
                Icons.notifications_none_rounded,
                size: 19,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
