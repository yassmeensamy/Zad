import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../child/presentation/widgets/custom_modal.dart';
import '../cubit/language_cubit.dart';
import '../cubit/language_state.dart';

typedef OnLanguageChangedCallback =
    Future<void> Function(BuildContext context, String newLanguage);

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({
    super.key,
    this.shouldSkipBackend = true,
    this.onLanguageChanged,
  });

  final bool shouldSkipBackend;
  final OnLanguageChangedCallback? onLanguageChanged;

  static const List<_LanguageOption> _availableLanguages = [
    _LanguageOption(
      label: 'العربية',
      subtitle: 'Arabic',
      code: 'ar',
      flag: '🇸🇦',
    ),
    _LanguageOption(
      label: 'English',
      subtitle: 'الإنجليزية',
      code: 'en',
      flag: '🇬🇧',
    ),
  ];

  static Future<void> show(
    BuildContext context, {
    bool shouldSkipBackend = true,
    OnLanguageChangedCallback? onLanguageChanged,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => LanguageDialog(
      shouldSkipBackend: shouldSkipBackend,
      onLanguageChanged: onLanguageChanged,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocProvider(
      create: (_) =>
          LanguageCubit()..updateCurrentLanguage(context.locale.languageCode),
      child: BlocConsumer<LanguageCubit, LanguageState>(
        listener: _handleLanguageStateChange,
        builder: (context, state) => CustomModal(
          title: ResponsiveText(
            'language',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.oliveDeep,
            ),
          ),
          subtitle: ResponsiveText(
            'language_subtitle',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: colors.olive.withValues(alpha: 0.7),
            ),
          ),
          child: AbsorbPointer(
            absorbing: state.status.isLoading,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final lang in _availableLanguages) ...[
                  _buildLanguageItem(lang, state),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                _ActionButtons(shouldSkipBackend: shouldSkipBackend),
              ],
            ),
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const ResponsiveText('failed_to_update_language'),
          backgroundColor: context.appColors.warning,
        ),
      );
      context.read<LanguageCubit>().clearError();
    }
  }

  Widget _buildLanguageItem(_LanguageOption option, LanguageState state) =>
      BlocSelector<LanguageCubit, LanguageState, String?>(
        selector: (s) => s.selectedLanguage,
        builder: (context, selectedCode) => _LanguageItem(
          option: option,
          isSelected: selectedCode == option.code,
          isEnabled: !state.status.isLoading,
          onTap: () =>
              context.read<LanguageCubit>().updateCurrentLanguage(option.code),
        ),
      );
}

class _LanguageOption {
  const _LanguageOption({
    required this.label,
    required this.subtitle,
    required this.code,
    required this.flag,
  });

  final String label;
  final String subtitle;
  final String code;
  final String flag;
}

class _LanguageItem extends StatelessWidget {
  const _LanguageItem({
    required this.option,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isEnabled ? onTap : null,
        splashColor: colors.olive.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.oliveLeaf.withValues(alpha: 0.20),
                      colors.olive.withValues(alpha: 0.12),
                    ],
                  )
                : null,
            color: isSelected ? null : colors.canvas.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colors.olive.withValues(alpha: 0.45)
                  : colors.olive.withValues(alpha: 0.12),
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.olive.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _FlagBadge(flag: option.flag, isSelected: isSelected),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      option.label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? colors.oliveDeep
                            : colors.textArabic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ResponsiveText(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textArabic.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.olive : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? colors.olive
                        : colors.textArabic.withValues(alpha: 0.3),
                    width: 1.6,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: colors.canvas,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.flag, required this.isSelected});
  final String flag;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  colors.canvas,
                  colors.canvasRaised,
                ]
              : [
                  colors.canvasRaised.withValues(alpha: 0.8),
                  colors.canvas.withValues(alpha: 0.8),
                ],
        ),
        border: Border.all(
          color: colors.olive.withValues(alpha: isSelected ? 0.45 : 0.18),
          width: 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colors.olive.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(flag, style: const TextStyle(fontSize: 22)),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.shouldSkipBackend});

  final bool shouldSkipBackend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: BlocSelector<LanguageCubit, LanguageState, bool>(
            selector: (s) => s.status.isLoading,
            builder: (context, isLoading) => OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: colors.olive.withValues(alpha: 0.25),
                ),
              ),
              child: ResponsiveText(
                'cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.olive,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocSelector<LanguageCubit, LanguageState, LanguageState>(
            selector: (s) => s,
            builder: (context, state) {
              final selected = state.selectedLanguage;
              final canConfirm =
                  !state.status.isLoading &&
                  selected != null &&
                  selected != context.locale.languageCode;
              return ElevatedButton(
                onPressed: canConfirm
                    ? () => context.read<LanguageCubit>().updateLanguage(
                        selected,
                        shouldSkipBackend: shouldSkipBackend,
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.olive,
                  disabledBackgroundColor: colors.olive.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: state.status.isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.canvas,
                        ),
                      )
                    : ResponsiveText(
                        'change_language',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.canvas,
                        ),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
