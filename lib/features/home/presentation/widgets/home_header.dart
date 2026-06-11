import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../teams/presentation/widgets/team_number_one_dialog.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.firstName,
    this.onBellTap,
    this.unreadCount = 0,
  });

  final String? firstName;
  final VoidCallback? onBellTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name =
        (firstName?.trim().isNotEmpty ?? false) ? firstName!.trim() : 'Zayd';
    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'home.greeting_morning'
        : hour < 18
        ? 'home.greeting_afternoon'
        : 'home.greeting_evening';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BrandGradients.crest(
              [colors.accentSoft, colors.accent, colors.accentDeep],
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
                'home.salam_arabic'.tr(),
                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.2,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              ResponsiveText(
                '${greetingKey.tr()} $name',
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
          onTap: () => TeamNumberOneCelebrationDialog.show(context: context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.overlayLight,
              border: Border.all(color: colors.borderSubtle),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.emoji_events_outlined,
              size: 19,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
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
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              backgroundColor: colors.accent,
              textColor: colors.goldInk,
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
