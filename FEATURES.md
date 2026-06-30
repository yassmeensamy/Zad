# Zaad (زاد) — App Features

Zaad is a Flutter Islamic learning/quiz app with multi-profile family accounts, team
gamification, streaks, leaderboards, and an offline-first architecture. It follows clean
architecture (data / domain-ish / presentation), Cubit state management, and `go_router`
navigation with a state-driven auth guard.

- **Stack:** Flutter (Dart 3.11+), Material 3, `flutter_bloc`/HydratedBloc, `go_router`,
  Dio, Firebase (Core / Messaging / Remote Config), `easy_localization` (AR default, EN),
  SQLite for offline, `get_it` for DI.
- **Brand:** ElMessiri typeface; semantic olive/ember palette; dark-mode aware.

---

## Architecture & Cross-Cutting Concerns

### App bootstrap (`main.dart`, `app.dart`)
- Initializes HydratedBloc storage, EasyLocalization, Firebase, the `ServiceLocator`
  (get_it), and the deep-link service.
- Pre-fetches Remote Config **before routing** so the force-update gate is known at startup.
- `MyApp` provides 5 global cubits: `AuthCubit`, `UserCubit`, `ThemeCubit` (hydrated),
  `ConnectivityCubit`, `AppStartupCubit`.
- A non-dismissible **force-update overlay** renders above the router when
  `AppStartupCubit.forceUpdateRequired` is true, so it can't be bypassed by redirects.

### Routing & auth guard (`core/navigation/`)
- `go_router` with a `StatefulShellRoute` for the 4-tab main shell plus 30+ feature routes.
- `AuthGate` merges Auth + User + Startup streams into an **AuthPhase**:
  `unknown → transitioning → onboarding → signedOut → signedIn`.
- The guard owns all startup/auth/deep-link routing; the splash is **pure UI** and never
  navigates.
- **Role/guest guards:** guests (`UserModel.isAnonymous` from `/me`) skip profile/child
  management; children (`UserModel.role`) land on home and can't open parent-only routes.
- Deep links (custom scheme + universal links) map to router locations, incl. team join codes.

### API layer (`core/api/`)
- Dio `NetworkService` with interceptors: Auth (JWT inject + 401 refresh), Language,
  AppInfo, TimeZone, AppType. Maps Dio errors to `ServerException`; supports download/progress.
- REST surface in `app_endpoints.dart`: auth, users/me, quiz (categories/levels/questions/
  submit/stats/reset), notifications, support, teams, drafts, download.

### Theming (`theme/`, `features/theme/`)
- Semantic palette via `ThemeExtension` (`context.appColors`): olive (primary), ember (CTA),
  canvas, text hierarchy, success/warning/info.
- Light: bright canvas, dark-olive text. Dark: warm beige canvas, ivory text, warm shadows.
- `ThemeCubit` (HydratedCubit) persists light/dark/system. CTAs use `cta*` ember tokens;
  olive tokens become ivory ink in dark mode.

### Offline-first
- **Content:** categories/levels/questions downloaded via `GET /download` into SQLite
  (`OfflineContentDao`); bundle stores only the active locale, not all translations.
- **Quiz sync:** offline attempts queue in `PendingAnswersDao` (grouped by attempt UUID);
  `OfflineSyncService` flushes on reconnect/login via batch sync.
- **Drafts sync:** offline drafts queue in `PendingDraftsDao`; `DraftsSyncService` batch-syncs.
- `ConnectivityCubit`/`ConnectivityService` expose online state; a banner reflects it.

### App update (`features/upgrade/`, Remote Config)
- **Force update:** `AppStartupCubit` reads `client_min_version_ios/android` from Remote
  Config; if installed < min, pins router to splash + shows blocking dialog.
- **Optional update:** `UpgradeCubit` does a one-shot check on the shell; dismissible prompt.

---

## Authentication (`features/auth`)
- Email/password **login** & **signup** (with OTP email verification), **forgot password**
  (OTP reset), **Google Sign-In** (OAuth strategy factory), **guest mode**, and **guest →
  registered upgrade** without losing progress.
- `AuthCubit` tracks separate sub-statuses (main / guest / social / verification / upgrade /
  logout) so flows don't interfere. Emits login/logout events via `AuthEventService`, with
  pre-logout cleanup callbacks. Supports account switching (family → child).
- Guest UI is gated on `UserModel.isAnonymous` (source of truth), not AuthState.

## Onboarding & profiles (`features/onboarding`, `onboarding_flow`)
- **Tutorial carousel** (`OnboardingScreen`) of network image pages → marks onboarding done.
- **Role select** (Individual vs Family) → **Complete profile** (name/birthday/gender; email
  locked) → for family: **Profile select** grid or **Create children** (batch).
- Cubits: `AvatarsCubit`, `ChildCubit` (CRUD + batch), `ChildDraftCubit` (in-memory drafts
  with dirty/pending-delete tracking). `ProfileEntity` abstracts parent/child/placeholder cards.

## User & Profile (`features/user`, `profile`, `child`)
- `UserCubit` (with `AuthStateListenerMixin`) fetches `/me` on login, clears on logout, and
  falls back to cache on network/5xx so the app stays usable offline.
- **ProfileScreen:** avatar medallion, role-filtered sections (account/family/app/danger),
  update checks, reset progress, sign out. **EditProfileScreen** uses a draft form cubit
  (`EditProfileFormCubit`) saving only when dirty; avatar id sent only when changed.
- **Children management:** `KidCard`, avatar picker sheet, password pill/sheet; batch
  save = deletes + updates + creates; validation before API calls.

## Quiz (`features/quiz`, `quiz_stats`)
- Core learning loop: load a level's questions → answer one at a time (4 choices) → feedback
  panel with explanation/source → celebration overlays on correct answers → auto-submit.
- **Multi-round retry:** wrong answers re-queue into round 2+ until all correct.
- **Scoring:** first-round correct = 2 pts if within 10s else 1 pt; retry = 0. Max = 2×N.
- **History navigation** (`QuizHistoryCubit`): scroll back/forward through answered questions.
- **Drafts integration** (save a question + note), **report question** (creates support
  ticket), **review mode** (read-only with answers revealed).
- Offline: attempts stored locally and synced later. On submit, fires
  `QuizEventService.notifySubmitted(levelId)` to refresh levels/categories.
- **Quiz stats** (`QuizStatsCubit`): weekly solved + per-day breakdown, total solved, and
  best-effort individual rank (rank failure never blocks core stats).

## Levels & Categories (`features/levels`, `categories`)
- **Categories** hub: cards with icon/description, level progress bar, offline download badge,
  pull-to-refresh. **Levels** list: paginated, with locked/in-progress/completed status,
  per-level progress, and per-level **reset**.
- Both cubits listen to `QuizEventService` (submitted/reset) and refresh in the **background**
  (no skeleton flash). Summary completed/total comes from server, not paginated counts.

## Drafts (`features/drafts`)
- Personal saved questions with notes. List/detail screens; create/edit/delete are
  **optimistic with rollback**; `mutatingIds` disables per-row UI in flight.
- Offline: created drafts queue locally; `load()` falls back to pending queue when offline;
  `DraftsSyncService` batch-syncs via `POST /api/drafts/bulk` and prunes synced rows > 7 days.

## Teams (`features/teams`)
- Create a team (creator = owner), **join by code**, invite (share/QR), **leave** (members
  freely; owners must transfer first), **transfer ownership** (owner demoted to member).
- **Team home:** identity card with global rank (#X of Y), invite-code card, category-filtered
  top-10 leaderboard (podium + rows, "YOU" highlight), and a live activity feed.
- `TeamsCubit` tracks team/members/progress/summary with separate Create/Join/Leave/Transfer
  statuses. New-team leaderboard load **retries up to 4×** with backoff (backend lag).
- Recent additions: `team_owner_menu_sheet.dart` (Transfer/Leave actions),
  `team_transfer_ownership_sheet.dart` (member picker + confirm). Join is gated on existing
  membership.

## Leaderboard (`features/leaderboard`)
- Global rankings with **scope toggle** (Individuals / Teams), category filter (individuals),
  podium (top 3) + paginated 20/page list, and a "My Rank" card. Hidden for guests.
- Ranking is **level-completion based** (sorted by `completedLevels`). `RankingsCubit` keeps
  individual and team state independent across scope switches.

## Streak (`features/streak`)
- Current + longest streak, status (active/consistent/idle), and a 7-day activity grid.
- `StreakCubit` fetches streak + weekly activity concurrently and auto-refreshes on
  `QuizEventService.onSubmitted`.

## Home (`features/home`)
- Dashboard composing: header (greeting + notification badge + celebration button), daily
  **Quran sign card**, **play** CTA, **team section** (join prompt or team card, with optional
  Team #1 celebration dialog), **streak hero** (animated count-up), and **quiz stats**.
- Loads `QuranSignCubit`, `StreakCubit`, `TeamsCubit`, `QuizStatsCubit`,
  `NotificationBadgeCubit`; pull-to-refresh loads all in parallel. Guests see a "Why login?"
  upsell instead of streak/team sections.

## Notifications (`features/notification`, `core/services/notification_service.dart`)
- Layers: FCM push, local notifications (foreground/background + images), in-app inbox (REST),
  and per-type push **preferences** (OS permission gate + backend toggles).
- `NotificationCubit`: 20/page inbox, optimistic delete with rollback, silent mark-all-read
  (loads first to preserve unread state, then marks read server-side). `NotificationBadgeCubit`
  drives the home bell count separately. 6 notification types with icons/colors.

## Help Center & Support Tickets (`features/help_center`, `support_tickets`)
- **Help center:** topic grid (6 types) + subject/message composer with validation and an
  animated success card; on submit refreshes the tickets list.
- **Support tickets:** full lifecycle — list (shimmer/empty/refresh), detail with reply thread,
  optimistic close. `SupportTicketsCubit` tracks list / detail / CRUD statuses separately.

## Language (`features/language`)
- `LanguageDialog` to switch locale. `LanguageCubit` applies the change **locally first**
  (offline-safe), caches it, syncs to backend best-effort, and fires `LanguageChangedEvent`
  so EasyLocalization rebuilds.

## Splash & Shell (`features/splash`, `shell`)
- **Splash:** branded staggered animations (logo → brand → basmala, pulsing LOADING after 3s)
  over a dark-aware `DesertBackground` that owns the status-bar overlay. Pure UI, no nav.
- **Shell:** `HomeShell` wraps `StatefulNavigationShell` with a custom `ZaadBottomNav`
  (Home / Categories / Leaderboard / Profile) and runs the optional update check once per shell.

---

## Key Design Patterns
- **State-driven routing** — phase computed from cubits; UI never navigates "wrong".
- **Event buses** — `AuthEventService`, `QuizEventService`, `LanguageChangedEvent` for
  cross-feature refresh without tight coupling.
- **Optimistic UI with rollback** — drafts, notifications, support close.
- **Multi-status cubits** — separate enums per operation to avoid interference.
- **Offline-first** — cache fallback, local queues, batch sync on reconnect/login.
- **Draft-based forms** — edits staged in-memory, committed only on explicit save.
- **Semantic theming** — `ThemeExtension` tokens, not raw Material colors; dark-mode aware.
