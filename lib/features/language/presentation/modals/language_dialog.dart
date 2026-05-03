import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_close_button.dart';
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

  static const List<_LanguageOption> _availableLanguages = [
    _LanguageOption(
      native: 'English',
      english: 'English',
      code: 'en',
      flag: 'EN',
    ),
    _LanguageOption(
      native: 'العربية',
      english: 'Arabic',
      code: 'ar',
      flag: 'ع',
      isArabic: true,
    ),
  ];

  static Future<void> show(
    BuildContext context, {
    bool shouldSkipBackend = false,
    OnLanguageChangedCallback? onLanguageChanged,
  }) => CustomDialog.show<void>(
    context: context,
    radius: 24,
    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
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
                    const _LanguageHeader(),
                    const SizedBox(height: 14),
                    for (final lang in _availableLanguages) ...[
                      _LanguageTile(option: lang),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 6),
                    _SaveCtaButton(shouldSkipBackend: shouldSkipBackend),
                  ],
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: ZaadCloseButton(
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

class _LanguageOption {
  const _LanguageOption({
    required this.native,
    required this.english,
    required this.code,
    required this.flag,
    this.isArabic = false,
  });

  final String native;
  final String english;
  final String code;
  final String flag;
  final bool isArabic;
}

class _LanguageHeader extends StatelessWidget {
  const _LanguageHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          ResponsiveText(
            'language_eyebrow',
            textAlign: TextAlign.center,
            style: ZaadType.eyebrowSm.copyWith(color: colors.oliveSoft),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: ZaadType.titleAccent.copyWith(color: colors.oliveDeep),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${'language_title_lead'.tr()} '),
                  TextSpan(
                    text: 'language_title_accent'.tr(),
                    style: AppTextStyles.titleLarge.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colors.textArabic,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 28, height: 1, color: colors.accent),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.option});

  final _LanguageOption option;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LanguageCubit, LanguageState, String?>(
      selector: (s) => s.selectedLanguage,
      builder: (context, selectedCode) {
        final colors = context.appColors;
        final isSelected = selectedCode == option.code;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ZaadRadii.lg),
            onTap: () => context
                .read<LanguageCubit>()
                .updateCurrentLanguage(option.code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.5),
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
                  _FlagBadge(flag: option.flag, isArabic: option.isArabic),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.native,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: option.isArabic ? 18 : 16,
                            height: 1.1,
                            color: colors.oliveDeep,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.english,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            letterSpacing: 0.4,
                            color: colors.textArabic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CheckPill(selected: isSelected),
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
  const _FlagBadge({required this.flag, required this.isArabic});

  final String flag;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 34,
      height: 34,
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
      child: Text(
        flag,
        style: AppTextStyles.titleLarge.copyWith(
          fontSize: isArabic ? 18 : 13,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.olive : Colors.transparent,
        border: Border.all(
          color: selected
              ? colors.olive
              : colors.olive.withValues(alpha: 0.30),
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 12, color: colors.canvas)
          : null,
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
