import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

enum TicketStatusEnum {
  pending(apiValue: 'PENDING', labelKey: 'support_tickets.status.pending'),
  open(apiValue: 'OPEN', labelKey: 'support_tickets.status.open'),
  inReview(
    apiValue: 'IN_REVIEW',
    labelKey: 'support_tickets.status.in_review',
  ),
  resolved(apiValue: 'RESOLVED', labelKey: 'support_tickets.status.resolved'),
  closed(apiValue: 'CLOSED', labelKey: 'support_tickets.status.closed'),
  closedByUser(
    apiValue: 'CLOSED_BY_USER',
    labelKey: 'support_tickets.status.closed_by_user',
  );

  const TicketStatusEnum({required this.apiValue, required this.labelKey});

  final String apiValue;
  final String labelKey;

  String toApi() => apiValue;

  bool get isClosed =>
      this == TicketStatusEnum.closed ||
      this == TicketStatusEnum.closedByUser;

  Color color(AppColorsTheme colors) => switch (this) {
        TicketStatusEnum.pending => colors.warning,
        TicketStatusEnum.open => colors.info,
        TicketStatusEnum.inReview => colors.accent,
        TicketStatusEnum.resolved => colors.success,
        TicketStatusEnum.closed => colors.textTertiary,
        TicketStatusEnum.closedByUser => colors.textTertiary,
      };

  static TicketStatusEnum fromApi(String? value) =>
      TicketStatusEnum.values.firstWhere(
        (e) => e.apiValue == value,
        orElse: () => TicketStatusEnum.pending,
      );
}
