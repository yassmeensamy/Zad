import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
              const _BackdropOrnament(),
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                physics: const BouncingScrollPhysics(),
                children: [
                  _HeroCard(colors: colors, user: state.user),
                  const SizedBox(height: 28),
                  for (var i = 0; i < sections.length; i++) ...[
                    _SectionLabel(
                      textKey: sections[i].titleKey,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(items: sections[i].items),
                    const SizedBox(height: 24),
                  ],
                  const _SignOutButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackdropOrnament extends StatelessWidget {
  const _BackdropOrnament();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              left: -60,
              right: -60,
              height: 280,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.95,
                    colors: [
                      colors.oliveLeaf.withValues(alpha: 0.22),
                      colors.olive.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              right: -80,
              width: 220,
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.oliveLeaf.withValues(alpha: 0.10),
                      colors.olive.withValues(alpha: 0.0),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colors, required this.user});
  final AppColorsTheme colors;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? '';
    final initial = name.isNotEmpty ? name.characters.first : '؟';

    return Column(
      children: [
        _Avatar(initial: initial, colors: colors),
        const SizedBox(height: 14),
        ResponsiveText(
          name.isEmpty ? '—' : name,
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.oliveDeep,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.colors});
  final String initial;
  final AppColorsTheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.olive, colors.oliveDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.olive.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ResponsiveText(
        initial,
        style: GoogleFonts.amiri(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: colors.canvas,
        ),
      ),
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
      padding: const EdgeInsetsDirectional.only(start: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.oliveLeaf, colors.oliveDeep],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          ResponsiveText(
            textKey,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.items});
  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvas.withValues(alpha: 0.92),
            colors.canvasRaised.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.oliveDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              ProfileMenuTile(item: items[i]),
              if (i != items.length - 1)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 64),
                  child: Container(
                    height: 1,
                    color: colors.olive.withValues(alpha: 0.10),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

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
    final errorColor = context.colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomButton.full(
        onTap: () => _confirmLogout(context),
        theme: CustomButtonTheme(
          height: 52,
          backgroundColor: errorColor.withValues(alpha: 0.08),
          textColor: errorColor,
          borderRadius: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 18, color: errorColor),
            const SizedBox(width: 8),
            ResponsiveText(
              'profile.sign_out',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.oliveDeep,
          ),
        ),
        const SizedBox(height: 8),
        ResponsiveText(
          'profile.sign_out_confirm_subtitle',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
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
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.canvas,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: ResponsiveText(
            'common.cancel',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
