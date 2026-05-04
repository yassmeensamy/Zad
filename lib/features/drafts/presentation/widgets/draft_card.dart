import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/draft_model.dart';

class DraftCard extends StatelessWidget {
  const DraftCard({
    super.key,
    required this.draft,
    this.onTap,
    this.onDelete,
    this.isMutating = false,
  });

  final DraftModel draft;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isMutating;

  @override
  Widget build(BuildContext context) {
    final card = _DraftLayout(
      question: draft.question.text,
      note: draft.note,
      createdAt: draft.createdAt,
      isMutating: isMutating,
      onTap: onTap,
    );

    if (onDelete == null) return card;

    return Slidable(
      key: ValueKey(draft.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.18,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete!.call(),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.24),
                ),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
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

class DraftCardSkeleton extends StatelessWidget {
  const DraftCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => _DraftLayout(
        question: 'A placeholder draft question that fills two lines.',
        note: 'A placeholder note line for the saved draft.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
        isMutating: false,
      );
}

class _DraftLayout extends StatelessWidget {
  const _DraftLayout({
    required this.question,
    required this.note,
    required this.createdAt,
    required this.isMutating,
    this.onTap,
  });

  final String question;
  final String? note;
  final DateTime? createdAt;
  final bool isMutating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final trimmedNote = note?.trim();
    final hasNote = trimmedNote != null && trimmedNote.isNotEmpty;
    final radius = BorderRadius.circular(ZaadRadii.card);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: radius,
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ResponsiveText(
                        question,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: colors.oliveDeep,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _Trailing(
                      isMutating: isMutating,
                      color: colors.accentDeep,
                    ),
                  ],
                ),
                if (hasNote) ...[
                  const SizedBox(height: 12),
                  _Note(text: trimmedNote),
                ],
                const SizedBox(height: 12),
                _Footer(createdAt: createdAt),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.isMutating, required this.color});

  final bool isMutating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (isMutating) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Icon(Icons.bookmark_rounded, size: 18, color: color);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.createdAt});

  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = AppTextStyles.labelMedium.copyWith(
      fontSize: 11,
      letterSpacing: 0,
      color: colors.textTertiary,
    );
    return Row(
      children: [
        Icon(
          Icons.touch_app_outlined,
          size: 12,
          color: colors.textTertiary,
        ),
        const SizedBox(width: 6),
        ResponsiveText('drafts.view_details', style: style),
        const Spacer(),
        if (createdAt != null)
          ResponsiveText(
            timeago.format(createdAt!, locale: context.locale.languageCode),
            style: style,
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                height: 1.45,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
