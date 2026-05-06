import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ZaadCircleIconButton extends StatelessWidget {
  const ZaadCircleIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.enabled = true,
    this.size = 38,
    this.iconSize = 20,
  });

  const factory ZaadCircleIconButton.back({
    Key? key,
    required VoidCallback onTap,
    bool enabled,
    double size,
    double iconSize,
  }) = _ZaadBackButton;

  const factory ZaadCircleIconButton.close({
    Key? key,
    required VoidCallback onTap,
    bool enabled,
    double size,
    double iconSize,
  }) = _ZaadCloseButton;

  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;
  final double size;
  final double iconSize;

  IconData resolveIcon(BuildContext context) => icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.white.withValues(alpha: 0.6),
      shape: CircleBorder(
        side: BorderSide(
          color: colors.olive.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            resolveIcon(context),
            size: iconSize,
            color: colors.oliveDeep,
          ),
        ),
      ),
    );
  }
}

class _ZaadBackButton extends ZaadCircleIconButton {
  const _ZaadBackButton({
    super.key,
    required super.onTap,
    super.enabled = true,
    super.size = 38,
    super.iconSize = 20,
  }) : super(icon: Icons.chevron_left_rounded);

  @override
  IconData resolveIcon(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl
          ? Icons.chevron_right_rounded
          : Icons.chevron_left_rounded;
}

class _ZaadCloseButton extends ZaadCircleIconButton {
  const _ZaadCloseButton({
    super.key,
    required super.onTap,
    super.enabled = true,
    super.size = 30,
    super.iconSize = 14,
  }) : super(icon: Icons.close_rounded);
}
