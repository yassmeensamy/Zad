import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/choice_model.dart';

enum AnswerChoiceVisualState {
  idle(
    reactDuration: Duration.zero,
    scaleAmplitude: 0,
    shakeAmplitude: 0,
    showsHalo: false,
    pulsesBadge: false,
    showsShadow: true,
  ),
  selected(
    reactDuration: Duration(milliseconds: 220),
    scaleAmplitude: -0.03,
    shakeAmplitude: 0,
    showsHalo: false,
    pulsesBadge: false,
    showsShadow: true,
  ),
  revealedCorrect(
    reactDuration: Duration(milliseconds: 540),
    scaleAmplitude: 0.045,
    shakeAmplitude: 0,
    showsHalo: true,
    pulsesBadge: true,
    showsShadow: true,
  ),
  revealedWrong(
    reactDuration: Duration(milliseconds: 540),
    scaleAmplitude: 0,
    shakeAmplitude: 7,
    showsHalo: false,
    pulsesBadge: false,
    showsShadow: true,
  ),
  revealedMuted(
    reactDuration: Duration.zero,
    scaleAmplitude: 0,
    shakeAmplitude: 0,
    showsHalo: false,
    pulsesBadge: false,
    showsShadow: false,
  );

  const AnswerChoiceVisualState({
    required this.reactDuration,
    required this.scaleAmplitude,
    required this.shakeAmplitude,
    required this.showsHalo,
    required this.pulsesBadge,
    required this.showsShadow,
  });

  final Duration reactDuration;
  final double scaleAmplitude;
  final double shakeAmplitude;
  final bool showsHalo;
  final bool pulsesBadge;
  final bool showsShadow;

  AnswerChoiceVisuals visuals(BuildContext context) {
    final colors = context.appColors;
    final wrong = context.colorScheme.error;
    return switch (this) {
      AnswerChoiceVisualState.idle => AnswerChoiceVisuals(
          bg: colors.canvasRaised,
          borderColor: colors.olive.withValues(alpha: 0.12),
          textColor: colors.textPrimary,
          badgeBg: colors.canvas,
          badgeFg: colors.textSecondary,
        ),
      AnswerChoiceVisualState.selected => AnswerChoiceVisuals(
          bg: Color.lerp(colors.canvasRaised, colors.olive, 0.10)!,
          borderColor: colors.olive.withValues(alpha: 0.55),
          textColor: colors.textPrimary,
          badgeBg: colors.olive.withValues(alpha: 0.16),
          badgeFg: colors.oliveDeep,
        ),
      AnswerChoiceVisualState.revealedCorrect => AnswerChoiceVisuals(
          bg: Color.lerp(colors.canvasRaised, colors.olive, 0.12)!,
          borderColor: colors.olive,
          textColor: colors.oliveDeep,
          badgeBg: colors.olive,
          badgeFg: colors.canvas,
          trailing:
              Icon(Icons.check_rounded, size: 16, color: colors.olive),
        ),
      AnswerChoiceVisualState.revealedWrong => AnswerChoiceVisuals(
          bg: Color.lerp(colors.canvasRaised, wrong, 0.14)!,
          borderColor: wrong,
          textColor: wrong,
          badgeBg: wrong,
          badgeFg: colors.canvas,
          trailing: Icon(Icons.close_rounded, size: 16, color: wrong),
        ),
      AnswerChoiceVisualState.revealedMuted => AnswerChoiceVisuals(
          bg: colors.canvasRaised.withValues(alpha: 0.55),
          borderColor: colors.borderSubtle,
          textColor: colors.textTertiary,
          badgeBg: colors.canvas,
          badgeFg: colors.textTertiary,
        ),
    };
  }
}

class AnswerChoiceVisuals {
  const AnswerChoiceVisuals({
    required this.bg,
    required this.borderColor,
    required this.textColor,
    required this.badgeBg,
    required this.badgeFg,
    this.trailing,
  });

  final Color bg;
  final Color borderColor;
  final Color textColor;
  final Color badgeBg;
  final Color badgeFg;
  final Widget? trailing;
}

class AnswerChoiceCard extends StatefulWidget {
  const AnswerChoiceCard({
    super.key,
    required this.choice,
    required this.label,
    required this.visualState,
    required this.onTap,
  });

  final ChoiceModel choice;
  final String label;
  final AnswerChoiceVisualState visualState;
  final VoidCallback? onTap;

  static String labelForIndex(int i) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    if (i >= 0 && i < letters.length) return letters[i];
    return '${i + 1}';
  }

  @override
  State<AnswerChoiceCard> createState() => _AnswerChoiceCardState();
}

class _AnswerChoiceCardState extends State<AnswerChoiceCard>
    with TickerProviderStateMixin {
  late final AnimationController _reactCtrl;
  late final AnimationController _haloCtrl;

  @override
  void initState() {
    super.initState();
    _reactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    );
    _haloCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
  }

  @override
  void didUpdateWidget(covariant AnswerChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualState == widget.visualState) return;

    final state = widget.visualState;
    if (state.reactDuration > Duration.zero) {
      _reactCtrl
        ..stop()
        ..duration = state.reactDuration
        ..forward(from: 0);
    }
    if (state.showsHalo) {
      _haloCtrl
        ..stop()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _reactCtrl.dispose();
    _haloCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final state = widget.visualState;
    final v = state.visuals(context);
    final bgTop = Color.lerp(v.bg, Colors.white, 0.05) ?? v.bg;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: ZaadRadii.xlAll,
        splashColor: colors.olive.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsetsDirectional.fromSTEB(11, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgTop, v.bg],
            ),
            borderRadius: ZaadRadii.lgAll,
            border: Border.all(color: v.borderColor, width: 0.9),
            boxShadow: state.showsShadow
                ? [
                    BoxShadow(
                      color: colors.oliveDeep.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              _AnimatedBadge(
                badgeBg: v.badgeBg,
                badgeFg: v.badgeFg,
                label: widget.label,
                shouldPulse: state.pulsesBadge,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.36,
                    color: v.textColor,
                  ),
                  child: Builder(
                    builder: (context) => ResponsiveText(
                      widget.choice.text,
                      style: DefaultTextStyle.of(context).style,
                    ),
                  ),
                ),
              ),
              if (v.trailing != null) ...[
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(state),
                    child: v.trailing!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: Listenable.merge([_reactCtrl, _haloCtrl]),
        builder: (context, child) {
          final t = _reactCtrl.value;
          final scale = (t == 0 || state.scaleAmplitude == 0)
              ? 1.0
              : 1 + math.sin(t * math.pi) * state.scaleAmplitude;
          final dx = (t == 0 || state.shakeAmplitude == 0)
              ? 0.0
              : math.sin(t * math.pi * 4) * (1 - t) * state.shakeAmplitude;
          return Stack(
            alignment: Alignment.center,
            children: [
              if (state.showsHalo)
                _CorrectHalo(
                  progress: _haloCtrl.value,
                  color: colors.olive,
                ),
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.scale(scale: scale, child: child),
              ),
            ],
          );
        },
        child: card,
      ),
    );
  }
}

class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({
    required this.badgeBg,
    required this.badgeFg,
    required this.label,
    required this.shouldPulse,
  });

  final Color badgeBg;
  final Color badgeFg;
  final String label;
  final bool shouldPulse;

  @override
  Widget build(BuildContext context) {
    final badgeTop = Color.lerp(badgeBg, Colors.white, 0.18) ?? badgeBg;
    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: 29,
      height: 29,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [badgeTop, badgeBg],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeBg.withValues(alpha: 0.28),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 220),
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: badgeFg,
        ),
        child: Builder(
          builder: (context) => ResponsiveText(
            label,
            style: DefaultTextStyle.of(context).style,
          ),
        ),
      ),
    );
    if (!shouldPulse) return badge;
    return TweenAnimationBuilder<double>(
      key: const ValueKey('correct-badge-pulse'),
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: badge,
    );
  }
}

class _CorrectHalo extends StatelessWidget {
  const _CorrectHalo({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (progress == 0 || progress >= 1) return const SizedBox.shrink();
    final eased = Curves.easeOutCubic.transform(progress);
    final fade = (1 - progress).clamp(0.0, 1.0) * 0.55;
    final scale = 0.96 + eased * 0.10;
    return Positioned.fill(
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: ZaadRadii.xlAll,
              border: Border.all(
                color: color.withValues(alpha: 0.85 * fade),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25 * fade),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
