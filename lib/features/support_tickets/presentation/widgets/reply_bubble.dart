import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../data/models/reply_model.dart';
import 'conversation_bubble.dart';

class ReplyBubble extends StatelessWidget {
  const ReplyBubble({super.key, required this.reply});

  final ReplyModel reply;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isAdmin = reply.adminReply;
    return ConversationBubble(
      authorLabel: isAdmin
          ? 'support_tickets.detail.from_admin'
          : 'support_tickets.detail.from_you',
      body: reply.content,
      accent: isAdmin ? colors.olive : colors.accent,
      icon: isAdmin
          ? Icons.support_agent_rounded
          : Icons.person_outline_rounded,
      side: isAdmin ? BubbleSide.right : BubbleSide.left,
      createdAt: reply.createdAt,
    );
  }
}
