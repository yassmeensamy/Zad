import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_app/core/widgets/responsive_text.dart';
import 'package:my_app/theme/app_colors.dart';


/// Zad — Date & Ember profile screen.
///
/// A single-file, faithful port of the `Zad Date and Ember Profile.html`
/// design: a gilded avatar hero, level badge, stat trio, earned medals and a
/// calm settings list over the roasted-brown radial vignette. Every colour in
/// the design lives in [AppColors] (lib/theme/app_colors.dart) — the shared palette this screen and the app dark theme both use.
///
/// Standalone showcase — not yet wired to the live user/profile cubits.
class DateEmberProfileScreen extends StatelessWidget {
  const DateEmberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.canvasNight,
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
          colors: [AppColors.nightRaised, AppColors.nightSurface, AppColors.nightLow],
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
                  color: AppColors.ivory,
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            right: -120,
            top: -110,
            height: 380,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.65,
                    colors: [
                      AppColors.washAmber.withValues(alpha: 0.24),
                      AppColors.washAmber.withValues(alpha: 0),
                    ],
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
            icon: Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward
                : Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: const [
                ResponsiveText(
                  'MY ACCOUNT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                    color: AppColors.amberGlow,
                  ),
                ),
                SizedBox(height: 3),
                ResponsiveText(
                  'Profile',
                  style: TextStyle(
                    fontFamily: _serif,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    fontSize: 21,
                    height: 1,
                    letterSpacing: -0.3,
                    color: AppColors.ivory,
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
      color: AppColors.ivory.withValues(alpha: 0.05),
      shape: const CircleBorder(side: BorderSide(color: AppColors.nightOutline)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 16, color: AppColors.ivory),
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
        const ResponsiveText(
          'Zayd Naseer',
          style: TextStyle(
            fontFamily: _serif,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300,
            fontSize: 25,
            height: 1,
            letterSpacing: -0.5,
            color: AppColors.ivory,
          ),
        ),
        const SizedBox(height: 5),
        ResponsiveText(
          'زَيْد نَصِير',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.amberGlow.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _MetaTag(icon: Icons.groups_outlined, label: 'Companions of Sabr'),
            SizedBox(width: 8),
            _MetaTag(icon: Icons.star_outline, label: '#5', iconColor: AppColors.oliveLight),
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
                  AppColors.amberLight.withValues(alpha: 0.2 + 0.2 * _c.value),
                  AppColors.amberLight.withValues(alpha: 0),
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
              colors: [AppColors.discGoldHi, AppColors.discGoldMid, AppColors.discGoldLo],
              stops: [0.0, 0.55, 1.0],
            ),
            border: Border.all(
              color: AppColors.washAmber.withValues(alpha: 0.50),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ember.withValues(alpha: 0.30),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const ResponsiveText(
            'ز',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 38,
              color: AppColors.discGoldInk,
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
      ..color = AppColors.washAmber.withValues(alpha: 0.5);
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
          colors: [AppColors.emberBright, AppColors.ember],
        ),
        border: Border.all(color: AppColors.nightSurface, width: 2.5),
        boxShadow: [
          BoxShadow(color: AppColors.ember.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 10, color: AppColors.emberInk),
          const SizedBox(width: 3),
          ResponsiveText(
            '$level',
            style: const TextStyle(
              fontFamily: _mono,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.emberInk,
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
    this.iconColor = AppColors.amberGlow,
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
        color: AppColors.ivory.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.nightOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 5),
          ResponsiveText(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.ivory62),
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
      color: AppColors.ivory,
    );

    Widget valueWidget;
    if (gold) {
      valueWidget = ShaderMask(
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.amberLight, AppColors.amberGlow, AppColors.discGoldLo],
          stops: [0.0, 0.55, 1.0],
        ).createShader(r),
        child: ResponsiveText(value, style: valueStyle.copyWith(color: Colors.white)),
      );
    } else {
      valueWidget = ResponsiveText(
        value,
        style: valueStyle.copyWith(color: fire ? AppColors.emberBright : AppColors.ivory),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ivory06, AppColors.ivory02],
        ),
        border: Border.all(color: AppColors.nightOutline),
      ),
      child: Column(
        children: [
          valueWidget,
          const SizedBox(height: 6),
          ResponsiveText(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: AppColors.ivory62,
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
          Container(width: 16, height: 1, color: AppColors.amberGlow),
          const SizedBox(width: 8),
          ResponsiveText(
            label,
            style: const TextStyle(
              fontFamily: _mono,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
              color: AppColors.amberGlow,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            ResponsiveText(
              trailing!,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: AppColors.amberGlow,
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
                      colors: [AppColors.ivory06, AppColors.ivory02],
                    )
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.washAmber.withValues(alpha: 0.18),
                        AppColors.discGoldLo.withValues(alpha: 0.08),
                      ],
                    ),
              border: Border.all(
                color: locked
                    ? AppColors.nightOutline
                    : AppColors.washAmber.withValues(alpha: 0.50),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: locked ? AppColors.ivory40 : AppColors.amberLight,
            ),
          ),
          const SizedBox(height: 7),
          ResponsiveText(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: AppColors.ivory62,
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
        color: AppColors.ivory.withValues(alpha: 0.02),
        border: Border.all(color: AppColors.ivory08),
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
      const Divider(height: 1, thickness: 1, color: AppColors.ivory08);
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
              color: AppColors.washAmber.withValues(alpha: 0.10),
              border: Border.all(color: AppColors.nightOutline),
            ),
            child: Icon(icon, size: 16, color: AppColors.amberGlow),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                    color: AppColors.ivory,
                  ),
                ),
                const SizedBox(height: 2),
                ResponsiveText(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.ivory62),
                ),
              ],
            ),
          ),
          if (pill != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: AppColors.ember.withValues(alpha: 0.16),
                border: Border.all(
                  color: AppColors.emberBright.withValues(alpha: 0.35),
                ),
              ),
              child: ResponsiveText(
                pill!,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.emberBright,
                ),
              ),
            )
          else
            const Icon(Icons.chevron_right, size: 16, color: AppColors.ivory40),
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.nightRaised.withValues(alpha: 0.92),
            AppColors.nightSurface.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: AppColors.nightOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
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
    final color = active ? AppColors.amberLight : AppColors.ivory40;
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
                    color: AppColors.amberGlow,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amberGlow.withValues(alpha: 0.7),
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
        ResponsiveText(
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
            AppColors.amberLight.withValues(alpha: opacity),
            AppColors.emberBright.withValues(alpha: opacity * 0.6),
            AppColors.emberBright.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: radius));
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => oldDelegate.t != t;
}
