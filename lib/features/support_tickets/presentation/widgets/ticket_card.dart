import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/relative_time.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/ticket_model.dart';
import 'support_pill.dart';
import 'ticket_status_chip.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({super.key, required this.ticket, this.onTap});

  final TicketModel ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = ticket.topic.accent(colors);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SupportPill(
                    color: accent,
                    label: ticket.topic.label,
                    icon: ticket.topic.icon,
                  ),
                  const Spacer(),
                  TicketStatusChip(status: ticket.status),
                ],
              ),
              const SizedBox(height: 12),
              ResponsiveText(
                ticket.title.isNotEmpty ? ticket.title : ticket.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: colors.oliveDeep,
                ),
              ),
              const SizedBox(height: 12),
              _Footer(
                createdAt: ticket.createdAt,
                replyCount: ticket.replyCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.createdAt, required this.replyCount});

  final DateTime? createdAt;
  final int replyCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = AppTextStyles.labelMedium.copyWith(
      fontSize: 11,
      letterSpacing: 0,
      color: colors.textTertiary,
    );

    final relative = formatRelative(context, createdAt);

    return Row(
      children: [
        if (relative != null) ...[
          Icon(Icons.schedule, size: 12, color: colors.textTertiary),
          const SizedBox(width: 4),
          ResponsiveText(relative, style: style),
        ],
        const Spacer(),
        Icon(
          Icons.forum_outlined,
          size: 12,
          color: colors.olive.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        ResponsiveText(
          'support_tickets.reply_count'
              .plural(replyCount, args: ['$replyCount']),
          style: style.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.olive,
          ),
        ),
      ],
    );
  }
}
