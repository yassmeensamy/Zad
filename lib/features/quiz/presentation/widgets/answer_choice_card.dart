import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/theme.dart';
import '../../data/models/choice_model.dart';

enum AnswerChoiceVisualState {
  /// No answer locked in yet — choice is tappable.
  idle,

  /// User picked this choice (transient — feedback hasn't kicked in yet).
  selected,

  /// Answer locked in: this is the correct choice (always highlighted in green).
  revealedCorrect,

  /// Answer locked in: user picked this and it was wrong.
  revealedWrong,

  /// Answer locked in: a non-selected, non-correct choice (muted).
  revealedMuted,
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

    switch (widget.visualState) {
      case AnswerChoiceVisualState.selected:
        _reactCtrl
          ..stop()
          ..duration = const Duration(milliseconds: 220)
          ..forward(from: 0);
        break;
      case AnswerChoiceVisualState.revealedCorrect:
        _reactCtrl
          ..stop()
          ..duration = const Duration(milliseconds: 540)
          ..forward(from: 0);
        _haloCtrl
          ..stop()
          ..forward(from: 0);
        break;
      case AnswerChoiceVisualState.revealedWrong:
        _reactCtrl
          ..stop()
          ..duration = const Duration(milliseconds: 540)
          ..forward(from: 0);
        break;
      case AnswerChoiceVisualState.idle:
      case AnswerChoiceVisualState.revealedMuted:
        break;
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
    final wrongColor = context.colorScheme.error;

    final (bg, borderColor, textColor, badgeBg, badgeFg, trailing) = switch (
        widget.visualState) {
      AnswerChoiceVisualState.idle => (
          colors.canvasRaised,
          colors.borderSubtle,
          colors.textPrimary,
          colors.canvas,
          colors.textSecondary,
          null,
        ),
      AnswerChoiceVisualState.selected => (
          Color.lerp(colors.canvasRaised, colors.olive, 0.10)!,
          colors.olive.withValues(alpha: 0.55),
          colors.textPrimary,
          colors.olive.withValues(alpha: 0.16),
          colors.oliveDeep,
          null,
        ),
      AnswerChoiceVisualState.revealedCorrect => (
          Color.lerp(colors.canvasRaised, colors.olive, 0.12)!,
          colors.olive,
          colors.oliveDeep,
          colors.olive,
          colors.canvas,
          Icon(Icons.check_rounded, size: 18, color: colors.olive),
        ),
      AnswerChoiceVisualState.revealedWrong => (
          Color.lerp(colors.canvasRaised, wrongColor, 0.14)!,
          wrongColor,
          wrongColor,
          wrongColor,
          colors.canvas,
          Icon(Icons.close_rounded, size: 18, color: wrongColor),
        ),
      AnswerChoiceVisualState.revealedMuted => (
          colors.canvasRaised.withValues(alpha: 0.55),
          colors.borderSubtle,
          colors.textTertiary,
          colors.canvas,
          colors.textTertiary,
          null,
        ),
    };

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: ZaadRadii.xlAll,
        splashColor: colors.olive.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: const EdgeInsetsDirectional.fromSTEB(12, 14, 16, 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: ZaadRadii.xlAll,
            border: Border.all(color: borderColor, width: 0.9),
          ),
          child: Row(
            children: [
              _AnimatedBadge(
                badgeBg: badgeBg,
                badgeFg: badgeFg,
                label: widget.label,
                shouldPulse:
                    widget.visualState == AnswerChoiceVisualState.revealedCorrect,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: textColor,
                  ),
                  child: Text(widget.choice.text),
                ),
              ),
              if (trailing != null) ...[
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
                    key: ValueKey(widget.visualState),
                    child: trailing,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedBuilder(
        animation: Listenable.merge([_reactCtrl, _haloCtrl]),
        builder: (context, child) {
          final scale = _scaleFor(widget.visualState, _reactCtrl.value);
          final dx = _shakeFor(widget.visualState, _reactCtrl.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.visualState == AnswerChoiceVisualState.revealedCorrect)
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

  double _scaleFor(AnswerChoiceVisualState state, double t) {
    if (t == 0) return 1;
    switch (state) {
      case AnswerChoiceVisualState.selected:
        // Quick tap punch: 1 → 0.97 → 1
        return 1 - math.sin(t * math.pi) * 0.03;
      case AnswerChoiceVisualState.revealedCorrect:
        // Soft pulse up: 1 → 1.045 → 1
        return 1 + math.sin(t * math.pi) * 0.045;
      case AnswerChoiceVisualState.revealedWrong:
        // No scale; the shake handles it.
        return 1;
      case AnswerChoiceVisualState.idle:
      case AnswerChoiceVisualState.revealedMuted:
        return 1;
    }
  }

  double _shakeFor(AnswerChoiceVisualState state, double t) {
    if (state != AnswerChoiceVisualState.revealedWrong || t == 0) return 0;
    // 4 oscillations, decaying amplitude, peak ~7px.
    final decay = 1 - t;
    return math.sin(t * math.pi * 4) * decay * 7;
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
    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 220),
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: badgeFg,
        ),
        child: Text(label),
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

/// A green ring that expands and fades out around a correct answer.
class _CorrectHalo extends StatelessWidget {
  const _CorrectHalo({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (progress == 0 || progress >= 1) return const SizedBox.shrink();
    final eased = Curves.easeOutCubic.transform(progress);
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.55;
    final scale = 0.96 + eased * 0.10;
    return Positioned.fill(
      child: IgnorePointer(
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ZaadRadii.xlAll,
                border: Border.all(
                  color: color.withValues(alpha: 0.85),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
