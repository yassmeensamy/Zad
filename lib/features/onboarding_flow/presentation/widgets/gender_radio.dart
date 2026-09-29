import 'package:flutter/material.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Radio-style gender selector: two stacked, tappable tiles each with a
/// custom olive radio indicator, an icon, and a label. The selected tile
/// highlights its border/fill; the indicator animates between options.
class GenderRadioGroup extends StatelessWidget {
  const GenderRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.maleLabel,
    required this.femaleLabel,
  });

  final Gender? value;
  final ValueChanged<Gender?> onChanged;
  final String maleLabel;
  final String femaleLabel;

  void _toggle(Gender gender) => onChanged(value == gender ? null : gender);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderRadioTile(
            label: maleLabel,
            selected: value == Gender.male,
            onTap: () => _toggle(Gender.male),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderRadioTile(
            label: femaleLabel,
            selected: value == Gender.female,
            onTap: () => _toggle(Gender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderRadioTile extends StatelessWidget {
  const _GenderRadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZaadRadii.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 10),
              Expanded(
                child: ResponsiveText(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    letterSpacing: 0,
                    color: colors.oliveDeep,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.olive : colors.oliveSoft.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: selected ? 1 : 0,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.olive,
            ),
          ),
        ),
      ),
    );
  }
}
