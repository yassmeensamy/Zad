import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../onboarding_flow/data/child_avatar.dart';
import '../../../onboarding_flow/presentation/widgets/child_avatar_circle.dart';
import '../cubit/child_draft_cubit.dart';
import 'avatar_picker_sheet.dart';
import 'child_password_sheet.dart';
import 'password_pill.dart';

/// Card representing a single in-progress child draft inside the
/// create-profiles form. Shows the avatar, name + age fields, and a
/// password pill, plus a remove affordance when there's more than one
/// draft. All edits are pushed straight to [ChildDraftCubit].
class KidCard extends StatelessWidget {
  const KidCard({super.key, required this.draft, required this.showRemove});

  final ChildDraft draft;
  final bool showRemove;

  Future<void> _pickAvatar(BuildContext context) async {
    final cubit = context.read<ChildDraftCubit>();
    final picked = await showModalBottomSheet<ChildAvatar>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AvatarPickerSheet(current: draft.avatar),
    );
    if (picked != null) {
      cubit.update(draft.id, avatar: picked);
    }
  }

  Future<void> _editPassword(BuildContext context) async {
    final cubit = context.read<ChildDraftCubit>();
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChildPasswordSheet(
        childName: draft.name,
        initialPassword: draft.password,
      ),
    );
    if (picked != null) {
      cubit.update(draft.id, password: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cubit = context.read<ChildDraftCubit>();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.oliveSoft.withValues(alpha: 0.22)),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _pickAvatar(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.oliveSoft.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: ChildAvatarCircle(avatar: draft.avatar),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.olive,
                          border: Border.all(color: AppColors.ivory, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 11,
                          color: AppColors.ivory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MiniField(
                            label: 'create_profiles.name_label'.tr(),
                            hint: 'create_profiles.name_hint'.tr(),
                            initial: draft.name,
                            onChanged: (v) =>
                                cubit.update(draft.id, name: v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 78,
                          child: _MiniField(
                            label: 'create_profiles.age_label'.tr(),
                            hint: '7',
                            initial: draft.age,
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                cubit.update(draft.id, age: v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PasswordPill(
                      hasPassword: draft.hasPassword,
                      onTap: () => _editPassword(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showRemove)
            Positioned(
              top: -4,
              right: -4,
              child: Material(
                color: AppColors.date.withValues(alpha: 0.10),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => cubit.remove(draft.id),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: AppColors.dateSoft,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField({
    required this.label,
    required this.hint,
    required this.initial,
    required this.onChanged,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final String initial;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.oliveSoft.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveText(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 8 * 0.3,
              color: colors.oliveSoft,
            ),
          ),
          TextFormField(
            initialValue: initial,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: colors.oliveDeep,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 13.5,
                color: colors.oliveSoft.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
