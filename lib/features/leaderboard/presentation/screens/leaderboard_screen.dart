import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/core_service_locator.dart';
import '../../../../core/utils/scroll_pagination_mixin.dart';
import '../../../../theme/theme.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../cubit/rankings_cubit.dart';
import '../cubit/rankings_state.dart';
import '../widgets/leaderboard_backdrop.dart';
import '../widgets/leaderboard_guest_prompt.dart';
import '../widgets/leaderboard_header.dart';
import '../widgets/rankings_body.dart';
import '../widgets/rankings_category_filter.dart';
import '../widgets/rankings_scope_tabs.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RankingsCubit>(create: (_) => sl<RankingsCubit>()),
        BlocProvider<CategoriesCubit>.value(value: sl<CategoriesCubit>()),
      ],
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatefulWidget {
  const _LeaderboardView();

  @override
  State<_LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<_LeaderboardView>
    with ScrollPaginationMixin {
  bool _branchVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_branchVisible) {
      _branchVisible = true;
      _loadOnEnter();
    } else if (!visible) {
      _branchVisible = false;
    }
  }

  void _loadOnEnter() {
    final isGuest = context.read<UserCubit>().state.user?.isAnonymous ?? false;
    if (isGuest) return;
    context.read<CategoriesCubit>().ensureLoaded();
    context.read<RankingsCubit>().refresh();
  }

  @override
  void onLoadMore() => context.read<RankingsCubit>().loadMore();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final view = View.of(context);
    final bottomInset = view.viewPadding.bottom / view.devicePixelRatio;
    final bottomNavSpace = 64 + bottomInset + 10;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: LeaderboardBackdrop(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 8, 18, 8 + bottomNavSpace),
            child: BlocSelector<UserCubit, UserState, bool>(
              selector: (state) => state.user?.isAnonymous ?? false,
              builder: (context, isGuest) {
                if (isGuest) return const LeaderboardGuestPrompt();
                return BlocBuilder<RankingsCubit, RankingsState>(
                  builder: (context, state) {
                    final cubit = context.read<RankingsCubit>();
                    return Column(
                      children: [
                        const LeaderboardHeader(),
                        const SizedBox(height: 14),
                        RankingsScopeTabs(
                          value: state.scope,
                          onChanged: cubit.setScope,
                        ),
                        if (state.isIndividuals) ...[
                          const SizedBox(height: 12),
                          BlocSelector<
                            CategoriesCubit,
                            CategoriesState,
                            List<CategoryModel>
                          >(
                            selector: (catState) => catState.categories,
                            builder: (context, categories) =>
                                RankingsCategoryFilter(
                                  categories: categories,
                                  selectedId: state.categoryId,
                                  onSelected: cubit.setCategory,
                                ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Expanded(
                          child: RankingsBody(
                            state: state,
                            controller: scrollController,
                          ),
                        ),
                        RankingsFooter(state: state),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
