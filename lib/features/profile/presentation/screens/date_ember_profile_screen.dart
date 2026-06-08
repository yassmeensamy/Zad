import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/date_ember_palette.dart';

/// Zad — Date & Ember profile screen.
///
/// A single-file, faithful port of the `Zad Date and Ember Profile.html`
/// design: a gilded avatar hero, level badge, stat trio, earned medals and a
/// calm settings list over the roasted-brown radial vignette. Every colour in
/// the design lives in [DateEmber] (lib/theme/date_ember_palette.dart) — the shared palette this screen and the app dark theme both use.
///
/// Standalone showcase — not yet wired to the live user/profile cubits.
class DateEmberProfileScreen extends StatelessWidget {
  const DateEmberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DateEmber.canvas,
      body: _ProfileBody(),
    );
  }
}

const String _serif = 'serif';
const String _mono = 'monospace';

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // radial-gradient(130% 60% at 50% -8%, #271A10, #1A120B 42%, #0E0905)
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.1),
          radius: 1.4,
          colors: [DateEmber.raised, DateEmber.surface, DateEmber.base],
          stops: [0.0, 0.42, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: Image(
                  image: AssetImage('assets/images/islamic-pattern.png'),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  color: DateEmber.ivory,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ),
          const Positioned(
            left: -120,
            right: -120,
            top: -110,
            height: 380,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [Color(0x3DE1A560), Color(0x00E1A560)],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: _EmberField())),

          SafeArea(
            child: Column(
              children: const [
                _TopBar(),
                Expanded(child: _Stage()),
                _TabBar(),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar.
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: const [
                Text(
                  'MY ACCOUNT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                    color: DateEmber.amber,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: _serif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 21,
                    height: 1,
                    letterSpacing: -0.3,
                    color: DateEmber.ivory,
                  ),
                ),
              ],
            ),
          ),
          const _GlassIconButton(icon: Icons.settings_outlined),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x0DF4ECD8),
      shape: const CircleBorder(side: BorderSide(color: DateEmber.glassBorder)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 16, color: DateEmber.ivory),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stage — scrollable body.
// ─────────────────────────────────────────────────────────────────────────────
class _Stage extends StatelessWidget {
  const _Stage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
      children: const [
        _Hero(),
        SizedBox(height: 18),
        _StatTrio(),
        SizedBox(height: 14),
        _SectionHeader(label: 'MEDALS', trailing: 'ALL 12 →'),
        SizedBox(height: 10),
        _MedalRail(),
        SizedBox(height: 14),
        _SectionHeader(label: 'ACCOUNT'),
        SizedBox(height: 10),
        _SettingsList(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero — gilded avatar, level badge, name, role tags.
// ─────────────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(width: 104, height: 104, child: _AvatarHero()),
        const SizedBox(height: 11),
        const Text(
          'Zayd Naseer',
          style: TextStyle(
            fontFamily: _serif,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            fontSize: 25,
            height: 1,
            letterSpacing: -0.5,
            color: DateEmber.ivory,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'زَيْد نَصِير',
          style: TextStyle(
            fontSize: 14,
            color: DateEmber.amber.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _MetaTag(icon: Icons.groups_outlined, label: 'Companions of Sabr'),
            SizedBox(width: 8),
            _MetaTag(icon: Icons.star_outline, label: '#5', iconColor: DateEmber.olive),
          ],
        ),
      ],
    );
  }
}

class _AvatarHero extends StatefulWidget {
  const _AvatarHero();

  @override
  State<_AvatarHero> createState() => _AvatarHeroState();
}

class _AvatarHeroState extends State<_AvatarHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Pulsing halo.
        AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DateEmber.amberLight.withValues(alpha: 0.2 + 0.2 * _c.value),
                  DateEmber.amberLight.withValues(alpha: 0),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
        // Dashed ring.
        const SizedBox(
          width: 104,
          height: 104,
          child: CustomPaint(painter: _DashedRingPainter()),
        ),
        // Gilded disc.
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.36, -0.44),
              radius: 0.95,
              colors: [DateEmber.goldHi, DateEmber.goldMid, DateEmber.goldLo],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(color: const Color(0x80E1A560), width: 2),
            boxShadow: [
              BoxShadow(
                color: DateEmber.ember.withValues(alpha: 0.30),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Text(
            'ز',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 38,
              color: DateEmber.goldInk,
            ),
          ),
        ),
        // Level badge.
        const Positioned(right: 2, bottom: 4, child: _LevelBadge(level: 6)),
      ],
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 1;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = DateEmber.washAmber.withValues(alpha: 0.5);
    const dash = 2.0;
    const gap = 5.0;
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (dash + gap)).floor();
    final step = 2 * math.pi / count;
    final arc = dash / radius;
    for (var i = 0; i < count; i++) {
      final start = i * step;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        arc,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DateEmber.emberLight, DateEmber.ember],
        ),
        border: Border.all(color: DateEmber.surface, width: 2.5),
        boxShadow: [
          BoxShadow(color: DateEmber.ember.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 10, color: DateEmber.emberInk),
          const SizedBox(width: 3),
          Text(
            '$level',
            style: const TextStyle(
              fontFamily: _mono,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DateEmber.emberInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({
    required this.icon,
    required this.label,
    this.iconColor = DateEmber.amber,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: const Color(0x0DF4ECD8),
        border: Border.all(color: DateEmber.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: DateEmber.txtMute),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat trio.
// ─────────────────────────────────────────────────────────────────────────────
class _StatTrio extends StatelessWidget {
  const _StatTrio();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _StatCard(value: '38', label: 'DAY STREAK', fire: true)),
        SizedBox(width: 9),
        Expanded(child: _StatCard(value: '1,860', label: 'TOTAL XP', gold: true)),
        SizedBox(width: 9),
        Expanded(child: _StatCard(value: '88', label: 'SOLVED')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.fire = false,
    this.gold = false,
  });

  final String value;
  final String label;
  final bool fire;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(
      fontFamily: _serif,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w300,
      fontSize: 24,
      height: 0.9,
      color: DateEmber.ivory,
    );

    Widget valueWidget;
    if (gold) {
      valueWidget = ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DateEmber.amberLight, DateEmber.amber, DateEmber.amberDeep],
          stops: [0.0, 0.55, 1.0],
        ).createShader(r),
        child: Text(value, style: valueStyle.copyWith(color: Colors.white)),
      );
    } else {
      valueWidget = Text(
        value,
        style: valueStyle.copyWith(color: fire ? DateEmber.emberLight : DateEmber.ivory),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0FF4ECD8), Color(0x05F4ECD8)],
        ),
        border: Border.all(color: DateEmber.glassBorder),
      ),
      child: Column(
        children: [
          valueWidget,
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: DateEmber.txtMute,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header (gold tick + eyebrow + optional trailing link).
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.trailing});
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Container(width: 16, height: 1, color: DateEmber.amber),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _mono,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
              color: DateEmber.amber,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: DateEmber.amber,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Medal rail.
// ─────────────────────────────────────────────────────────────────────────────
class _MedalRail extends StatelessWidget {
  const _MedalRail();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _Medal(icon: Icons.local_fire_department, label: '30-Day\nFlame'),
        ),
        SizedBox(width: 10),
        Expanded(child: _Medal(icon: Icons.star_outline, label: 'First\nHundred')),
        SizedBox(width: 10),
        Expanded(child: _Medal(icon: Icons.check, label: 'Perfect\nWeek')),
        SizedBox(width: 10),
        Expanded(
          child: _Medal(
            icon: Icons.lock_outline,
            label: 'Scholar\nLvl 10',
            locked: true,
          ),
        ),
      ],
    );
  }
}

class _Medal extends StatelessWidget {
  const _Medal({required this.icon, required this.label, this.locked = false});
  final IconData icon;
  final String label;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: locked
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0FF4ECD8), Color(0x05F4ECD8)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x2EE1A560), Color(0x14A6622A)],
                    ),
              border: Border.all(
                color: locked ? DateEmber.glassBorder : const Color(0x80E1A560),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: locked ? DateEmber.txtFaint : DateEmber.amberLight,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: DateEmber.txtMute,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings list.
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x06F4ECD8),
        border: Border.all(color: DateEmber.hairline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: const [
            _SettingRow(
              icon: Icons.person_outline,
              title: 'Edit profile',
              subtitle: 'Name, avatar, intention',
            ),
            _SettingDivider(),
            _SettingRow(
              icon: Icons.notifications_none,
              title: 'Reminders',
              subtitle: 'Daily prompt at 6:00 AM',
              pill: 'ON',
            ),
            _SettingDivider(),
            _SettingRow(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'العربية · English',
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: DateEmber.hairline);
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.pill,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? pill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0x1AE1A560),
              border: Border.all(color: DateEmber.glassBorder),
            ),
            child: Icon(icon, size: 16, color: DateEmber.amber),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: DateEmber.ivory,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: DateEmber.txtMute),
                ),
              ],
            ),
          ),
          if (pill != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: const Color(0x29C9512B),
                border: Border.all(color: const Color(0x59E07A48)),
              ),
              child: Text(
                pill!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: DateEmber.emberLight,
                ),
              ),
            )
          else
            const Icon(Icons.chevron_right, size: 16, color: DateEmber.txtFaint),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom tab bar (static, faithful to the design).
// ─────────────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEB271A10), Color(0xEB1A120B)],
        ),
        border: Border.all(color: DateEmber.glassBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 14)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _TabItem(icon: Icons.home_outlined, label: 'HOME'),
          _TabItem(icon: Icons.show_chart, label: 'LEARN'),
          _TabItem(icon: Icons.bar_chart, label: 'RANKS'),
          _TabItem(icon: Icons.person_outline, label: 'PROFILE', active: true),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.icon, required this.label, this.active = false});
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? DateEmber.amberLight : DateEmber.txtFaint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 6,
          child: active
              ? Container(
                  width: 26,
                  height: 3,
                  decoration: BoxDecoration(
                    color: DateEmber.amber,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DateEmber.amber.withValues(alpha: 0.7),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 5),
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rising ember particle field.
// ─────────────────────────────────────────────────────────────────────────────
class _EmberField extends StatefulWidget {
  const _EmberField();

  @override
  State<_EmberField> createState() => _EmberFieldState();
}

class _EmberFieldState extends State<_EmberField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 13),
  )..repeat();

  final List<_Spark> _sparks = List.generate(12, (i) {
    final rnd = math.Random(i * 13 + 5);
    return _Spark(
      x: rnd.nextDouble(),
      durScale: 0.55 + rnd.nextDouble(),
      sizeScale: 0.5 + rnd.nextDouble() * 0.9,
      phase: rnd.nextDouble(),
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _EmberPainter(sparks: _sparks, t: _c.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Spark {
  const _Spark({
    required this.x,
    required this.durScale,
    required this.sizeScale,
    required this.phase,
  });
  final double x;
  final double durScale;
  final double sizeScale;
  final double phase;
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.sparks, required this.t});
  final List<_Spark> sparks;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparks) {
      final p = (t / s.durScale + s.phase) % 1.0;
      double opacity;
      if (p < 0.12) {
        opacity = (p / 0.12) * 0.7;
      } else if (p < 0.85) {
        opacity = 0.7 - (p - 0.12) / 0.73 * 0.3;
      } else {
        opacity = 0.4 * (1 - (p - 0.85) / 0.15);
      }
      if (opacity <= 0) continue;

      final scale = 0.5 + p * 0.7;
      final radius = 2 * s.sizeScale * scale;
      final dx = s.x * size.width;
      final dy = size.height - p * (size.height + 40);

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            DateEmber.amberLight.withValues(alpha: opacity),
            DateEmber.emberLight.withValues(alpha: opacity * 0.6),
            DateEmber.emberLight.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.t != t;
}
