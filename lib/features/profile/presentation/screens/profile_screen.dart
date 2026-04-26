import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme.dart';
import '../../data/profile_section.dart';
import '../../data/profile_sections.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _remindersEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sections = profileSections(
      context,
      remindersEnabled: _remindersEnabled,
      onRemindersChanged: (v) => setState(() => _remindersEnabled = v),
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _ProfileHeader(colors: colors),
          const SizedBox(height: 18),
          _StatsRow(colors: colors),
          const SizedBox(height: 22),
          for (final section in sections) ...[
            _SectionLabel(textKey: section.titleKey, colors: colors),
            const SizedBox(height: 10),
            for (final item in section.items) _MenuTile(item: item),
            const SizedBox(height: 22),
          ],
          const _SignOutButton(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.accentSoft, colors.accent],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.25),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'ي',
            style: GoogleFonts.amiri(
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: colors.canvas,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'ياسمين',
          style: GoogleFonts.amiri(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: colors.textArabic,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'انضمّت في رمضان ١٤٤٦',
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.textArabic.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: colors.canvasRaised.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.textArabic.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const Expanded(child: _Stat(value: '٧', label: 'يوم متتالي')),
          _Divider(colors: colors),
          const Expanded(child: _Stat(value: '١٢٨', label: 'آية')),
          _Divider(colors: colors),
          const Expanded(child: _Stat(value: '٣٫٥٨٠', label: 'نقطة')),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: colors.textArabic.withValues(alpha: 0.14),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.accent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.textArabic.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.textKey, required this.colors});
  final String textKey;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        textKey.tr(),
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: colors.textArabic.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item});
  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasTrailingWidget = item.trailing != null;
    final hasTrailingText = item.trailingText != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.canvasRaised.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: item.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: hasTrailingWidget ? 10 : 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.textArabic.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: colors.accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.titleKey.tr(),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textArabic,
                    ),
                  ),
                ),
                if (hasTrailingText)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: Text(
                      item.trailingText!,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textArabic.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                if (hasTrailingWidget)
                  item.trailing!
                else
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: colors.textArabic.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.08),
          foregroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          'profile.sign_out'.tr(),
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
