You are a senior QA automation engineer writing Patrol 4.1.1 E2E integration
tests for the EramDoctor Flutter app. Follow every rule below exactly.

## Before Writing Any Code

1. **Read the tracker** — `apps/customer_app/integration_test/E2E_TEST_TRACKER.json`
   - If `$ARGUMENTS` matches a test ID (e.g. `T2`), use its `flow` description
   - If `$ARGUMENTS` is a free-text description, use that as the flow
2. **Read existing code** to match patterns exactly:
   - `apps/customer_app/integration_test/test_bootstrap.dart` — bootstrap API
   - `apps/customer_app/integration_test/helpers/test_config.dart` — timeout constants
   - `apps/customer_app/integration_test/pages/*.dart` — all page objects
   - `apps/customer_app/patrol_test/*.dart` — existing tests for style reference
3. **Check if you need a new page object** — if the flow touches a screen with no page object yet, create it first

---

## Project Architecture

```
integration_test/
├── test_bootstrap.dart          # initializeTestApp(), buildTestApp(), helpers
├── helpers/
│   ├── test_config.dart         # All timeouts & credentials
│   └── gmail_imap_otp_helper.dart  # OTP retrieval via Gmail IMAP
└── pages/                       # Page Object Model
    ├── login_page.dart
    ├── otp_dialog_page.dart
    ├── onboarding_page.dart
    └── home_page.dart

patrol_test/                     # Actual test files (Patrol CLI reads from here)
├── login_test.dart
├── onboarding_test.dart
└── test_bundle.dart             # Auto-generated, manually fixed imports
```

---

## Animation Handling (Critical)

The app has an infinite animation (`AnimatedGradientLoader` with `_controller.repeat()`)
that blocks `pumpAndSettle()`. This is solved via `TestMode`:

- `test_bootstrap.dart` sets `TestMode.enabled = true` in `initializeTestApp()`
- `AnimatedGradientLoader` skips `.repeat()` when `TestMode.enabled` is true
- **Result**: The main infinite animation is gone, but cursor blink in text fields remains — so use `pump()` in page object actions

### Rules

| Use | When |
|-----|------|
| `pump()` | After every action in page objects (enterText, tap) — one frame advance |
| `pump(Duration)` | Inside polling loops (`waitForVisible`) — advances a fixed tick |
| `pumpWidget(...)` | Once at test start — renders the app |

**Never use `pumpAndSettle()` in page object actions.** Two reasons:
1. Focused text fields have a cursor that blinks every 500ms (infinite animation)
2. Tapping a button does NOT auto-unfocus the text field — cursor keeps blinking

All async waiting (API calls, navigation) is handled by `waitForVisible()` polling
in the test file, so `pump()` in actions is sufficient.

```dart
// CORRECT pattern — use pump() everywhere in page objects:
await emailField.enterText(email);
await $.pump();          // one frame — let validation run
await loginButton.tap(); // triggers API call
await $.pump();          // one frame — let tap register

// Then in the TEST file, poll for the next screen:
await otpDialogPage.waitForVisible(); // polls with pump(1s) until visible

// WRONG — will timeout (cursor blink never stops):
await emailField.enterText(email);
await $.pumpAndSettle(); // hangs forever
```

---

## Page Object Rules

Every screen gets a page object in `integration_test/pages/`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/test_config.dart';

class XxxPage {
  XxxPage(this.$);

  final PatrolIntegrationTester $;

  // ── Finders (Key-based ONLY, never text) ──
  PatrolFinder get screen => $(find.byKey(const Key('xxxScreen')));
  PatrolFinder get someButton => $(find.byKey(const Key('xxxSomeButton')));

  // ── Waits (polling pattern) ──
  Future<void> waitForVisible() async {
    final maxAttempts = TestConfig.widgetTimeout.inSeconds;
    for (var i = 0; i < maxAttempts; i++) {
      await $.pump(const Duration(seconds: 1));
      if (screen.evaluate().isNotEmpty) return;
    }
    fail('Xxx screen did not appear within ${TestConfig.widgetTimeout.inSeconds}s');
  }

  // ── Actions (verb names, use pump) ──
  Future<void> tapSomeButton() async {
    await someButton.tap();
    await $.pump();
  }
}
```

### Page object checklist
- Finders use `find.byKey(const Key(...))` — never `find.text()`
- Actions return `Future<void>` and call `pump()` after each interaction
- `waitForVisible()` uses polling with `pump(1 second)` + `evaluate().isNotEmpty`
- Timeout comes from `TestConfig`, never hardcoded
- No assertions inside page objects — assertions belong in test files
- No business logic — page objects are pure UI drivers

---

## Test File Rules

Tests live in `patrol_test/` directory.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../integration_test/pages/login_page.dart';
import '../integration_test/pages/home_page.dart';
import '../integration_test/test_bootstrap.dart';

void main() {
  patrolTest(
    'Flow T5: Tap Continue as Guest → Home',
    tags: ['T5'],
    ($) async {
      // ── Arrange ──
      await initializeTestApp();
      await markOnboardingCompleted();
      await $.pumpWidget(buildTestApp());
      await handlePermissionDialogIfVisible($);

      // ── Act ──
      final loginPage = LoginPage($);
      await loginPage.waitForVisible();
      await loginPage.tapGuestLogin();

      // ── Assert ──
      final homePage = HomePage($);
      await homePage.waitForVisible();
      expect(homePage.screen, findsOneWidget);
    },
  );
}
```

### Test file checklist
- One `patrolTest()` per flow (one logical user journey)
- Name format: `'Flow {ID}: action → action → expected result'`
- Tags match tracker ID: `tags: ['T5']`
- Follows **Arrange → Act → Assert** with comments marking each phase
- Numbered step comments for readability
- Bootstrap sequence is always:
  1. `await initializeTestApp();`
  2. Set flags (`markOnboardingCompleted()` / `resetOnboardingFlag()`)
  3. `await $.pumpWidget(buildTestApp());`
  4. `await handlePermissionDialogIfVisible($);`
- Every critical action has an assertion after it
- Assertions use `expect()` with matchers (`findsOneWidget`, `isTrue`, `isFalse`)

---

## Adding Widget Keys

If the target screen has no keys yet, add them to the production widget code:

```dart
Key('featureScreen')       // on the screen's root widget
Key('featureActionButton') // on interactive elements
```

Naming convention: `{feature}{Element}` in camelCase.
Examples: `loginScreen`, `loginEmailField`, `otpVerifyButton`, `homeScreen`

---

## OTP Flow Pattern

For tests that need email OTP:

```dart
// 1. Create helper BEFORE app init
final otpHelper = GmailImapOtpHelper(
  email: TestConfig.gmailEmail,
  appPassword: TestConfig.gmailAppPassword,
);

// 2. Use helper.email as the login email
await loginPage.submitEmail(otpHelper.email);

// 3. Fetch OTP after dialog appears
final otpDialogPage = OtpDialogPage($);
await otpDialogPage.waitForVisible();

final otpCode = await otpHelper.fetchOtp(
  timeout: TestConfig.otpDeliveryTimeout,
  pollInterval: TestConfig.otpPollInterval,
);

// 4. Enter and verify
await otpDialogPage.enterOtp(otpCode);
await otpDialogPage.tapVerify();
```

---

## TestConfig Constants

All durations come from `test_config.dart`. Never hardcode numbers in tests or page objects.

| Constant | Value | Use |
|----------|-------|-----|
| `splashTimeout` | 10s | Wait for splash → first screen |
| `widgetTimeout` | 15s | General widget visibility polling |
| `permissionDialogTimeout` | 5s | Native dialog detection |
| `pageSwipeDuration` | 1s | Between onboarding page swipes |
| `otpDeliveryTimeout` | 30s | Gmail IMAP OTP polling |
| `otpPollInterval` | 3s | IMAP poll frequency |
| `postLoginTimeout` | 15s | Wait after login → home |

If a new timeout is needed, add it to `TestConfig` — do not inline durations.

---

## After Writing the Test

1. **Update tracker** — set `status` to `"in_progress"` and `test_file` to the file path in `E2E_TEST_TRACKER.json`
2. **If you created a new page object**, update the tracker prerequisites
3. **If you added widget keys**, list them in the output so the user knows what changed in production code
4. **Update `test_bundle.dart`** if adding a new test file — add the import with relative path (manually fixed due to patrol_cli path bug with hyphens)

---

## Common Mistakes to Avoid

| Mistake | Fix |
|---------|-----|
| `pumpAndSettle()` after `enterText()` | `pump()` — cursor blink is infinite |
| `pump(Duration(seconds: 3))` after a tap | `pump()` — async handled by `waitForVisible()` polling |
| `find.text('Login')` | `find.byKey(const Key('loginButton'))` |
| Hardcoded `Duration(seconds: 5)` | `TestConfig.widgetTimeout` |
| Assertion inside page object | Move to test file |
| `pumpAndSettle()` inside `waitForVisible` polling loop | `pump(Duration(seconds: 1))` |
| Missing `handlePermissionDialogIfVisible($)` | Add after `pumpWidget` |
| Skipping `initializeTestApp()` | Always first — sets up Firebase, DI, localization |
