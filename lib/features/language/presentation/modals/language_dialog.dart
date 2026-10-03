import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_languages.dart';
import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_circle_button.dart';
import '../../../../core/widgets/zaad_dialog_header.dart';
import '../../../../core/widgets/zaad_primary_button.dart';
import '../../../../theme/theme.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';

typedef OnLanguageChangedCallback =
    Future<void> Function(BuildContext context, String newLanguage);

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    super.key,
    this.shouldSkipBackend = false,
    this.onLanguageChanged,
  });

  final bool shouldSkipBackend;
  final OnLanguageChangedCallback? onLanguageChanged;

  static Future<void> show(
    BuildContext context, {
    bool shouldSkipBackend = false,
    OnLanguageChangedCallback? onLanguageChanged,
  }) => CustomDialog.show<void>(
    context: context,
    radius: 24,
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
    scrollable: false,
    child: LanguageDialog(
      shouldSkipBackend: shouldSkipBackend,
      onLanguageChanged: onLanguageChanged,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<LanguageCubit>()..updateCurrentLanguage(context.locale.languageCode),
      child: BlocConsumer<LanguageCubit, LanguageState>(
        listener: _handleLanguageStateChange,
        builder: (context, state) {
          final loading = state.status.isLoading;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              AbsorbPointer(
                absorbing: loading,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ZaadDialogHeader(
                      eyebrowKey: 'language_eyebrow',
                      titleLeadKey: 'language_title_lead',
                      titleAccentKey: 'language_title_accent',
                    ),
                    const SizedBox(height: 14),
                    const Flexible(child: _LanguageGrid()),
                    const SizedBox(height: 14),
                    _SaveCtaButton(shouldSkipBackend: shouldSkipBackend),
                  ],
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: ZaadCircleIconButton.close(
                  enabled: !loading,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleLanguageStateChange(
    BuildContext context,
    LanguageState state,
  ) async {
    if (state.status.isSuccess && state.selectedLanguage != null) {
      final newLocale = Locale(state.selectedLanguage!);
      await context.setLocale(newLocale);
      if (!context.mounted) return;
      if (onLanguageChanged != null) {
        await onLanguageChanged!(context, state.selectedLanguage!);
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } else if (state.status.isError) {
      SnackBarHelper.showError(
        context,
        message: 'failed_to_update_language',
      );
      context.read<LanguageCubit>().clearError();
    }
  }
}

/// Two-column grid of compact tiles; scrolls on its own so the save CTA below
/// stays pinned. Rows use [IntrinsicHeight] so a wrapped name (e.g. "Bahasa
/// Indonesia") keeps both tiles in the row the same height.
class _LanguageGrid extends StatelessWidget {
  const _LanguageGrid();

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    const languages = AppLanguages.all;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < languages.length; i += 2) ...[
            if (i > 0) const SizedBox(height: _gap),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _LanguageTile(language: languages[i])),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: i + 1 < languages.length
                        ? _LanguageTile(language: languages[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LanguageCubit, LanguageState, String?>(
      selector: (s) => s.selectedLanguage,
      builder: (context, selectedCode) {
        final colors = context.appColors;
        final isSelected = selectedCode == language.code;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ZaadRadii.lg),
            onTap: () => context
                .read<LanguageCubit>()
                .updateCurrentLanguage(language.code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colors.inputSurface : colors.cardSurface,
                borderRadius: BorderRadius.circular(ZaadRadii.lg),
                border: Border.all(
                  color: isSelected
                      ? colors.olive
                      : colors.olive.withValues(alpha: 0.18),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.olive.withValues(alpha: 0.10),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _FlagBadge(
                        badge: language.badge,
                        usesArabicScript: language.usesArabicScript,
                      ),
                      PositionedDirectional(
                        bottom: -5,
                        end: -5,
                        child: _CheckPill(selected: isSelected),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ResponsiveText(
                      language.nativeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: language.usesArabicScript ? 16 : 14,
                        height: 1.15,
                        color: colors.oliveDeep,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.badge, required this.usesArabicScript});

  final String badge;
  final bool usesArabicScript;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ZaadRadii.sm),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.canvas,
            colors.canvasRaised,
          ],
        ),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: ResponsiveText(
        badge,
        style: AppTextStyles.titleLarge.copyWith(
          fontSize: usesArabicScript ? 18 : 13,
          height: 1,
          color: colors.oliveDeep,
        ),
      ),
    );
  }
}

class _CheckPill extends StatelessWidget {
  const _CheckPill({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Sits on the flag badge's corner, so it only appears once selected.
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1 : 0,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.olive,
          border: Border.all(color: colors.canvas, width: 1.5),
        ),
        child: Icon(Icons.check_rounded, size: 10, color: colors.canvas),
      ),
    );
  }
}

class _SaveCtaButton extends StatelessWidget {
  const _SaveCtaButton({required this.shouldSkipBackend});

  final bool shouldSkipBackend;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LanguageCubit, LanguageState, LanguageState>(
      selector: (s) => s,
      builder: (context, state) {
        final selected = state.selectedLanguage;
        final loading = state.status.isLoading;
        final canConfirm =
            !loading &&
            selected != null &&
            selected != context.locale.languageCode;

        return ZaadPrimaryButton(
          label: 'language_save_cta',
          loading: loading,
          enabled: canConfirm,
          onTap: () => context.read<LanguageCubit>().updateLanguage(
            selected!,
            shouldSkipBackend: shouldSkipBackend,
          ),
          height: 46,
          borderRadius: ZaadRadii.md,
          fontSize: 12,
          letterSpacing: 2.16,
        );
      },
    );
  }
}
