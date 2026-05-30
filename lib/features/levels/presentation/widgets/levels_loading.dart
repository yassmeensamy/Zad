import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../../data/models/level_model.dart';
import '../cubit/levels_state.dart';
import 'levels_list.dart';

/// Skeleton stand-ins shown while the real levels load. Presentation-only
/// data — the shimmer just needs realistic shapes, so this never touches the
/// data layer.
const List<LevelModel> _kPlaceholders = [
  LevelModel(
    id: 0,
    title: 'Level title',
    order: 1,
    questionCount: 10,
    completedQuestions: 10,
    passingGrade: 70,
    status: LevelStatus.completed,
  ),
  LevelModel(
    id: 1,
    title: 'Level title',
    order: 2,
    questionCount: 10,
    completedQuestions: 10,
    passingGrade: 70,
    status: LevelStatus.completed,
  ),
  LevelModel(
    id: 2,
    title: 'Level title',
    order: 3,
    questionCount: 10,
    completedQuestions: 4,
    passingGrade: 70,
    status: LevelStatus.inProgress,
  ),
  LevelModel(
    id: 3,
    title: 'Level title',
    order: 4,
    questionCount: 10,
    completedQuestions: 0,
    passingGrade: 70,
    status: LevelStatus.locked,
  ),
  LevelModel(
    id: 4,
    title: 'Level title',
    order: 5,
    questionCount: 10,
    completedQuestions: 0,
    passingGrade: 70,
    status: LevelStatus.locked,
  ),
  LevelModel(
    id: 5,
    title: 'Level title',
    order: 6,
    questionCount: 10,
    completedQuestions: 0,
    passingGrade: 70,
    status: LevelStatus.locked,
  ),
];

class LevelsLoading extends StatelessWidget {
  const LevelsLoading({super.key, required this.tint, this.category});

  final Color tint;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const mockState = LevelsState(
      status: LevelsStatus.loaded,
      levels: _kPlaceholders,
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
