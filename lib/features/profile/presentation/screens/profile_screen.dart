import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/profile_section.dart';
import '../../data/profile_sections.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sections = profileSections(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status && current.isNotLoggedIn,
      listener: (context, state) {
        context.goNamed(AppRoutes.loginName);
      },
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) => Stack(
            children: [
              _BackdropOrnament(colors: colors),
              ListView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
                physics: const BouncingScrollPhysics(),
                children: [
                  _MihrabHero(colors: colors, user: state.user),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: StarRule(color: colors.accent, starSize: 10),
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < sections.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _SectionLabel(
                        textKey: sections[i].titleKey,
                        colors: colors,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _SectionCard(items: sections[i].items),
                    ),
                    const SizedBox(height: 22),
                  ],
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _SignOutButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// BACKDROP — paper warmth + faint star tessellation behind the hero
// ─────────────────────────────────────────────────────────────────

class _BackdropOrnament extends StatelessWidget {
  const _BackdropOrnament({required this.colors});
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -40,
              right: -40,
              height: 320,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.95,
                    colors: [
                      colors.accentSoft.withValues(alpha: 0.20),
                      colors.canvas.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HERO — Mihrab arch with avatar nested inside, name + role beneath
// ─────────────────────────────────────────────────────────────────

class _MihrabHero extends StatelessWidget {
  const _MihrabHero({required this.colors, required this.user});
  final AppColorsTheme colors;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? '';
    final initial = name.isNotEmpty ? name.characters.first : '؟';
    final email = user?.email;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _AvatarMedallion(initial: initial, colors: colors),
          const SizedBox(height: 14),
          ResponsiveText(
            name.isEmpty ? '—' : name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.2,
              color: colors.oliveDeep,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 6),
            ResponsiveText(
              email,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12.5,
                letterSpacing: 0.2,
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _AvatarMedallion extends StatelessWidget {
  const _AvatarMedallion({required this.initial, required this.colors});
  final String initial;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.olive, colors.oliveDeep],
        ),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ResponsiveText(
        initial,
        style: AppTextStyles.displayMedium.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -0.4,
          color: colors.canvas,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION HEADER — Roman ordinal + label + extending gold rule
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.textKey, required this.colors});
  final String textKey;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Row(
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CustomPaint(
              painter: KhatimStarPainter(
                fill: colors.accent.withValues(alpha: 0.20),
                stroke: colors.accentDeep,
                strokeWidth: 0.7,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ResponsiveText(
            textKey,
            style: ZaadType.sectionLabel.copyWith(color: colors.oliveDeep),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECTION CARD — paper container with gold hairlines between rows
// ─────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.items});
  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.canvas, colors.canvasRaised],
        ),
        borderRadius: BorderRadius.circular(ZaadRadii.card),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.20),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZaadRadii.card),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              ProfileMenuTile(item: items[i]),
              if (i != items.length - 1)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 58,
                    end: 16,
                  ),
                  child: Container(
                    height: 0.6,
                    color: colors.accent.withValues(alpha: 0.14),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SIGN OUT — outlined danger pill (kept understated by intent)
// ─────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await CustomDialog.show<bool>(
      context: context,
      child: const _SignOutConfirmDialog(),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorColor.withValues(alpha: 0.28),
          width: 1.0,
        ),
        color: colors.canvas.withValues(alpha: 0.6),
      ),
      child: CustomButton.full(
        onTap: () => _confirmLogout(context),
        theme: CustomButtonTheme(
          height: 52,
          backgroundColor: Colors.transparent,
          textColor: errorColor,
          borderRadius: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 18, color: errorColor),
            const SizedBox(width: 10),
            ResponsiveText(
              'profile.sign_out',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignOutConfirmDialog extends StatelessWidget {
  const _SignOutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final errorColor = context.colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: errorColor.withValues(alpha: 0.10),
          ),
          child: Icon(
            Icons.logout_rounded,
            color: errorColor,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        ResponsiveText(
          'profile.sign_out_confirm_title',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText(
          'profile.sign_out_confirm_subtitle',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        CustomButton.full(
          onTap: () => Navigator.of(context).pop(true),
          theme: CustomButtonTheme(
            height: 48,
            backgroundColor: errorColor,
            textColor: colors.canvas,
            borderRadius: 14,
          ),
          child: ResponsiveText(
            'profile.sign_out_confirm_cta',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
              color: colors.canvas,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: ResponsiveText(
            'common.cancel',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
