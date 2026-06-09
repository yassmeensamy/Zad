# Declarative Routing Refactor — Portable Plan

A reusable guide to move startup / auth / deep-link navigation out of cubits and
the splash screen into a **single go_router `redirect`**. Written from the Zaad
implementation so it can be reproduced in another Flutter app.

---

## 1. The idea (before → after)

**Before (imperative, race-prone):**
- `SplashCubit` did startup work *and* decided where to navigate (`destination`
  enum). The splash screen read that and called `context.go(...)`.
- `DeepLinkHandler` was a **static singleton** buffering a `_pending` link with a
  manual `isAppReady` flag. The splash "consumed" pending links once auth
  resolved. Two places navigated → ordering races, flicker, duplicated logic.

**After (declarative, single source of truth):**
- **go_router's `redirect`** is the *only* thing that navigates. It is a pure
  function of one value: an `AuthPhase`.
- An **`AuthGate`** (a plain object, **not** a cubit) reads the startup/auth/user
  cubits and derives that `AuthPhase`. It also merges their streams into one
  `Listenable` that drives `refreshListenable`, so the redirect re-runs on any
  state change. Onboarding is **not** a gate input — it is resolved during
  startup and lives on the startup state, so the gate just reads
  `startup.needsOnboarding`.
- The **splash is pure UI** — it never navigates.
- **Deep links** become an instance `DeepLinkService` (stream of locations);
  `main` resolves the launch link *before* building the router and pipes later
  links into `router.go`.

Net effect: every navigation decision lives in one pure function; cubits only own
state; no `isAppReady`, no pending buffer, no cubit-drives-navigation.

---

## 2. Files this refactor introduces / changes

New:
- `core/navigation/auth_guard.dart` — `AuthPhase` enum, `GuardRoutes` config,
  `authGuard(...)` redirect factory (pure).
- `core/navigation/auth_gate.dart` — derives `AuthPhase`, exposes `listenable`.
  Takes only the auth/user/startup cubits — onboarding is read off the startup
  state, not injected.
- `core/navigation/stream_listenable.dart` — `Stream` → `Listenable` adapter.
- `core/navigation/deep_link_service.dart` — instance deep-link service.
- `core/bootstrap/app_startup_cubit.dart` + `app_startup_state.dart` — startup
  side-effects + onboarding resolution. Status-only **plus** a resolved
  `needsOnboarding` flag (no destination, no navigation). Also owns
  `completeOnboarding()`.
- `app.dart` — `MyApp` + `_AppView`: the `MultiBlocProvider`, the gate, the
  router, and the deep-link wiring. (Lifted out of `main.dart`.)

Changed:
- `core/navigation/app_router.dart` — `AppRouter.build({initialLocation, gate})`
  wires `refreshListenable` + `redirect` from the gate.
- `main.dart` — bootstrap only: init services, resolve the initial deep link,
  `runApp(MyApp(...))`. No widgets/cubits here anymore.
- `core/services/service_locator.dart` — registers `AppStartupCubit` in place of
  the deleted `SplashCubit`.
- `onboarding/data/repositories/onboarding_repository.dart` — pure data access;
  exposes `cachedOnboarding` (the primed pages) for the cubit to seed from.
- `onboarding/presentation/cubit/onboarding_cubit.dart` — seeds from
  `cachedOnboarding` (no loading flash); `load()` no-ops if already seeded.
- `onboarding/presentation/screens/onboarding_screen.dart` — "Get started" calls
  `AppStartupCubit.completeOnboarding()` instead of navigating.
- `splash_screen.dart` — strip all navigation; pure animation/UI.

Deleted:
- `splash/.../splash_cubit.dart` + `splash_state.dart`
- `core/navigation/deep_link_handler.dart` (static singleton)

---

## 3. Step-by-step

### Step 1 — Define the phase + redirect (the brain)
Create `auth_guard.dart`. This is pure and has **no Flutter/bloc imports** beyond
go_router — it's just a state machine, so it's trivially testable.

```dart
enum AuthPhase { unknown, transitioning, onboarding, signedOut, signedIn }

class GuardRoutes {
  const GuardRoutes({
    required this.splash, required this.signIn,
    required this.home, required this.onboarding,
    this.publicRoutes = const {},
  });
  final String splash, signIn, home, onboarding;
  final Set<String> publicRoutes;
  bool isEntry(String location) {
    final p = Uri.parse(location).path;
    return p == splash || p == signIn || p == onboarding;
  }
}

GoRouterRedirect authGuard({
  required GuardRoutes routes,
  required AuthPhase Function() phase,
  String fromParam = 'from',
}) => (context, state) {
  final loc = state.matchedLocation;
  // ...preserve intended destination via ?from=, then:
  switch (phase()) {
    case AuthPhase.unknown:       // park on splash while resolving
      return loc == routes.splash ? null : routes.splash; // (+ ?from=)
    case AuthPhase.transitioning: return null;            // mid sign-in, don't bounce
    case AuthPhase.onboarding:    return loc == routes.onboarding ? null : routes.onboarding;
    case AuthPhase.signedOut:     return _allowedWhenOut(loc) ? null : routes.signIn; // (+ ?from=)
    case AuthPhase.signedIn:      // off splash/signIn → intended deep link or home
      return (loc == routes.splash || loc == routes.signIn) ? (intended ?? routes.home) : null;
  }
};
```

Key behaviours to copy:
- `unknown` → hold on splash (prevents flicker before state resolves).
- `transitioning` → return `null` so an in-progress login isn't yanked around.
- `?from=` round-trip preserves the originally-requested deep-link target through
  the sign-in detour, then lands there on `signedIn`.

### Step 2 — `StreamListenable` (stream → Listenable adapter)
go_router's `refreshListenable` wants a `Listenable`; blocs emit `Stream`. Bridge:

```dart
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<dynamic> s) { _sub = s.listen((_) => notifyListeners()); }
  late final StreamSubscription<dynamic> _sub;
  @override void dispose() { _sub.cancel(); super.dispose(); }
}
```

### Step 3 — `AuthGate` (the coordinator, NOT a cubit)
Reads the cubits and computes `phase`; merges their streams for refresh. It owns
no state and mutates nothing → **avoids the cubit-in-cubit anti-pattern**.

```dart
class AuthGate {
  AuthGate({required AuthCubit auth, required UserCubit user,
            required AppStartupCubit startup}) ...
  late final _sources = [StreamListenable(_auth.stream),
                         StreamListenable(_user.stream),
                         StreamListenable(_startup.stream)];
  late final Listenable listenable = Listenable.merge(_sources);

  AuthPhase get phase {                 // precedence order matters
    final s = _startup.state;
    if (s.isInitial || s.isLoading) return AuthPhase.unknown;
    if (s.isError) return AuthPhase.signedOut;
    if (s.needsOnboarding) return AuthPhase.onboarding;   // resolved during startup
    final a = _auth.state;
    if (a.isInitial) return AuthPhase.unknown;
    if (a.isLoading) return AuthPhase.transitioning;
    if (a.isError || a.isNotLoggedIn) return AuthPhase.signedOut;
    final u = _user.state;              // gate signedIn on the /me profile
    if (u.isInitial) return AuthPhase.unknown;
    if (u.isLoading) return AuthPhase.transitioning;
    if (u.isError) return AuthPhase.signedOut;
    return AuthPhase.signedIn;
  }
  void dispose() { for (final x in _sources) x.dispose(); }
}
```
Note: onboarding is `s.needsOnboarding` (a field on the startup state), **not** a
separate repository injected into the gate. The gate stays a 3-cubit reader.
Adapt the `phase` ladder to your app's cubits. The principle: **`unknown` until
everything that could redirect is known**, so the guard never makes a decision on
half-loaded state.

### Step 4 — `AppStartupCubit` (bootstrap + onboarding resolution)
Move the splash's startup side-effects here. It emits **status + a resolved
`needsOnboarding` flag** — no destination, no navigation. Resolving onboarding
during startup (first-open check, fetch pages, warm their images) means the gate
reads a synchronous `state.needsOnboarding` and the onboarding screen opens
without a loading flash.

```dart
Future<void> init(String language) async {
  emit(state.copyWith(status: loading));
  try {
    final onboarding = _resolveNeedsOnboarding();   // Future<bool>
    await Future.wait([cache.set(localeKey, language),
                       notifications.init(), onboarding]);
    emit(state.copyWith(status: success, needsOnboarding: await onboarding));
  } catch (_) { emit(state.copyWith(status: error)); }
}

// First launch only: check the flag, fetch pages, precache artwork (bounded,
// best-effort — a slow image must never stall startup). Returning users skip it.
Future<bool> _resolveNeedsOnboarding() async {
  if (!await onboarding.getFirstOpen()) return false;
  final pages = await onboarding.getOnboardingData();
  if (pages.isEmpty) return false;
  await _precacheImages(pages.map((p) => p.image));
  return true;
}

// Called by the onboarding screen's "Get started". Flips the flag (a gate
// source → re-runs the redirect) and persists first-open. No manual navigation.
Future<void> completeOnboarding() async {
  emit(state.copyWith(needsOnboarding: false));
  await onboarding.setFirstOpen();
}
```

`AppStartupState` carries `status` + `needsOnboarding` (+ optional
`errorMessage`). The repository stays pure data access and exposes
`cachedOnboarding` (the primed pages) so `OnboardingCubit` seeds straight into
`success`.

### Step 5 — `DeepLinkService` (instance, not static)
Resolve the cold-start link before the router exists; stream later links.

```dart
class DeepLinkService {
  DeepLinkService({required this.resolver, AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();
  final String? Function(Uri) resolver;
  final _controller = StreamController<String>.broadcast();
  Stream<String> get locations => _controller.stream;
  Future<String?> initialLocation() async {
    final uri = await _appLinks.getInitialLink();
    return uri == null ? null : resolver(uri);
  }
  void start() => _sub ??= _appLinks.uriLinkStream.listen((u) {
    final loc = resolver(u); if (loc != null) _controller.add(loc);
  });
  Future<void> dispose() async { await _sub?.cancel(); await _controller.close(); }
}
```
Keep link-shape parsing (`https://host/...` and custom `scheme://...`) in a
separate `DeepLinks.toLocation(uri)` resolver, like before.

### Step 6 — `AppRouter.build({initialLocation, gate})`
The router only *consumes* the gate; callers never touch redirect plumbing.

```dart
static GoRouter build({required String initialLocation, required AuthGate gate}) =>
  GoRouter(
    initialLocation: initialLocation,
    refreshListenable: gate.listenable,
    redirect: authGuard(routes: guardRoutes, phase: () => gate.phase),
    routes: [ /* ...all GoRoutes... */ ],
  );
```

### Step 7 — Wire `main.dart` (bootstrap) + `app.dart` (widgets)
`main.dart` stays pure bootstrap; the widget tree, providers, gate, and router
live in `app.dart`.

**`main.dart`** — init services, resolve the launch link **before** `runApp`:
```dart
final deepLinks = DeepLinkService(resolver: DeepLinks.toLocation);
final initialLink = await deepLinks.initialLocation();
runApp(/* EasyLocalization, etc. → */ MyApp(deepLinks: deepLinks, initialLocation: initialLink));
```

**`app.dart`** —
1. `MyApp`: `MultiBlocProvider` with **`lazy: false`** for Auth/User/Theme/
   AppStartup so they exist before the router's first redirect runs.
2. `_AppView` (stateful): build the gate from `context.read<...>()` (auth, user,
   **startup** — no onboarding), then the router from the gate.
3. In `didChangeDependencies` (once): kick `AppStartupCubit.init(locale)`, start
   the deep-link service, and `deepLinks.locations.listen(_router.go)`.
4. Dispose the gate and the deep-link service.

```dart
// _AppView:
late final _gate = AuthGate(auth: read<AuthCubit>(), user: read<UserCubit>(),
                            startup: read<AppStartupCubit>());
late final _router = AppRouter.build(
  initialLocation: widget.initialLocation ?? AppRoutes.splash, gate: _gate);
```

### Step 8 — Make the splash pure UI
Delete `SplashCubit`/`SplashState`. The splash is just animations; it never reads
auth state and never navigates. The guard moves the user off it automatically once
`phase` leaves `unknown`.

### Step 9 — Delete the old machinery
Remove `deep_link_handler.dart` (static singleton, `isAppReady`, `_pending`) and
the splash cubit/state. Search the codebase for `context.go`/`context.push` calls
that were doing auth/startup routing and delete them — those decisions now belong
to the guard only. (Feature-level navigation, e.g. "open ticket detail", stays.)

---

## 4. Porting checklist (per target app)

- [ ] List your phases. Most apps need exactly: `unknown, transitioning,
      onboarding, signedOut, signedIn`. Drop `onboarding` if you have none.
- [ ] Map each phase to your cubits in `AuthGate.phase` (precedence: startup →
      onboarding → auth → user/profile).
- [ ] Fill `GuardRoutes` with your route constants + `publicRoutes`
      (signup, forgot-password, etc.).
- [ ] Decide whether `signedIn` is gated on a `/me` profile fetch (recommended)
      or just on the auth token.
- [ ] Provide all gate-source cubits with `lazy: false`.
- [ ] Keep deep-link URL parsing in a `toLocation` resolver; only the plumbing is
      the service.
- [ ] iOS: custom schemes need `SceneDelegate.swift` bridging for `app_links`;
      universal links need entitlements + `.well-known` files. Android: intent
      filters in the manifest. (Unchanged by this refactor.)
- [ ] Splash contains zero navigation.
- [ ] Unit-test `authGuard` directly — it's a pure function over `AuthPhase`.

## 5. Why each decision

- **Redirect as single source of truth** → no two code paths can disagree about
  where the user should be; no ordering races.
- **AuthGate is not a cubit** → it only reads + forwards; making it a cubit that
  listens to other cubits is the cubit-in-cubit anti-pattern.
- **`phase` is a synchronous snapshot** → `redirect` must be sync; the gate gives
  it an instantaneous read, while `listenable` triggers re-evaluation.
- **`unknown` parks on splash** → prevents the classic "flash of login screen"
  before auth resolves.
- **`?from=` round-trip** → a deep link that requires auth survives the login
  detour and lands on the intended page.
- **Instance DeepLinkService** → testable, disposable, no global mutable state.
