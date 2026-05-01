import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/textforms/main_text_form.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../cubit/edit_profile_form_cubit.dart';
import '../cubit/edit_profile_form_state.dart';

class EditProfileForm extends StatelessWidget {
  const EditProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      children: [
        const _CardAvatar(),
        const SizedBox(height: 20),
        _FieldGroup(
          label: 'edit_profile.name_label',
          child: const _NameField(),
        ),
        const SizedBox(height: 14),
        _FieldGroup(
          label: 'edit_profile.email_label',
          helper: 'edit_profile.email_locked',
          child: BlocSelector<UserCubit, UserState, String?>(
            selector: (state) => state.user?.email,
            builder: (context, email) => _ReadOnlyField(
              icon: Icons.mail_outline_rounded,
              text: email ?? '—',
            ),
          ),
        ),
        const SizedBox(height: 14),
        _FieldGroup(
          label: 'edit_profile.birthday_label',
          child: BlocSelector<
            EditProfileFormCubit,
            EditProfileFormState,
            DateTime?
          >(
            selector: (state) => state.updatedUser?.birthDate,
            builder: (context, date) => _BirthDateField(
              birthDate: date,
              onTap: () => _pickBirthDate(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final formCubit = context.read<EditProfileFormCubit>();
    final current = formCubit.state.updatedUser?.birthDate;
    final now = DateTime.now();
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (_) => _CupertinoDatePickerSheet(
        initialDate: current ?? DateTime(now.year - 25, now.month, now.day),
        minDate: DateTime(1900),
        maxDate: now,
      ),
    );
    if (picked != null && context.mounted) {
      formCubit.setBirthDate(picked);
    }
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  const _FieldGroup({
    required this.label,
    required this.child,
    this.helper,
  });

  final String label;
  final Widget child;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4),
          child: ResponsiveText(
            label,
            style: ZaadType.sectionLabel.copyWith(
              letterSpacing: 0.4,
              color: colors.oliveDeep,
            ),
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: ResponsiveText(
              helper!,
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CardAvatar extends StatelessWidget {
  const _CardAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (a, b) => a.user?.fullName != b.user?.fullName,
      builder: (context, state) {
        final name = state.user?.fullName ?? '';
        final initial = name.isNotEmpty ? name.characters.first : '؟';
        return Center(
          child: Container(
            width: 72,
            height: 72,
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
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colors.canvas,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NameField extends StatefulWidget {
  const _NameField();

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final formCubit = context.read<EditProfileFormCubit>();
    _controller = TextEditingController(
      text: formCubit.state.updatedUser?.fullName ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formCubit = context.read<EditProfileFormCubit>();
    return MainTextFormField(
      controller: _controller,
      hintText: 'edit_profile.name_hint'.tr(),
      textCapitalization: TextCapitalization.words,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      onChanged: formCubit.setName,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'please_enter_your_name'.tr();
        }
        if (value.trim().length > 60) {
          return 'full_name_max_length'.tr();
        }
        return null;
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
        : 'edit_profile.birthday_hint'.tr();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZaadRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              Icon(
                Icons.cake_outlined,
                size: 18,
                color: colors.oliveDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ResponsiveText(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

class _CupertinoDatePickerSheet extends StatefulWidget {
  const _CupertinoDatePickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<_CupertinoDatePickerSheet> createState() =>
      _CupertinoDatePickerSheetState();
}

class _CupertinoDatePickerSheetState extends State<_CupertinoDatePickerSheet> {
  static const _pickerHeight = 320.0;
  static const _headerHeight = 50.0;

  late DateTime _selectedDate;
  bool _userChanged = false;

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
    return Container(
      height: _pickerHeight,
      color: colors.canvas,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: _headerHeight,
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: ResponsiveText(
                      'common.cancel',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_userChanged ? _selectedDate : null),
                    child: ResponsiveText(
                      'common.done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.olive,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: widget.minDate,
                maximumDate: widget.maxDate,
                onDateTimeChanged: (date) => setState(() {
                  _selectedDate = date;
                  _userChanged = true;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
