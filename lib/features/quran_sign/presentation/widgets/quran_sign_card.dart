import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../data/models/quran_sign_model.dart';
import '../cubit/quran_sign_cubit.dart';
import '../cubit/quran_sign_state.dart';

class QuranSignCard extends StatelessWidget {
  const QuranSignCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(),
        BlocBuilder<QuranSignCubit, QuranSignState>(
          buildWhen: (a, b) => a.status != b.status || a.sign != b.sign,
          builder: (context, state) {
            final sign = state.sign;
            if (sign != null) return _CardBody(sign: sign);
            if (state.isError) {
              return _CardError(
                onRetry: () => context.read<QuranSignCubit>().load(),
              );
            }
            return const _CardSkeleton();
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
      child: ResponsiveText(
        'home.quran_sign.section_title',
        style: AppTextStyles.displaySmall.copyWith(
          fontSize: 22,
          color: colors.oliveDeep,
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.olive.withValues(alpha: 0.10),
            colors.olive.withValues(alpha: 0.03),
          ],
        ),
        border: Border.all(color: colors.olive.withValues(alpha: 0.28)),
      ),
      child: child,
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.sign});

  final QuranSignModel sign;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveText(
            sign.text,
            textAlign: TextAlign.end,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 17,
              height: 1.7,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 11),
          _Reference(sign: sign),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Skeletonizer.zone(
      child: _CardShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Bone.multiText(lines: 3, fontSize: 17),
            SizedBox(height: 11),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Bone.text(width: 130),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardError extends StatelessWidget {
  const _CardError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _CardShell(
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 20, color: colors.oliveDeep),
          const SizedBox(width: 12),
          Expanded(
            child: ResponsiveText(
              'home.quran_sign.load_failed',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.5,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const ResponsiveText('common.retry'),
            style: TextButton.styleFrom(
              foregroundColor: colors.oliveDeep,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Reference extends StatelessWidget {
  const _Reference({required this.sign});

  final QuranSignModel sign;

  @override
  Widget build(BuildContext context) {
    final surahName = sign.surahName;
    final ayah = sign.madaniNumber;
    if (surahName == null || ayah == null) return const SizedBox.shrink();
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: _SurahPill(surahName: surahName, ayah: ayah),
    );
  }
}

class _SurahPill extends StatelessWidget {
  const _SurahPill({required this.surahName, required this.ayah});

  final String surahName;
  final int ayah;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colors.olive.withValues(alpha: 0.10),
        border: Border.all(color: colors.olive.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 12, color: colors.oliveDeep),
          const SizedBox(width: 6),
          ResponsiveText(
            'home.quran_sign.surah_ayah',
            args: [surahName, ayah.toString()],
            maxLines: 1,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colors.oliveDeep,
            ),
          ),
        ],
      ),
    );
  }
}
