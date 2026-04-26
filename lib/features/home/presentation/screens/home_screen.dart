import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: const [
          _Greeting(name: 'ياسمين'),
          SizedBox(height: 18),
          _StreakCard(),
          SizedBox(height: 22),
          _SectionLabel(text: 'تابع التعلّم'),
          SizedBox(height: 12),
          _ContinueCard(),
          SizedBox(height: 22),
          _SectionLabel(text: 'مقترح لك'),
          SizedBox(height: 12),
          _QuickGrid(),
          SizedBox(height: 22),
          _AyahOfTheDay(),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السلام عليكم',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textArabic.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: colors.textArabic,
                  ),
                  children: [
                    const TextSpan(text: 'أهلاً بعودتك، '),
                    TextSpan(
                      text: name,
                      style: GoogleFonts.amiri(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w700,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Avatar(initial: name.isNotEmpty ? name[0] : '؟'),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accentSoft, colors.accent],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.amiri(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colors.canvas,
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
          colors: [
            colors.accentSoft,
            const Color(0xFFD2963F),
            colors.accent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.22),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: colors.canvas,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'سلسلة يومية',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: colors.canvas.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '٧',
                style: GoogleFonts.amiri(
                  fontSize: 60,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: colors.canvas,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'أيام متتالية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.canvas.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < 5
                          ? colors.canvas
                          : colors.canvas.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (i != 6) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '٥ من ٧ أهداف يومية مكتملة',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.canvas.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.amiri(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: colors.textArabic,
          ),
        ),
        const Spacer(),
        Text(
          'عرض الكل',
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.accent,
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.canvasRaised.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.textArabic.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.accentSoft.withValues(alpha: 0.5),
                  colors.accent.withValues(alpha: 0.85),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '٢',
              style: GoogleFonts.amiri(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: colors.canvas,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سورة البقرة',
                  style: GoogleFonts.amiri(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colors.textArabic,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الآية ١٤٢ من ٢٨٦ · ١٨ دقيقة متبقية',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.textArabic.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: 0.49,
                    minHeight: 5,
                    backgroundColor:
                        colors.textArabic.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(colors.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: colors.canvas,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tiles = <_QuickTileData>[
      _QuickTileData(
        title: 'الحفظ',
        subtitle: '١٢ آية',
        icon: Icons.bookmark_added_rounded,
        tint: colors.accent,
      ),
      _QuickTileData(
        title: 'التجويد',
        subtitle: 'الدرس ٤',
        icon: Icons.graphic_eq_rounded,
        tint: colors.textArabic,
      ),
      _QuickTileData(
        title: 'الأدعية',
        subtitle: 'مجموعة يومية',
        icon: Icons.spa_rounded,
        tint: AppColors.success,
      ),
      _QuickTileData(
        title: 'التفسير',
        subtitle: '٣ جديدة',
        icon: Icons.menu_book_rounded,
        tint: colors.accentDeep,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [for (final t in tiles) _QuickTile(data: t)],
    );
  }
}

class _QuickTileData {
  const _QuickTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.data});
  final _QuickTileData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.canvasRaised.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.textArabic.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: data.tint.withValues(alpha: 0.14),
            ),
            child: Icon(data.icon, size: 20, color: data.tint),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.amiri(
                  fontSize: 16,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: colors.textArabic,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11.5,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  color: colors.textArabic.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AyahOfTheDay extends StatelessWidget {
  const _AyahOfTheDay();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.textArabic.withValues(alpha: 0.06),
        border: Border.all(
          color: colors.textArabic.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: colors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'آية اليوم',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: colors.textArabic.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'وَمَن يَتَّقِ ٱللَّهَ يَجْعَل لَّهُۥ مَخْرَجًۭا',
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 24,
              height: 1.7,
              fontWeight: FontWeight.w400,
              color: colors.textArabic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سورة الطلاق · ٦٥:٢',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
