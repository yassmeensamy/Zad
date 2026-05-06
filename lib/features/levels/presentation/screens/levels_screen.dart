import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/islamic_ornaments.dart';
import '../../../../core/widgets/zaad_app_bar.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/utils/random_tint.dart';
import '../cubit/levels_cubit.dart';
import '../cubit/levels_state.dart';
import '../widgets/levels_list.dart';
import '../widgets/levels_loading.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key, required this.categoryId, this.category});

  final String categoryId;
  final CategoryModel? category;

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen>
    with ScrollPaginationMixin<LevelsScreen> {
  late final int _categoryId = int.tryParse(widget.categoryId) ?? -1;
  late final Color _tint = widget.category != null
      ? tintFor(widget.category!.id)
      : randomTint();
  late final LevelsCubit _cubit = sl<LevelsCubit>()..getLevels(_categoryId);

  @override
  void onLoadMore() => _cubit.loadMore(_categoryId);

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocProvider<LevelsCubit>.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: colors.canvas,
        body: Column(
          children: [
            ZaadAppBar(
              title: widget.category?.name ?? 'levels.title',
              onBack: context.canPop() ? () => context.pop() : null,
            ),
            Expanded(
              child: CustomPaint(
                painter: StarTessellationPainter(
                  color: _tint,
                  tile: 56,
                  opacity: 0.04,
                ),
                child: BlocBuilder<LevelsCubit, LevelsState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    if ((state.isLoading || state.isInitial) &&
                        !state.hasLevels) {
                      return LevelsLoading(
                        tint: _tint,
                        category: widget.category,
                      );
                    }
                    if (state.isError && !state.hasLevels) {
                      return ErrorState(
                        message: state.errorMessage ?? 'errors.generic',
                        onRetry: () => _cubit.getLevels(_categoryId),
                      );
                    }
                    return LevelsList(
                      controller: scrollController,
                      state: state,
                      tint: _tint,
                      category: widget.category,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
