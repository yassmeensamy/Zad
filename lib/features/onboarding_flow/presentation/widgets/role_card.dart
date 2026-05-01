import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(ZaadRadii.xxl);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(22),
          constraints: const BoxConstraints(minHeight: 128),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 0.85 : 0.55),
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? colors.olive
                  : colors.oliveSoft.withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.oliveDeep.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.ivory, AppColors.dune],
                  ),
                  border: Border.all(
                    color: colors.oliveSoft.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(icon, size: 26, color: colors.oliveDeep),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveText(
                      label,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 22,
                        letterSpacing: -0.3,
                        height: 1,
                        color: colors.oliveDeep,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ResponsiveText(
                      desc,
                      style: AppTextStyles.bodySmall.copyWith(
                        height: 1.5,
                        color: AppColors.dateSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: selected ? colors.olive : colors.oliveSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
