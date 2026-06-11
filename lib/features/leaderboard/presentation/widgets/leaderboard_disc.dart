import 'package:flutter/material.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';

/// Metallic medal styles for [LeaderboardDisc] avatars.
enum DiscStyle { gold, silver, bronze, olive }

/// First glyph of [name], upper-cased; `?` when empty/null.
String discInitial(String? name) {
  final t = name?.trim() ?? '';
  return t.isEmpty ? '?' : t.substring(0, 1).toUpperCase();
}

/// Podium pedestal place → medal style (1st gold, 2nd silver, else bronze).
DiscStyle discStyleForPlace(int place) => switch (place) {
  1 => DiscStyle.gold,
  2 => DiscStyle.silver,
  _ => DiscStyle.bronze,
};

/// List-row rank → medal style; the current user ("me") always reads gold.
DiscStyle discStyleForRow(int rank, bool isMe) {
  if (isMe) return DiscStyle.gold;
  return switch (rank) {
    1 => DiscStyle.gold,
    2 => DiscStyle.silver,
    3 => DiscStyle.bronze,
    _ => DiscStyle.olive,
  };
}

/// A circular metallic avatar disc showing a single initial. The gold/silver/
/// bronze/olive ramps are sourced from the Date & Ember palette.
class LeaderboardDisc extends StatelessWidget {
  const LeaderboardDisc({
    super.key,
    required this.size,
    required this.initial,
    required this.style,
    required this.fontSize,
  });

  final double size;
  final String initial;
  final DiscStyle style;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (colors, ink, ringColor) = switch (style) {
      DiscStyle.gold => (
        [AppColors.discGoldHi, AppColors.discGoldMid, AppColors.discGoldLo],
        AppColors.discGoldInk,
        AppColors.discGoldMid.withValues(alpha: 0.55),
      ),
      DiscStyle.silver => (
        [
          AppColors.discSilverHi,
          AppColors.discSilverMid,
          AppColors.discSilverLo,
        ],
        AppColors.discGoldInk,
        AppColors.discSilverMid.withValues(alpha: 0.5),
      ),
      DiscStyle.bronze => (
        [
          AppColors.discBronzeHi,
          AppColors.discBronzeMid,
          AppColors.discBronzeLo,
        ],
        AppColors.discBronzeInk,
        AppColors.discBronzeMid.withValues(alpha: 0.5),
      ),
      DiscStyle.olive => (
        [AppColors.discOliveHi, AppColors.discOliveMid, AppColors.discOliveLo],
        AppColors.discOliveInk,
        AppColors.discGoldMid.withValues(alpha: 0.2),
      ),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.36, -0.44),
          radius: 0.95,
          colors: colors,
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(color: ringColor, width: 2),
      ),
      child: ResponsiveText(
        initial,
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          height: 1,
          color: ink,
        ),
      ),
    );
  }
}
