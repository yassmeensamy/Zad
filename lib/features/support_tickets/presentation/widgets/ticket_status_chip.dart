import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../data/models/ticket_status_enum.dart';
import 'support_pill.dart';

class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip({super.key, required this.status});

  final TicketStatusEnum status;

  @override
  Widget build(BuildContext context) {
    return SupportPill(
      color: status.color(context.appColors),
      label: status.labelKey,
      dot: true,
    );
  }
}
