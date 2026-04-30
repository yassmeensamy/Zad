import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/notification_model.dart';

/// A single notification row. Type-driven accent color paints the icon
/// medallion while the rest of the card stays in the warm canvas palette.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = notification.notificationType.accent(colors);

    final card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconMedallion(
            icon: notification.notificationType.icon,
            color: accent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  notification.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.oliveDeep,
                    height: 1.3,
                  ),
                ),
                if (notification.messageBody != null &&
                    notification.messageBody!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ResponsiveText(
                    notification.messageBody,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (notification.createdAt != null)
                      Text(
                        timeago.format(
                          notification.createdAt!,
                          locale: context.locale.languageCode,
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onDelete == null) return card;

    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.14,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete!.call(),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Container(
              width: 44,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                  bottom: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.28),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
                semanticLabel: 'common.delete'.tr(),
              ),
            ),
          ),
        ],
      ),
      child: card,
    );
  }

}

class _IconMedallion extends StatelessWidget {
  const _IconMedallion({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: color),
    );
  }
}
