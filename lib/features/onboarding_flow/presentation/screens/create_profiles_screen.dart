import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../data/child_avatar.dart';
import '../widgets/child_avatar_circle.dart';
import '../widgets/onboarding_topnav.dart';

class CreateProfilesScreen extends StatefulWidget {
  const CreateProfilesScreen({super.key});

  @override
  State<CreateProfilesScreen> createState() => _CreateProfilesScreenState();
}

class _CreateProfilesScreenState extends State<CreateProfilesScreen> {
  final List<ChildDraft> _kids = [ChildDraft()];

  ChildAvatar _nextAvatar() {
    final used = _kids.map((k) => k.avatar).toSet();
    return ChildAvatar.values.firstWhere(
      (a) => !used.contains(a),
      orElse: () => ChildAvatar.values.first,
    );
  }

  void _addKid() {
    setState(() => _kids.add(ChildDraft(avatar: _nextAvatar())));
  }

  void _removeKid(int index) {
    setState(() => _kids.removeAt(index));
  }

  Future<void> _pickAvatar(int index) async {
    final picked = await showModalBottomSheet<ChildAvatar>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AvatarPickerSheet(current: _kids[index].avatar),
    );
    if (picked != null && mounted) {
      setState(() => _kids[index].avatar = picked);
    }
  }

  void _continue() => context.go(AppRoutes.profileSelect);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: DesertBackground(
        child: SafeArea(
          child: Column(
            children: [
              OnboardingTopNav(
                onBack: () => context.go(AppRoutes.roleSelect),
                stepLabel: 'create_profiles.step'.tr(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Column(
                    children: [
                      _Heading(colors: colors),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _kids.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            if (i == _kids.length) {
                              return _AddKidTile(onTap: _addKid);
                            }
                            return _KidRow(
                              key: ValueKey(_kids[i].hashCode),
                              draft: _kids[i],
                              showRemove: _kids.length > 1,
                              onPickAvatar: () => _pickAvatar(i),
                              onRemove: () => _removeKid(i),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      AuthPrimaryButton(
                        label: 'common.continue',
                        onTap: _continue,
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _continue,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: ResponsiveText(
                            'create_profiles.skip',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.dateSoft,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveText(
          'create_profiles.eyebrow'.tr().toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 10 * 0.32,
            color: colors.oliveSoft,
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            style: GoogleFonts.fraunces(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              height: 1.15,
              color: colors.oliveDeep,
            ),
            children: [
              TextSpan(text: 'create_profiles.title_prefix'.tr()),
              TextSpan(
                text: 'create_profiles.title_accent'.tr(),
                style: GoogleFonts.fraunces(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: colors.textArabic,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'create_profiles.subtitle',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _KidRow extends StatelessWidget {
  const _KidRow({
    super.key,
    required this.draft,
    required this.showRemove,
    required this.onPickAvatar,
    required this.onRemove,
  });

  final ChildDraft draft;
  final bool showRemove;
  final VoidCallback onPickAvatar;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                onTap: onPickAvatar,
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
                          border: Border.all(
                            color: AppColors.ivory,
                            width: 2,
                          ),
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
                child: Row(
                  children: [
                    Expanded(
                      child: _MiniField(
                        label: 'create_profiles.name_label'.tr(),
                        hint: 'create_profiles.name_hint'.tr(),
                        initial: draft.name,
                        onChanged: (v) => draft.name = v,
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
                        onChanged: (v) => draft.age = v,
                      ),
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
                  onTap: onRemove,
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

class _AddKidTile extends StatelessWidget {
  const _AddKidTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.oliveSoft.withValues(alpha: 0.35),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 16, color: colors.olive),
              const SizedBox(width: 8),
              ResponsiveText(
                'create_profiles.add_child',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 12.5 * 0.18,
                  color: colors.olive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  const _AvatarPickerSheet({required this.current});
  final ChildAvatar current;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, -8),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colors.oliveSoft.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            ResponsiveText(
              'create_profiles.sheet_title',
              style: GoogleFonts.fraunces(
                fontSize: 20,
                color: colors.oliveDeep,
              ),
            ),
            const SizedBox(height: 4),
            ResponsiveText(
              'create_profiles.sheet_sub',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.dateSoft,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: ChildAvatar.values.length,
              itemBuilder: (_, i) {
                final a = ChildAvatar.values[i];
                final active = a == current;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(a),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active ? colors.olive : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: colors.olive.withValues(alpha: 0.15),
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ChildAvatarCircle(avatar: a, size: 60),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
