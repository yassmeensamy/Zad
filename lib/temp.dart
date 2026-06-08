// Zad — Home · Date & Ember
//
// A self-contained Flutter recreation of the "Zad Date and Ember Home.html"
// design handed off from Claude Design. It reproduces the dark, roasted-brown
// "Date & Ember" home screen in its two states:
//
//   • State A — before joining a team (the "Walk the path together" join card)
//   • State B — inside a team (team summary card + daily verse)
//
// The week-streak card and the "begin answering" play CTA stay constant; only
// the team block transforms. A small segmented control lets you flip between
// the two states to mirror the side-by-side artboards in the original mock.
//
// This file deliberately depends on nothing in the rest of the app — it owns
// its palette, gradients and rising-ember animation — so it can be dropped in
// and run standalone:  home: const TempDateEmberHome().
//
// Font note: the mock uses Fraunces / Inter / Amiri / JetBrains Mono. Only
// ElMessiri ships with this project, so the Arabic uses ElMessiri and the
// display/mono roles fall back to the platform serif/monospace families.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'features/home/presentation/widgets/home_header.dart';
import 'features/home/presentation/widgets/home_verse_card.dart';

part 'temp_join_team_card.dart';
part 'temp_team_card.dart';

/// Date & Ember palette, lifted verbatim from the design's `:root` block.
class _C {
  static const base = Color(0xFF0E0905);
  static const surface = Color(0xFF1A120B);
  static const raised = Color(0xFF271A10);
  static const canvas = Color(0xFF140F0A);

  static const ivory = Color(0xFFF4ECD8);

  static const amber = Color(0xFFE0A560);
  static const amberLight = Color(0xFFF1C57A);
  static const amberDeep = Color(0xFFA6622A);

  static const ember = Color(0xFFC9512B);
  static const emberLight = Color(0xFFE07A48);
  static const emberDeepest = Color(0xFF9A3A1E);

  static const olive = Color(0xFF7A8A5A);

  static const glassBorder = Color(0x33E1A560); // rgba(225,165,96,0.20)
  static const hairline = Color(0x14F4ECD8); // rgba(244,236,216,0.08)
  static const txtMute = Color(0x9EF4ECD8); // rgba(244,236,216,0.62)
  static const txtFaint = Color(0x66F4ECD8); // rgba(244,236,216,0.40)

  static const ink = Color(0xFF2A1B0A); // ink over gold fills
  static const emberInk = Color(0xFF1A0E06); // ink over ember fills
}

/// Closest available font roles to the mock's pairing.
class _F {
  static const serif = 'serif'; // Fraunces stand-in (display italic)
  static const mono = 'monospace'; // JetBrains Mono stand-in (eyebrows)
  static const arabic = 'ElMessiri'; // Amiri stand-in (bundled)
}

enum _HomeState { noTeam, inTeam }

/// Entry point widget — a phone-scale Date & Ember home with a state toggle.
class TempDateEmberHome extends StatefulWidget {
  const TempDateEmberHome({super.key});

  @override
  State<TempDateEmberHome> createState() => _TempDateEmberHomeState();
}

class _TempDateEmberHomeState extends State<TempDateEmberHome> {
  _HomeState _state = _HomeState.inTeam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.canvas,
      body: Stack(
        children: [
          Positioned.fill(child: _ScreenBackground(state: _state)),
          // State toggle floats at the bottom, clear of the tab bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StateToggle(
                  state: _state,
                  onChanged: (s) => setState(() => _state = s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The roasted-brown radial screen background + amber wash + rising embers,
/// wrapping the scrollable home content and the floating tab bar.
class _ScreenBackground extends StatelessWidget {
  const _ScreenBackground({required this.state});

  final _HomeState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // .screen — radial(130% 55% at 50% -8%, raised → surface → base)
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.16),
          radius: 1.3,
          colors: [_C.raised, _C.surface, _C.base],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // .wash — warm amber light source glowing from above the top edge.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.78),
                radius: 0.85,
                colors: [Color(0x38E1A560), Color(0x00E1A560)],
                stops: [0.0, 0.65],
              ),
            ),
          ),
          // .embers — gold sparks drifting upward.
          const Positioned.fill(child: _Embers()),
          SafeArea(
            bottom: false,
            child: _HomeContent(state: state),
          ),
          const Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: SafeArea(top: false, child: _TabBar()),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final _HomeState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 140),
      physics: const BouncingScrollPhysics(),
      children: [
        const HomeHeader(),
        const SizedBox(height: 22),
        const _StreakCard(),
        const SizedBox(height: 14),
        const _PlayCard(),
        const SizedBox(height: 18),
        if (state == _HomeState.noTeam) ...[
          const _SectionLabel(text: 'Companions'),
          const SizedBox(height: 11),
          const TempJoinTeamCard(),
        ] else ...[
          const _SectionLabel(text: 'My Team', trailing: 'Open →'),
          const SizedBox(height: 11),
          const TempTeamCard(),
          const SizedBox(height: 14),
          const HomeVerseCard(),
        ],
      ],
    );
  }
}

// ─────────────────────────── Header ───────────────────────────

// ─────────────────────────── Streak card ───────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  // 0=done, 1=today, 2=todo
  static const _states = [0, 0, 0, 0, 1, 2, 2];

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
      // Ember glow bleeding from the top-right corner.
      extraGradient: const RadialGradient(
        center: Alignment(1, -1),
        radius: 1.1,
        colors: [Color(0x38C9512B), Color(0x00C9512B)],
        stops: [0.0, 0.55],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Flame chip.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_C.emberLight, _C.ember],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x80C9512B), blurRadius: 18),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.local_fire_department,
                    size: 22, color: _C.emberInk),
              ),
              const SizedBox(width: 11),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '38',
                    style: TextStyle(
                      fontFamily: _F.serif,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      fontSize: 34,
                      height: 0.9,
                      color: _C.emberLight,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'DAY STREAK',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 9 * 0.24,
                      color: _C.txtMute,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Best',
                      style: TextStyle(fontSize: 10, color: _C.txtMute, height: 1.4)),
                  Text(
                    '52 days',
                    style: TextStyle(
                      fontFamily: _F.mono,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.amberLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Week row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _DayPip(label: _days[i], state: _states[i]),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayPip extends StatelessWidget {
  const _DayPip({required this.label, required this.state});

  final String label;
  final int state; // 0 done, 1 today, 2 todo

  @override
  Widget build(BuildContext context) {
    late final Widget orb;
    late final Color labelColor;

    switch (state) {
      case 0: // done — gold gradient with check
        labelColor = _C.amber;
        orb = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_C.amberLight, _C.amberDeep],
            ),
            boxShadow: const [BoxShadow(color: Color(0x4DE1A560), blurRadius: 8)],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.check_rounded, size: 15, color: _C.ink),
        );
      case 1: // today — ember ring with flame
        labelColor = _C.emberLight;
        orb = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x29C9512B),
            border: Border.all(color: _C.ember, width: 1.5),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.local_fire_department,
              size: 14, color: _C.emberLight),
        );
      default: // todo — faint empty
        labelColor = _C.txtFaint;
        orb = Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x0DF4ECD8),
            border: Border.all(color: _C.hairline),
          ),
        );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.08 * 9,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        orb,
      ],
    );
  }
}

// ─────────────────────────── Play / begin-answering CTA ───────────────────────────

class _PlayCard extends StatelessWidget {
  const _PlayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.emberLight, _C.ember, _C.emberDeepest],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66C9512B), blurRadius: 32, offset: Offset(0, 16)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Pen disc — this is a "begin answering" nudge, not a media player.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x401A0E06),
                  border: Border.all(color: const Color(0x66FFE6C8), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.edit_outlined,
                    size: 21, color: Color(0xFFFFF3E4)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S REVIEW · RIYĀḌ AS-SĀLIḤĪN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 9 * 0.26,
                        color: Color(0xCCFFF3E4),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Chapter 4 — On Patience',
                      style: TextStyle(
                        fontFamily: _F.serif,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 1.05,
                        color: Color(0xFFFFF6EC),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Begin answering · 10 questions today',
                      style: TextStyle(fontSize: 10.5, color: Color(0xC7FFF3E4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          // Progress track — barely started (4%).
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              color: const Color(0x4D1A0E06),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.04,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFE9CE), Color(0xFFFFF6EC)],
                    ),
                    boxShadow: [BoxShadow(color: Color(0x99FFF3E4), blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Section label ───────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(width: 16, height: 1, color: _C.amber),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontFamily: _F.mono,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 9 * 0.34,
              color: _C.amber,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!.toUpperCase(),
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 9.5 * 0.16,
                color: _C.amber,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── State A · Join team ───────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.amberLight, _C.amber, _C.amberDeep],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x47E1A560), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
                letterSpacing: 10.5 * 0.16,
                color: _C.ink,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, size: 12, color: _C.ink),
            ],
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: const Color(0x0DF4ECD8),
          border: Border.all(color: _C.glassBorder, width: 1.5),
        ),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 10.5,
            letterSpacing: 10.5 * 0.16,
            color: _C.ivory,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── State B · Team + verse ───────────────────────────


// ─────────────────────────── Tab bar ───────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEB271A10), Color(0xEB1A120B)],
        ),
        border: Border.all(color: _C.glassBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 14)),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Tab(icon: Icons.home_outlined, label: 'Home', active: true),
          _Tab(icon: Icons.show_chart, label: 'Learn'),
          _Tab(icon: Icons.bar_chart_rounded, label: 'Ranks'),
          _Tab(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.icon, required this.label, this.active = false});

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? _C.amberLight : _C.txtFaint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (active)
          Container(
            width: 26,
            height: 3,
            margin: const EdgeInsets.only(bottom: 7),
            decoration: const BoxDecoration(
              color: _C.amber,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
              boxShadow: [BoxShadow(color: Color(0xB3E1A560), blurRadius: 10)],
            ),
          )
        else
          const SizedBox(height: 10),
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 8.5 * 0.14,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Shared bits ───────────────────────────

/// Glassy card matching the design's `.streakcard` / `.teamcard` / `.joincard`
/// treatment: a faint ivory film, amber hairline border, inset gold highlight
/// and a soft drop shadow. An optional [extraGradient] layers a corner glow.
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.radius,
    required this.padding,
    this.extraGradient,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Gradient? extraGradient;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: border,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0FF4ECD8), Color(0x05F4ECD8)],
        ),
        border: Border.all(color: _C.glassBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: border,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: extraGradient),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Gold radial disc gradient — `radial(circle at 32% 28%, amberLight, amber 55%, amberDeep)`.
const _goldDisc = RadialGradient(
  center: Alignment(-0.36, -0.44),
  radius: 0.9,
  colors: [_C.amberLight, _C.amber, _C.amberDeep],
  stops: [0.0, 0.55, 1.0],
);

/// Segmented control to flip between the two home states the mock presents.
class _StateToggle extends StatelessWidget {
  const _StateToggle({required this.state, required this.onChanged});

  final _HomeState state;
  final ValueChanged<_HomeState> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, _HomeState value) {
      final active = state == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active ? const Color(0x24E1A560) : Colors.transparent,
            border: Border.all(
              color: active ? _C.glassBorder : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: active ? _C.amberLight : _C.txtFaint,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xCC1A120B),
          border: Border.all(color: _C.hairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            seg('Before a team', _HomeState.noTeam),
            const SizedBox(width: 4),
            seg('In a team', _HomeState.inTeam),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Rising embers ───────────────────────────

class _Embers extends StatefulWidget {
  const _Embers();

  @override
  State<_Embers> createState() => _EmbersState();
}

class _EmbersState extends State<_Embers> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Ember> _dots;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _dots = List.generate(14, (_) {
      final scale = 0.5 + rng.nextDouble() * 0.9;
      return _Ember(
        x: rng.nextDouble(),
        phase: rng.nextDouble(),
        speed: 0.6 + rng.nextDouble() * 0.7,
        size: 4 * scale,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _EmbersPainter(_dots, _controller.value),
        ),
      ),
    );
  }
}

class _Ember {
  const _Ember({
    required this.x,
    required this.phase,
    required this.speed,
    required this.size,
  });

  final double x; // 0..1 horizontal position
  final double phase; // 0..1 starting offset in its cycle
  final double speed; // cycle-speed multiplier
  final double size;
}

class _EmbersPainter extends CustomPainter {
  _EmbersPainter(this.dots, this.t);

  final List<_Ember> dots;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in dots) {
      // Progress 0 (bottom) → 1 (top), looping per-dot.
      final p = (t * d.speed + d.phase) % 1.0;
      final y = size.height + 10 - p * (size.height + 20);
      final x = d.x * size.width;

      // Fade in early, hold, fade out near the top — mirrors @keyframes rise.
      double opacity;
      if (p < 0.12) {
        opacity = (p / 0.12) * 0.7;
      } else if (p < 0.85) {
        opacity = 0.7 - (p - 0.12) / (0.85 - 0.12) * 0.3;
      } else {
        opacity = 0.4 * (1 - (p - 0.85) / 0.15);
      }
      opacity = opacity.clamp(0.0, 0.7);
      final radius = d.size / 2 * (0.5 + p * 0.7);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            _C.amberLight.withValues(alpha: opacity),
            _C.emberLight.withValues(alpha: opacity * 0.6),
            _C.emberLight.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius * 1.6));
      canvas.drawCircle(Offset(x, y), radius * 1.6, paint);
    }
  }

  @override
  bool shouldRepaint(_EmbersPainter old) => old.t != t;
}
