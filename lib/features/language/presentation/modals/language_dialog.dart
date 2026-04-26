import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/custom_dialog.dart';
import '../../../../theme/theme.dart';
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
    _LanguageOption(label: 'العربية', subtitle: 'Arabic', code: 'ar'),
    _LanguageOption(label: 'English', subtitle: 'الإنجليزية', code: 'en'),
  ];

  static Future<void> show(
    BuildContext context, {
    bool shouldSkipBackend = true,
    OnLanguageChangedCallback? onLanguageChanged,
  }) => CustomDialog.show<void>(
    context: context,
    child: LanguageDialog(
      shouldSkipBackend: shouldSkipBackend,
      onLanguageChanged: onLanguageChanged,
    ),
  );

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        LanguageCubit()..updateCurrentLanguage(context.locale.languageCode),
    child: BlocConsumer<LanguageCubit, LanguageState>(
      listener: _handleLanguageStateChange,
      builder: (context, state) => AbsorbPointer(
        absorbing: state.status.isLoading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(),
            const SizedBox(height: 18),
            for (final lang in _availableLanguages) ...[
              _buildLanguageItem(lang, state),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 14),
            _ActionButtons(shouldSkipBackend: shouldSkipBackend),
          ],
        ),
      ),
    ),
  );

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
          content: Text('failed_to_update_language'.tr()),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.accent.withValues(alpha: 0.14),
          ),
          child: Icon(
            Icons.translate_rounded,
            color: colors.accent,
            size: 24,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'language'.tr(),
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textArabic,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'language_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: colors.textArabic.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.label,
    required this.subtitle,
    required this.code,
  });

  final String label;
  final String subtitle;
  final String code;
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
      color: isSelected
          ? colors.accentSoft.withValues(alpha: 0.22)
          : colors.canvas.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colors.accent.withValues(alpha: 0.5)
                  : colors.textArabic.withValues(alpha: 0.10),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.textArabic,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: GoogleFonts.cairo(
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
                  color: isSelected ? colors.accent : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? colors.accent
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
                  color: colors.textArabic.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textArabic.withValues(alpha: 0.75),
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
                  backgroundColor: colors.accent,
                  disabledBackgroundColor: colors.accent.withValues(
                    alpha: 0.4,
                  ),
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
                    : Text(
                        'change_language'.tr(),
                        style: GoogleFonts.cairo(
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
