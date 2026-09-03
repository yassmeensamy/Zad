import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/accent_rich_title.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../auth/presentation/widgets/auth_primary_button.dart';
import '../../../auth/presentation/widgets/signup_success_dialog.dart';
import '../../../auth/presentation/widgets/zaad_text_field.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../data/country_model.dart';
import '../cubit/countries_cubit.dart';
import '../cubit/countries_state.dart';
import '../widgets/gender_radio.dart';
import '../widgets/onboarding_topnav.dart';

/// Collects the new user's profile details right after role selection.
/// Full name and email are pre-filled from the freshly created account; email
/// is locked, everything else is editable. On save the profile is persisted
/// and the flow continues to [nextDestination] (home, or the family setup).
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, required this.nextDestination});

  final String nextDestination;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;

  DateTime? _birthDate;
  Gender? _gender;
  int? _countryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserCubit>().state.user;
    logger.debug(
      '[apple-name] 6/6 complete-profile prefill → '
      'user=${user == null ? 'null' : 'loaded'}, '
      'fullName="${user?.fullName ?? ''}", email=${user?.email}',
    );
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _birthDate = user?.birthDate;
    _gender = user?.gender;
    _countryId = user?.countryId;
    _fullNameController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit =>
      _fullNameController.text.trim().isNotEmpty &&
      _birthDate != null &&
      _gender != null &&
      _countryId != null &&
      !_saving;

  /// Resolves the currently-selected [CountryModel] from the loaded list so the
  /// dropdown can render its localized name. Null until the list loads or while
  /// no country is chosen.
  CountryModel? _selectedCountry(List<CountryModel> countries) {
    for (final c in countries) {
      if (c.id == _countryId) return c;
    }
    return null;
  }

  void _onSave() {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null || _gender == null || _countryId == null) return;

    setState(() => _saving = true);
    context.read<UserCubit>().updateProfile(
      fullName: _fullNameController.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      countryId: _countryId,
    );
  }

  /// The save that lands here is also what flips the user to "profile
  /// complete", which the auth guard watches. `/complete-profile` is listed in
  /// [AppRouter.guardRoutes]'s `selfExitRoutes` so the guard leaves us in place
  /// instead of redirecting in the same frame — otherwise the dialog below
  /// would be torn down with the route before it could be seen. Continuing on
  /// to [CompleteProfileScreen.nextDestination] is therefore our job, once the
  /// user dismisses the dialog.
  Future<void> _onUpdateStatusChanged(
    BuildContext context,
    UserState state,
  ) async {
    if (state.isUpdateSuccess) {
      context.read<UserCubit>().resetUpdateStatus();
      await SignupSuccessDialog.show(
        context,
        titleAccentKey: 'complete_profile.success.title_accent',
        subtitleKey: 'complete_profile.success.subtitle',
        onClose: () => Navigator.of(context, rootNavigator: true).pop(),
      );
      if (!context.mounted) return;
      context.go(widget.nextDestination);
    } else if (state.isUpdateError) {
      setState(() => _saving = false);
      SnackBarHelper.showError(
        context,
        message: state.updateErrorMessage ?? 'complete_profile.save_failed',
      );
      context.read<UserCubit>().resetUpdateStatus();
    }
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (_) => _BirthDatePickerSheet(
        initialDate: _birthDate ?? now,
        minDate: DateTime(1900),
        maxDate: now,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final email = context.select<UserCubit, String?>(
      (c) => c.state.user?.email,
    );

    return BlocListener<UserCubit, UserState>(
      listenWhen: (a, b) => a.updateStatus != b.updateStatus,
      listener: _onUpdateStatusChanged,
      child: AppScaffold(
        body: SafeArea(
          child: Column(
            children: [
              OnboardingTopNav(
                stepLabel: 'complete_profile.step'.tr(),
                onBack: context.canPop() ? () => context.pop() : null,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Heading(colors: colors),
                        const SizedBox(height: 26),
                        _FieldLabel(label: 'complete_profile.full_name_label'),
                        const SizedBox(height: 8),
                        ZaadTextField(
                          hintText: 'complete_profile.full_name_hint',
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: colors.oliveSoft,
                            size: 20,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'complete_profile.full_name_required'.tr();
                            }
                            if (value.trim().length > 60) {
                              return 'full_name_max_length'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(label: 'complete_profile.email_label'),
                        const SizedBox(height: 8),
                        _ReadOnlyField(
                          icon: Icons.mail_outline_rounded,
                          text: email ?? '—',
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 4),
                          child: ResponsiveText(
                            'complete_profile.email_locked',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(label: 'complete_profile.birthday_label'),
                        const SizedBox(height: 8),
                        _BirthDateField(
                          birthDate: _birthDate,
                          onTap: _pickBirthDate,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(label: 'complete_profile.gender_label'),
                        const SizedBox(height: 8),
                        GenderRadioGroup(
                          value: _gender,
                          maleLabel: 'complete_profile.gender_male'.tr(),
                          femaleLabel: 'complete_profile.gender_female'.tr(),
                          onChanged: (g) => setState(() => _gender = g),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(label: 'complete_profile.country_label'),
                        const SizedBox(height: 8),
                        _CountryField(
                          selectedCountry: _selectedCountry,
                          onSelected: (c) =>
                              setState(() => _countryId = c.id),
                        ),
                        const SizedBox(height: 28),
                        AuthPrimaryButton(
                          label: 'complete_profile.continue',
                          onTap: _onSave,
                          enabled: _canSubmit,
                          loading: _saving,
                        ),
                      ],
                    ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ResponsiveText(
          'complete_profile.eyebrow'.tr().toUpperCase(),
          style: ZaadType.eyebrow.copyWith(color: colors.oliveSoft),
        ),
        const SizedBox(height: 14),
        AccentRichTitle(
          prefixKey: 'complete_profile.title_prefix',
          accentKey: 'complete_profile.title_accent',
          accentStyle: AppTextStyles.headlineMedium.copyWith(
            fontStyle: FontStyle.italic,
            color: colors.textArabic,
          ),
        ),
        const SizedBox(height: 10),
        ResponsiveText(
          'complete_profile.subtitle',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            height: 1.5,
            color: colors.dateSoft,
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: ResponsiveText(
        label,
        style: ZaadType.sectionLabel.copyWith(
          letterSpacing: 0.4,
          color: colors.oliveDeep,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.olive.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(ZaadRadii.lg),
        border: Border.all(
          color: colors.olive.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.olive.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Expanded(
            child: ResponsiveText(
              text,
              style: AppTextStyles.labelLarge.copyWith(
                letterSpacing: 0,
                color: colors.oliveDeep.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: colors.olive.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  const _BirthDateField({required this.birthDate, required this.onTap});

  final DateTime? birthDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasDate = birthDate != null;
    final label = hasDate
        ? DateFormat.yMMMd(context.locale.toLanguageTag()).format(birthDate!)
        : 'complete_profile.birthday_hint'.tr();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZaadRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: colors.canvas,
            borderRadius: BorderRadius.circular(ZaadRadii.lg),
            border: Border.all(
              color: colors.olive.withValues(alpha: 0.20),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.cake_outlined, size: 18, color: colors.oliveDeep),
              const SizedBox(width: 10),
              Expanded(
                child: ResponsiveText(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    letterSpacing: 0,
                    color: hasDate ? colors.oliveDeep : colors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: colors.olive.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Country dropdown backed by [CountriesCubit]. Shows a loading state while the
/// list is fetched and an inline retry when the fetch fails.
class _CountryField extends StatelessWidget {
  const _CountryField({
    required this.selectedCountry,
    required this.onSelected,
  });

  final CountryModel? Function(List<CountryModel> countries) selectedCountry;
  final ValueChanged<CountryModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountriesCubit, CountriesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdownField<CountryModel>(
              items: state.countries,
              value: selectedCountry(state.countries),
              loading: state.isLoading,
              enabled: state.isLoaded,
              prefixIcon: Icons.public_rounded,
              hintText: 'complete_profile.country_hint'.tr(),
              loadingLabel: 'complete_profile.country_loading'.tr(),
              sheetTitle: 'complete_profile.country_label'.tr(),
              searchHint: 'complete_profile.country_search_hint'.tr(),
              emptyLabel: 'complete_profile.country_empty'.tr(),
              itemLabel: (c) => c.displayName,
              onChanged: onSelected,
            ),
            if (state.isError) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => context.read<CountriesCubit>().fetchCountries(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: ResponsiveText(
                    'complete_profile.country_retry',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BirthDatePickerSheet extends StatefulWidget {
  const _BirthDatePickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<_BirthDatePickerSheet> createState() => _BirthDatePickerSheetState();
}

class _BirthDatePickerSheetState extends State<_BirthDatePickerSheet> {
  static const _pickerHeight = 240.0;
  static const _actionPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    var initial = widget.initialDate;
    if (initial.isBefore(widget.minDate)) initial = widget.minDate;
    if (initial.isAfter(widget.maxDate)) initial = widget.maxDate;
    _selectedDate = initial;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // The header grows with the OS text scale, so cap the wheel instead of
    // giving the sheet one fixed height that the header has to fit inside.
    final maxPickerHeight = MediaQuery.sizeOf(context).height * 0.42;
    return Container(
      color: colors.canvas,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.olive.withValues(alpha: 0.14),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: _actionPadding,
                    onPressed: () => Navigator.of(context).pop(),
                    child: ResponsiveText(
                      'common.cancel',
                      maxLines: 1,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: _actionPadding,
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedDate),
                    child: ResponsiveText(
                      'common.done',
                      maxLines: 1,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        color: colors.olive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: math.min(_pickerHeight, maxPickerHeight),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: widget.minDate,
                maximumDate: widget.maxDate,
                onDateTimeChanged: (date) =>
                    setState(() => _selectedDate = date),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
