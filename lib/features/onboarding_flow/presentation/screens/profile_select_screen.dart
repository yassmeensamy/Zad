import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../child/models/child_model.dart';
import '../../../child/presentation/cubit/child_cubit.dart';
import '../../../child/presentation/cubit/child_state.dart';
import '../../../splash/widgets/desert_background.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../data/child_avatar.dart';
import '../../data/profile_entity.dart';
import '../widgets/onboarding_topnav.dart';
import '../widgets/profile_card.dart';

/// Quranic opening phrase. Rendered identically in every locale, so it lives
/// in source rather than the translation files.
const String _basmala = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  void _onSelectEntry(BuildContext context, ProfileEntity entry) {
    if (entry.isParent) {
      context.go(AppRoutes.home);
      return;
    }
    final childId = entry.childId;
    if (childId == null) return;
    context.read<AuthCubit>().switchAccount(childId);
  }

  void _onContinueWithCurrent(BuildContext context) {
    context.go(AppRoutes.home);
  }

  void _onAddChild(BuildContext context) {
    context.go(AppRoutes.createProfiles);
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (state.isLoggedIn) {
      context.go(AppRoutes.home);
      return;
    }
    if (state.isError && state.errorMessage != null) {
      SnackBarHelper.showError(context, message: state.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChildCubit>(
      create: (_) => sl<ChildCubit>()..fetchChildren(),
      // Builder pushes a context below the provider so `context.read` /
      // `context.watch` for ChildCubit resolves inside this same widget.
      child: Builder(builder: _buildScaffold),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        // Only react to a switch we initiated from this screen: the auth
        // status flips loading → loggedIn (success) or loading → error.
        listenWhen: (a, b) => a.isLoading && a.status != b.status,
        listener: _onAuthState,
        child: DesertBackground(
          child: SafeArea(
            child: Column(
              children: [
                const OnboardingTopNav(showBrand: true),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
                    child: Column(
                      children: [
                        _Heading(colors: colors),
                        const SizedBox(height: 24),
                        Expanded(
                          child: BlocBuilder<ChildCubit, ChildState>(
                            buildWhen: (a, b) =>
                                a.status != b.status ||
                                a.children.length != b.children.length,
                            builder: (context, state) {
                              if (state.isError) {
                                return ErrorState(
                                  message:
                                      state.errorMessage ??
                                      'children_list.load_failed',
                                  onRetry: () => context
                                      .read<ChildCubit>()
                                      .fetchChildren(),
                                );
                              }
                              final loading =
                                  state.isInitial || state.isLoading;
                              return BlocBuilder<AuthCubit, AuthState>(
                                buildWhen: (a, b) =>
                                    a.isLoading != b.isLoading,
                                builder: (context, authState) =>
                                    AbsorbPointer(
                                  absorbing: authState.isLoading,
                                  child: _ProfilesGrid(
                                    children: state.children,
                                    loading: loading || authState.isLoading,
                                    onSelectEntry: (entry) =>
                                        _onSelectEntry(context, entry),
                                    onAddChild: () => _onAddChild(context),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ContinueWithCurrentButton(
                          onTap: () => _onContinueWithCurrent(context),
                        ),
                        const SizedBox(height: 6),
                        Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: Text(
                            _basmala,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              color: colors.oliveDeep.withValues(alpha: 0.55),
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
      ),
    );
  }
}

class _ProfilesGrid extends StatelessWidget {
  const _ProfilesGrid({
    required this.children,
    required this.loading,
    required this.onSelectEntry,
    required this.onAddChild,
  });

  final List<ChildModel> children;
  final bool loading;
  final ValueChanged<ProfileEntity> onSelectEntry;
  final VoidCallback onAddChild;

  static const _mockEntries = <ProfileEntity>[
    ProfileEntity.placeholder(name: 'Parent Name', isParent: true),
    ProfileEntity.placeholder(name: 'Child One'),
    ProfileEntity.placeholder(name: 'Child Two'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final parentName = context.select<UserCubit, String?>(
      (c) => c.state.user?.fullName,
    );

    final entries = loading
        ? _mockEntries
        : <ProfileEntity>[
            ProfileEntity.parent(
              name: parentName?.trim().isNotEmpty == true
                  ? parentName!
                  : 'profile_select.role_parent'.tr(),
            ),
            for (var i = 0; i < children.length; i++)
              ProfileEntity.fromChildModel(
                children[i],
                avatar: ChildAvatar.values[i % ChildAvatar.values.length],
              ),
          ];

    return Skeletonizer(
      enabled: loading,
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adapt to phones (2), small tablets / landscape phones (3),
          // and large tablets (4). Aspect ratio nudges narrower on wider
          // tiles so vertical content (avatar + name + role + chip)
          // doesn't stretch into empty space.
          final width = constraints.maxWidth;
          final crossAxisCount = width >= 900
              ? 4
              : width >= 600
                  ? 3
                  : 2;
          final childAspectRatio = crossAxisCount >= 3 ? 0.78 : 0.72;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: entries.length + (loading ? 0 : 1),
            itemBuilder: (_, i) {
              if (!loading && i == entries.length) {
                return _AddTile(onTap: onAddChild);
              }
              final entry = entries[i];
              return ProfileCard(
                entry: entry,
                onTap: loading ? () {} : () => onSelectEntry(entry),
              );
            },
          );
        },
      ),
    );
  }
}

class _ContinueWithCurrentButton extends StatelessWidget {
  const _ContinueWithCurrentButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: ResponsiveText(
          'profile_select.continue_current_account',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: colors.oliveDeep,
            decoration: TextDecoration.underline,
            decorationColor: colors.oliveSoft.withValues(alpha: 0.6),
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
          'profile_select.eyebrow'.tr().toUpperCase(),
          style: ZaadType.eyebrow.copyWith(color: colors.oliveSoft),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: ResponsiveText(
            'profile_select.subtitle',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              height: 1.5,
              color: AppColors.dateSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ProfileTileShell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 96,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.6),
                border: Border.all(
                  color: colors.oliveSoft.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(Icons.add_rounded, size: 36, color: colors.olive),
            ),
          ),
          const SizedBox(height: 12),
          ResponsiveText(
            'profile_select.add_child',
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: colors.olive,
            ),
          ),
          // Reserves the height of role label + chip slot from
          // ProfileCard so both tiles end at the same vertical position.
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
