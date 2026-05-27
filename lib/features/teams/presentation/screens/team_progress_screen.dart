import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../cubit/teams_cubit.dart';
import '../cubit/teams_state.dart';
import '../widgets/olive_hero_card.dart';
import '../widgets/team_disc.dart';
import '../widgets/team_scaffold.dart';
import '../widgets/zaad_pill.dart';

class TeamProgressScreen extends StatefulWidget {
  const TeamProgressScreen({super.key});

  @override
  State<TeamProgressScreen> createState() => _TeamProgressScreenState();
}

class _TeamProgressScreenState extends State<TeamProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamsCubit>().loadTeamProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      buildWhen: (a, b) =>
          a.progress != b.progress || a.summary != b.summary || a.team != b.team,
      builder: (context, state) {
        final progress = state.progress;
        final team = state.team;

        return TeamScaffold(
          child: Column(
            children: [
              ZaadAppBar(
                title: 'teams.progress.title',
                subtitle: team?.name ?? '',
                onBack: context.canPop() ? () => context.pop() : null,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  children: [
                    _BigStatCard(state: state),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _GoalCard(progress: progress)),
                        const SizedBox(width: 10),
                        Expanded(child: _AverageCard(state: state)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ContributorsCard(state: state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({required this.state});
  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = state.progress;
    final pct = progress?.overallProgressPercent ?? 0;
    final completed = progress?.totalCompleted ?? 0;

    return OliveHeroCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'teams.progress.overall'.tr().toUpperCase(),
            style: ZaadType.fieldLabel.copyWith(
              color: colors.canvas.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.flameLight,
                    AppColors.flameGold,
                    AppColors.amber,
                  ],
                ).createShader(rect),
                child: ResponsiveText(
                  '$completed',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontSize: 50,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 0.9,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ZaadPill(
                  label: '$pct% done',
                  tone: ZaadPillTone.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({this.progress});
  final dynamic progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ratio = (progress?.overallProgress as double?) ?? 0.0;
    final pct = (ratio * 100).round();
    final completed = (progress?.totalCompleted as int?) ?? 0;
    final total = (progress?.totalLevels as int?) ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.55),
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(color: colors.olive.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'teams.progress.goal'.tr().toUpperCase(),
            style: ZaadType.fieldLabel.copyWith(color: colors.oliveSoft),
          ),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: _RingPainter(
                  ratio: ratio,
                  track: colors.oliveDeep.withValues(alpha: 0.10),
                  arc: colors.accentDeep,
                ),
                child: Center(
                  child: ResponsiveText(
                    '$pct%',
                    style: AppTextStyles.displaySmall.copyWith(
                      fontSize: 16,
                      color: colors.oliveDeep,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: ResponsiveText(
              '$completed / $total',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 10,
                color: colors.oliveSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageCard extends StatelessWidget {
  const _AverageCard({required this.state});
  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final members = state.summary?.members ?? const [];
    final avg = members.isEmpty
        ? 0
        : (members.fold<int>(0, (s, m) => s + m.completedLevels) /
                  members.length)
              .round();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.55),
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(color: colors.olive.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'teams.progress.avg_member'.tr().toUpperCase(),
            style: ZaadType.fieldLabel.copyWith(color: colors.oliveSoft),
          ),
          const SizedBox(height: 14),
          Center(
            child: ResponsiveText(
              '$avg',
              style: AppTextStyles.displaySmall.copyWith(
                fontSize: 28,
                color: colors.oliveDeep,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: ResponsiveText(
              'teams.progress.levels_done'.tr(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.oliveSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributorsCard extends StatelessWidget {
  const _ContributorsCard({required this.state});
  final TeamsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final members = [...state.summary?.members ?? const []]
      ..sort((a, b) => b.completedLevels.compareTo(a.completedLevels));
    final top = members.take(3).toList();
    final maxValue = top.isEmpty
        ? 1
        : top.first.completedLevels.clamp(1, 1 << 30);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.canvas.withValues(alpha: 0.55),
        borderRadius: ZaadRadii.lgAll,
        border: Border.all(color: colors.olive.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'teams.progress.top_contributors'.tr().toUpperCase(),
            style: ZaadType.fieldLabel.copyWith(color: colors.oliveSoft),
          ),
          const SizedBox(height: 10),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ResponsiveText(
                'teams.progress.no_contributors'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  color: colors.oliveSoft,
                ),
              ),
            )
          else
            for (final m in top) ...[
              Row(
                children: [
                  TeamDisc(
                    seed: m.username,
                    size: 26,
                    fontSize: 11,
                    useSerif: false,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: ResponsiveText(
                                m.username,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.oliveDeep,
                                ),
                              ),
                            ),
                            ResponsiveText(
                              '${m.completedLevels} / ${m.totalLevels}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.accentDeep,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            height: 5,
                            child: Stack(
                              children: [
                                Container(
                                  color: colors.oliveDeep
                                      .withValues(alpha: 0.10),
                                ),
                                FractionallySizedBox(
                                  widthFactor:
                                      (m.completedLevels / maxValue)
                                          .clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.amberGlow,
                                          AppColors.amberDeep,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (m != top.last) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.ratio, required this.track, required this.arc});
  final double ratio;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 4.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      ratio.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.ratio != ratio || old.arc != arc || old.track != track;
}
