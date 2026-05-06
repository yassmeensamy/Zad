import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';

enum SupportTopicEnum {
  feedback(
    label: 'help_center.topics.feedback.label',
    description: 'help_center.topics.feedback.description',
    icon: Icons.favorite_outline_rounded,
    apiValue: 'FEEDBACK',
  ),
  question(
    label: 'help_center.topics.question.label',
    description: 'help_center.topics.question.description',
    icon: Icons.help_outline_rounded,
    apiValue: 'QUESTION',
  ),
  bug(
    label: 'help_center.topics.bug.label',
    description: 'help_center.topics.bug.description',
    icon: Icons.bug_report_outlined,
    apiValue: 'BUG',
  ),
  technical(
    label: 'help_center.topics.technical.label',
    description: 'help_center.topics.technical.description',
    icon: Icons.tune_rounded,
    apiValue: 'TECHNICAL',
  );

  const SupportTopicEnum({
    required this.label,
    required this.description,
    required this.icon,
    required this.apiValue,
  });

  final String label;
  final String description;
  final IconData icon;
  final String apiValue;

  String toApi() => apiValue;

  Color accent(AppColorsTheme colors) => switch (this) {
        SupportTopicEnum.feedback => colors.accent,
        SupportTopicEnum.question => colors.olive,
        SupportTopicEnum.bug => colors.warning,
        SupportTopicEnum.technical => colors.info,
      };

  static SupportTopicEnum fromApi(String? value) =>
      SupportTopicEnum.values.firstWhere(
        (e) => e.apiValue == value,
        orElse: () => SupportTopicEnum.question,
      );

  static SupportTopicEnum fromName(String? name) =>
      SupportTopicEnum.values.firstWhere(
        (e) => e.name == name,
        orElse: () => SupportTopicEnum.question,
      );
}
