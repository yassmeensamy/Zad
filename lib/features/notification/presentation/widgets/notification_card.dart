import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/app_card.dart';
import '../../../../theme/theme.dart';
import '../../data/models/notification_model.dart';

/// A single notification row. Type-driven accent color paints the icon
/// medallion while the rest of the card stays in the warm canvas palette.
/// Unread rows carry a small accent dot and slightly stronger weight.
/// Swiping reveals [onDelete].
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
    final isUnread = !notification.isRead;
    final textScaler = MediaQuery.textScalerOf(context);

    final card = AppCard.flat(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? '',
                        textScaler: textScaler,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 15,
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w600,
                          height: 1.3,
                          color: colors.oliveDeep,
                        ),
                      ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (notification.messageBody != null &&
                    notification.messageBody!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.messageBody!,
                    textScaler: textScaler,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      height: 1.45,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                if (notification.sentAt != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      timeago.format(
                        notification.sentAt!,
                        locale: context.locale.languageCode,
                      ),
                      textScaler: textScaler,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 11,
                        letterSpacing: 0,
                        color: colors.textTertiary,
                      ),
                    ),
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
