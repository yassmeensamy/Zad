import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../../data/repositories/levels_repository.dart';
import '../cubit/levels_state.dart';
import 'levels_list.dart';

class LevelsLoading extends StatelessWidget {
  const LevelsLoading({super.key, required this.tint, this.category});

  final Color tint;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final placeholders = sl<LevelsRepository>().getPlaceholders();
    final mockState = LevelsState(
      status: LevelsStatus.loaded,
      levels: placeholders,
    );
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.olive.withValues(alpha: 0.10),
        highlightColor: colors.oliveLeaf.withValues(alpha: 0.22),
      ),
      child: LevelsList(state: mockState, tint: tint, category: category),
    );
  }
}
