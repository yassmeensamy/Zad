import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shell/presentation/screens/home_shell.dart';
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
import '../../features/offline/presentation/screens/downloads_screen.dart';
import '../../features/onboarding_flow/presentation/screens/complete_profile_screen.dart';
import '../../features/onboarding_flow/presentation/screens/profile_select_screen.dart';
import '../../features/onboarding_flow/presentation/screens/role_select_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/support_tickets/data/models/ticket_model.dart';
import '../../features/support_tickets/presentation/cubit/support_tickets_cubit.dart';
import '../../features/support_tickets/presentation/screens/support_tickets_screen.dart';
import '../../features/support_tickets/presentation/screens/ticket_detail_screen.dart';
import '../../features/teams/presentation/cubit/teams_cubit.dart';
import '../../features/teams/presentation/screens/team_create_success_screen.dart';
import '../../features/teams/presentation/screens/team_home_screen.dart';
import '../../features/teams/presentation/screens/team_join_screen.dart';
import '../../features/teams/presentation/screens/team_join_success_screen.dart';
import '../../features/teams/presentation/screens/team_loader_screen.dart';
import '../../features/onboarding_flow/presentation/cubit/countries_cubit.dart';
import '../services/core_service_locator.dart';
import 'app_routes.dart';
import 'auth_gate.dart';
import 'auth_guard.dart';
import 'deep_links.dart';
import 'extra_codec.dart';

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static const GuardRoutes guardRoutes = GuardRoutes(
    splash: AppRoutes.splash,
    signIn: AppRoutes.login,
    // Sign-up is the front door: a signed-out user coming off the splash (or
    // hitting a protected route) lands on registration, not login. Login stays
    // a first-class route — the guard leaves a signed-out user sitting there,
    // and the sign-up screen links across to it for returning users.
    signedOutLanding: AppRoutes.signup,
    home: AppRoutes.profileSelect,
    profileSetup: AppRoutes.roleSelect,
    // signup is included so a just-registered (or just-upgraded) user with an
    // incomplete profile isn't redirected off /signup the instant /me resolves —
    // that would tear down the success dialog before it can be seen. The dialog's
    // Continue button navigates on to role-select explicitly.
    setupFlow: {
      AppRoutes.signup,
      AppRoutes.roleSelect,
      AppRoutes.completeProfile,
    },
    // Saving the profile is what flips `needsProfileSetup` to false, so without
    // this the guard would bounce off complete-profile in the same frame the
    // save lands — tearing down the success dialog before it renders. The
    // screen navigates on to `nextDestination` when the dialog is dismissed.
    selfExitRoutes: {AppRoutes.completeProfile},
    offlineHome: AppRoutes.home,
    guestHome: AppRoutes.home,
    childHome: AppRoutes.home,
    guestBlocked: {
      AppRoutes.profileSelect,
      AppRoutes.roleSelect,
      AppRoutes.createProfiles,
      AppRoutes.myChildren,
    },
    childBlocked: {
      AppRoutes.profileSelect,
      AppRoutes.roleSelect,
      AppRoutes.createProfiles,
      AppRoutes.myChildren,
    },
    onboarding: AppRoutes.onboarding,
    publicRoutes: {AppRoutes.signup, AppRoutes.forgotPassword},
  );

  static GoRouter build({
    required String initialLocation,
    required AuthGate gate,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      // Both of these resolve to `gate.routingState`: the refresh only fires
      // when that snapshot changes, and the guard decides from the same
      // snapshot. Neither can depend on an input the other doesn't see.
      refreshListenable: gate.refresh,
      redirect: authGuard(
        routes: guardRoutes,
        readState: () => gate.routingState,
      ),
      // A refresh re-decodes `extra`; without this codec go_router json-encodes
      // it through the models' `toJson()`, which return Strings. See
      // [AppExtraCodec].
      extraCodec: const AppExtraCodec(),
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
          path: AppRoutes.forgotPassword,
          name: AppRoutes.forgotPasswordName,
          builder: (context, state) => BlocProvider<ForgotPasswordCubit>(
            create: (_) => sl<ForgotPasswordCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.roleSelect,
          name: AppRoutes.roleSelectName,
          builder: (context, state) => const RoleSelectScreen(),
        ),
        GoRoute(
          path: AppRoutes.completeProfile,
          name: AppRoutes.completeProfileName,
          builder: (context, state) => BlocProvider<CountriesCubit>(
            create: (_) => sl<CountriesCubit>()..fetchCountries(),
            child: CompleteProfileScreen(
              nextDestination: state.extra is String
                  ? state.extra! as String
                  : AppRoutes.home,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.createProfiles,
          name: AppRoutes.createProfilesName,
          builder: (context, state) => CreateChildrenScreen(
            backDestination: state.extra is String
                ? state.extra! as String
                : null,
          ),
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
          path: AppRoutes.downloads,
          name: AppRoutes.downloadsName,
          builder: (context, state) => const DownloadsScreen(),
        ),
        GoRoute(
          path: AppRoutes.helpCenter,
          name: AppRoutes.helpCenterName,
          builder: (context, state) => const HelpCenterScreen(),
        ),
        // The drafts list and a single draft share one DraftsCubit: the detail
        // screen reads the live note out of the list's state and mutates it in
        // place. Hoisting the provider above both routes keeps that instance
        // shared without putting a live object into `extra`, which could never
        // survive go_router's serialization.
        ShellRoute(
          builder: (context, state, child) => BlocProvider<DraftsCubit>(
            create: (_) => sl<DraftsCubit>()..load(),
            child: child,
          ),
          routes: [
            GoRoute(
              path: AppRoutes.drafts,
              name: AppRoutes.draftsName,
              builder: (context, state) => const DraftsScreen(),
              routes: [
                GoRoute(
                  path: AppRoutes.draftDetail,
                  name: AppRoutes.draftDetailName,
                  // The screen cannot render without a draft, and the id alone
                  // isn't enough to rebuild one. If the hint didn't survive,
                  // fall back to the list rather than an empty page.
                  redirect: (context, state) =>
                      state.extra is DraftModel ? null : AppRoutes.drafts,
                  builder: (context, state) {
                    final extra = state.extra;
                    // Unreachable: the redirect above already bounced a missing
                    // draft to the list.
                    if (extra is! DraftModel) return const SizedBox.shrink();
                    return DraftDetailScreen(draft: extra);
                  },
                ),
              ],
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
              // Detail owns its cubit — it only ever reads detail-scoped state
              // and loads by id, so it never needs the list's instance. The
              // ticket is an optional seed for instant paint.
              builder: (context, state) {
                final extra = state.extra;
                return BlocProvider<SupportTicketsCubit>(
                  create: (_) => sl<SupportTicketsCubit>(),
                  child: TicketDetailScreen(
                    ticketId: state.pathParameters['id'] ?? '',
                    seed: extra is TicketModel ? extra : null,
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.levels,
          name: AppRoutes.levelsName,
          // `category` is a paint-ahead hint only; the id in the path is the
          // source of truth and the screen fetches from it either way.
          builder: (context, state) => LevelsScreen(
            categoryId: state.pathParameters['id']!,
            category: state.extra is CategoryModel
                ? state.extra! as CategoryModel
                : null,
          ),
        ),
        GoRoute(
          path: AppRoutes.quiz,
          name: AppRoutes.quizName,
          builder: (context, state) => QuizScreen(
            levelId: int.tryParse(state.pathParameters['levelId'] ?? '') ?? -1,
            level: state.extra is LevelModel
                ? state.extra! as LevelModel
                : null,
          ),
        ),
        GoRoute(
          path: AppRoutes.teams,
          name: AppRoutes.teamsName,
          builder: (context, state) => BlocProvider<TeamsCubit>(
            create: (_) => sl<TeamsCubit>(),
            child: const TeamLoaderScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.teamCreateSuccess,
          name: AppRoutes.teamCreateSuccessName,
          builder: (context, state) => BlocProvider<TeamsCubit>(
            create: (_) => sl<TeamsCubit>(),
            child: const TeamCreateSuccessScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.teamJoin,
          name: AppRoutes.teamJoinName,
          builder: (context, state) => BlocProvider<TeamsCubit>(
            create: (_) => sl<TeamsCubit>(),
            child: TeamJoinScreen(
              initialCode: state.uri.queryParameters[DeepLinks.codeParam],
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.teamJoinSuccess,
          name: AppRoutes.teamJoinSuccessName,
          builder: (context, state) => BlocProvider<TeamsCubit>(
            create: (_) => sl<TeamsCubit>(),
            child: const TeamJoinSuccessScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.teamHome,
          name: AppRoutes.teamHomeName,
          builder: (context, state) => BlocProvider<TeamsCubit>(
            create: (_) => sl<TeamsCubit>()
              ..loadTeamStatus()
              ..loadTeamMembers()
              ..loadTeamProgress(),
            child: const TeamHomeScreen(),
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
}
