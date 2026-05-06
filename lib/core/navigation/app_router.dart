import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/levels/data/models/level_model.dart';
import '../../features/levels/presentation/screens/levels_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/child/presentation/screens/children_list_screen.dart';
import '../../features/child/presentation/screens/create_children_screen.dart';
import '../../features/drafts/data/models/draft_model.dart';
import '../../features/drafts/presentation/cubit/drafts_cubit.dart';
import '../../features/drafts/presentation/screens/draft_detail_screen.dart';
import '../../features/drafts/presentation/screens/drafts_screen.dart';
import '../../features/help_center/presentation/screens/help_center_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/onboarding_flow/presentation/screens/profile_select_screen.dart';
import '../../features/onboarding_flow/presentation/screens/role_select_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/support_tickets/data/models/ticket_model.dart';
import '../../features/support_tickets/presentation/cubit/support_tickets_cubit.dart';
import '../../features/support_tickets/presentation/screens/support_tickets_screen.dart';
import '../../features/support_tickets/presentation/screens/ticket_detail_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splashName,
        builder: (context, state) => const ZaadSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signupName,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        name: AppRoutes.roleSelectName,
        builder: (context, state) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.createProfiles,
        name: AppRoutes.createProfilesName,
        builder: (context, state) => const CreateChildrenScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSelect,
        name: AppRoutes.profileSelectName,
        builder: (context, state) => const ProfileSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.myChildren,
        name: AppRoutes.myChildrenName,
        builder: (context, state) => const ChildrenListScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notificationsName,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRoutes.editProfileName,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        name: AppRoutes.helpCenterName,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.drafts,
        name: AppRoutes.draftsName,
        builder: (context, state) => const DraftsScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.draftDetail,
            name: AppRoutes.draftDetailName,
            builder: (context, state) {
              final extra =
                  state.extra as ({DraftsCubit cubit, DraftModel draft})?;
              if (extra == null) return const SizedBox.shrink();
              return BlocProvider<DraftsCubit>.value(
                value: extra.cubit,
                child: DraftDetailScreen(draft: extra.draft),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.supportTickets,
        name: AppRoutes.supportTicketsName,
        builder: (context, state) => const SupportTicketsScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.ticketDetail,
            name: AppRoutes.ticketDetailName,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra
                  as ({SupportTicketsCubit cubit, TicketModel ticket});
              return BlocProvider<SupportTicketsCubit>.value(
                value: extra.cubit,
                child: TicketDetailScreen(
                  ticketId: id,
                  seed: extra.ticket,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.levels,
        name: AppRoutes.levelsName,
        builder: (context, state) => LevelsScreen(
          categoryId: state.pathParameters['id']!,
          category: state.extra as CategoryModel?,
        ),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        name: AppRoutes.quizName,
        builder: (context, state) => QuizScreen(
          levelId: int.tryParse(state.pathParameters['levelId'] ?? '') ?? -1,
          level: state.extra as LevelModel?,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.homeName,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                name: AppRoutes.categoriesName,
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.leaderboard,
                name: AppRoutes.leaderboardName,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
