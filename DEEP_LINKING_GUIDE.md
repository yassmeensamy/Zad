# Deep Linking — Reusable Implementation Guide (for Claude)

> **How to use this file:** Drop it into any Flutter project and tell Claude:
> *"Implement deep linking using DEEP_LINKING_GUIDE.md."*
> Claude should follow the steps top-to-bottom, copy each file template verbatim,
> and replace every `<<PLACEHOLDER>>` with the target project's real values.

---

## 0. What this builds

A shareable HTTPS link, e.g. `https://<<HOST>>/<<PATH>>?<<PARAM>>=ABC12345`, that:

1. Opens the app **directly** when installed (Android App Links / iOS Universal Links).
2. Falls back to a **smart web page** when not verified or not installed — the page
   tries the custom scheme (`<<SCHEME>>://`), then redirects to the App/Play Store.
3. Routes the user to the correct screen with the query param pre-filled.

Both `https://` links and `<<SCHEME>>://` links share ONE code path. Flutter's
built-in deep linking is disabled; the `app_links` package owns handling.

---

## 1. Placeholders — collect these FIRST

Before writing any file, ask the user (or infer from the project) and fill in:

| Placeholder | Meaning | Example |
|---|---|---|
| `<<HOST>>` | Verified domain serving `/.well-known/` files | `myapp.web.app` |
| `<<SCHEME>>` | Custom URL scheme (open-app fallback only) | `myapp` |
| `<<PATH>>` | Deep-link path (matches an in-app route) | `/teams/join` |
| `<<PARAM>>` | Query key carried in the link | `code` |
| `<<ANDROID_PACKAGE>>` | Android applicationId | `com.example.myapp` |
| `<<ANDROID_KOTLIN_PATH>>` | Folder of MainActivity.kt | `com/example/myapp` |
| `<<IOS_BUNDLE_ID>>` | iOS bundle identifier | `com.example.myapp` |
| `<<APPLE_TEAM_ID>>` | Apple Developer Team ID | `ABCDE12345` |
| `<<SHA256_FINGERPRINT>>` | Release signing SHA-256 (Android) | `24:BE:...:F5` |
| `<<PLAYSTORE_URL>>` | Play Store listing | `https://play.google.com/store/apps/details?id=...` |
| `<<APPSTORE_URL>>` | App Store listing | `https://apps.apple.com/app/id1234567890` |
| `<<FIREBASE_PROJECT>>` | Firebase project id (for hosting) | `myapp-12345` |

> Find SHA-256 via Play Console → App signing, or
> `keytool -list -v -keystore <ks> -alias <alias>`. Add BOTH upload and
> Play-app-signing fingerprints if using Play App Signing.

---

## 2. Add packages

In `pubspec.yaml` under `dependencies:`

```yaml
  app_links: ^6.3.2     # captures incoming deep links (both schemes)
  go_router: ^17.2.2    # navigation / routing
  share_plus: ^12.0.2   # share the generated link out (optional)
```

Run `flutter pub get`.

> If the project already uses go_router, keep its version and just reuse the
> existing router. Only `app_links` is strictly required.

---

## 3. Dart — link definitions

Create `lib/core/navigation/deep_links.dart`:

```dart
/// Central definition of the app's deep links (Universal Links on iOS /
/// App Links on Android). Change the host/path/scheme HERE only, then mirror
/// the values in AndroidManifest.xml, Runner.entitlements, and the hosted
/// /.well-known/ association files.
class DeepLinks {
  const DeepLinks._();

  /// Verified domain that serves the association files. Must be a domain you
  /// control and can upload `/.well-known/` files to.
  static const String host = '<<HOST>>';

  /// Deep-link path. Must match an existing in-app go_router route.
  static const String teamJoinPath = '<<PATH>>';

  /// Query key carried by the link.
  static const String codeParam = '<<PARAM>>';

  /// Custom scheme used ONLY to open the app (never the shared link). The
  /// fallback web page launches `<<SCHEME>>://...` to reach the app without
  /// relying on domain verification.
  static const String scheme = '<<SCHEME>>';

  /// Builds the shareable URL, e.g. https://<<HOST>><<PATH>>?<<PARAM>>=ABC123.
  static String teamInvite(String code) =>
      Uri.https(host, teamJoinPath, {codeParam: code}).toString();

  /// Maps an incoming deep-link [uri] to a go_router location string, or null
  /// if the link isn't ours. Handles two shapes:
  ///   * https://<host><path>?<param>=...  (App/Universal Link)
  ///   * <scheme>://<path>?<param>=...     (custom scheme — first segment
  ///     parses as the URI host, so we rebuild the full path)
  static String? toLocation(Uri uri) {
    if (uri.scheme == scheme) {
      final segments = [
        uri.host,
        ...uri.pathSegments,
      ].where((s) => s.isNotEmpty).toList();
      return Uri(
        path: '/${segments.join('/')}',
        queryParameters:
            uri.queryParameters.isEmpty ? null : uri.queryParameters,
      ).toString();
    }
    if (uri.scheme == 'https' && uri.host == host) {
      return Uri(
        path: uri.path,
        queryParameters:
            uri.queryParameters.isEmpty ? null : uri.queryParameters,
      ).toString();
    }
    return null;
  }
}
```

---

## 4. Dart — listener service

Create `lib/core/navigation/deep_link_service.dart`:

```dart
import 'dart:async';

import 'package:app_links/app_links.dart';

/// Wraps `app_links`: resolves the cold-start link and streams live links,
/// already converted to go_router location strings via [resolver].
class DeepLinkService {
  DeepLinkService({required this.resolver, AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final String? Function(Uri uri) resolver;

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;
  final _controller = StreamController<String>.broadcast();

  /// Resolved locations from links received while the app is running.
  Stream<String> get locations => _controller.stream;

  /// The link that cold-started the app (or null). Call once at startup.
  Future<String?> initialLocation() async {
    final uri = await _appLinks.getInitialLink();
    return uri == null ? null : resolver(uri);
  }

  /// Begin listening for links delivered while the app is alive.
  void start() => _sub ??= _appLinks.uriLinkStream.listen((uri) {
    final loc = resolver(uri);
    if (loc != null) _controller.add(loc);
  });

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
```

---

## 5. Dart — wire into startup

In `lib/main.dart`, before `runApp`:

```dart
import 'core/navigation/deep_link_service.dart';
import 'core/navigation/deep_links.dart';

// ... inside main(), after WidgetsFlutterBinding.ensureInitialized():
final deepLinks = DeepLinkService(resolver: DeepLinks.toLocation);
final initialLink = await deepLinks.initialLocation();

runApp(MyApp(deepLinks: deepLinks, initialLocation: initialLink));
```

In the app/root widget (pass `deepLinks` and `initialLocation` in), do this ONCE
— `didChangeDependencies` with a guard, or `initState`:

```dart
// Build the router with the cold-start link as its start location:
final router = AppRouter.build(
  initialLocation: widget.initialLocation ?? AppRoutes.splash,
);

// Route live links and clean up:
widget.deepLinks.start();
widget.deepLinks.locations.listen(router.go);

// in dispose():
widget.deepLinks.dispose();
```

---

## 6. Dart — destination route

In the go_router config, ensure the route at `<<PATH>>` reads the query param:

```dart
GoRoute(
  path: DeepLinks.teamJoinPath,          // "<<PATH>>"
  builder: (context, state) => TeamJoinScreen(
    initialCode: state.uri.queryParameters[DeepLinks.codeParam],
  ),
),
```

The destination screen should normalize/prefill the incoming code, e.g.:

```dart
final raw = widget.initialCode ?? '';
final code = raw.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
```

---

## 7. Dart — generate & share the link (optional)

Wherever the user shares an invite:

```dart
import 'package:share_plus/share_plus.dart';

await Share.share('Join my team: ${DeepLinks.teamInvite(code)}');
```

---

## 8. Android — AndroidManifest.xml

In `android/app/src/main/AndroidManifest.xml`, inside the main `<activity>`
(the one with `MAIN`/`LAUNCHER`). Keep `android:launchMode="singleTop"`.

```xml
<!-- app_links owns deep links, not Flutter's built-in routing -->
<meta-data
    android:name="flutter_deeplinking_enabled"
    android:value="false" />

<!-- HTTPS App Link — auto-verified via /.well-known/assetlinks.json -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https"
          android:host="<<HOST>>"
          android:pathPrefix="<<PATH>>"/>
</intent-filter>

<!-- Custom scheme — launched by the fallback web page -->
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="<<SCHEME>>"/>
</intent-filter>
```

---

## 9. Android — MainActivity.kt (CRITICAL fix)

Without this, the launch intent (with the original invite link) is re-delivered
on EVERY app open from recents, wrongly re-triggering the deep-link flow.

`android/app/src/main/kotlin/<<ANDROID_KOTLIN_PATH>>/MainActivity.kt`:

```kotlin
package <<ANDROID_PACKAGE>>

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android re-delivers the original launch intent (incl. the deep-link
        // URI) when the activity is resumed from history/recents. Clearing the
        // data on those launches makes app_links honor deep links ONLY when the
        // app was genuinely opened via a link tap.
        val fromHistory =
            ((intent?.flags ?: 0) and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) != 0
        if (fromHistory) {
            intent?.data = null
        }
        super.onCreate(savedInstanceState)
    }
}
```

---

## 10. iOS — Info.plist

In `ios/Runner/Info.plist`, add inside the top-level `<dict>`:

```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string><<IOS_BUNDLE_ID>>.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string><<SCHEME>></string>
        </array>
    </dict>
</array>
```

> If a `CFBundleURLTypes` array already exists (e.g. for Google Sign-In), ADD a
> new `<dict>` to it rather than replacing the array.

---

## 11. iOS — Runner.entitlements

Create/edit `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:<<HOST>></string>
    </array>
</dict>
</plist>
```

**Xcode one-time step (tell the user — Claude cannot do this):**
Runner target → Signing & Capabilities → **+ Associated Domains**. This links the
entitlements file into the build. Confirm the `Code Signing Entitlements` build
setting points to `Runner/Runner.entitlements`.

---

## 12. Hosting — verification + fallback files

Create a `deep_links/` folder (a self-contained Firebase Hosting site).

### `deep_links/.firebaserc`
```json
{
  "projects": {
    "default": "<<FIREBASE_PROJECT>>"
  }
}
```

### `deep_links/firebase.json`
```json
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "appAssociation": "AUTO",
    "rewrites": [
      { "source": "<<PATH>>/**", "destination": "/index.html" },
      { "source": "<<PATH>>", "destination": "/index.html" }
    ],
    "headers": [
      {
        "source": "/.well-known/apple-app-site-association",
        "headers": [{ "key": "Content-Type", "value": "application/json" }]
      },
      {
        "source": "/.well-known/assetlinks.json",
        "headers": [{ "key": "Content-Type", "value": "application/json" }]
      }
    ]
  }
}
```

### `deep_links/public/.well-known/assetlinks.json`
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "<<ANDROID_PACKAGE>>",
      "sha256_cert_fingerprints": [
        "<<SHA256_FINGERPRINT>>"
      ]
    }
  }
]
```

### `deep_links/public/.well-known/apple-app-site-association`
(no file extension; served as JSON)
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<<APPLE_TEAM_ID>>.<<IOS_BUNDLE_ID>>",
        "paths": ["<<PATH>>", "<<PATH>>/*"]
      }
    ]
  }
}
```

### `deep_links/public/index.html` (smart fallback page)
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <title>Open in the app</title>
  <meta name="robots" content="noindex" />
  <style>
    * { box-sizing: border-box; }
    html, body { margin: 0; height: 100%; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      display: flex; align-items: center; justify-content: center; padding: 24px; text-align: center; }
    .card { width: 100%; max-width: 360px; border: 1px solid #ccc; border-radius: 20px; padding: 32px 24px; }
    h1 { font-size: 22px; margin: 16px 0 6px; }
    p { font-size: 14px; line-height: 1.5; color: #666; margin: 0 0 20px; }
    .code { font-family: ui-monospace, monospace; font-size: 22px; font-weight: 700; letter-spacing: 6px;
      padding: 12px 16px; margin: 0 0 20px; border: 1px solid #ccc; border-radius: 12px; display: inline-block; }
    .btn { display: block; width: 100%; padding: 14px 16px; margin: 8px 0; border-radius: 12px; border: none;
      font-size: 15px; font-weight: 600; cursor: pointer; text-decoration: none; }
    .btn-primary { background: #333; color: #fff; }
    .btn-store { background: #fff; color: #333; border: 1px solid #ccc; }
    .hidden { display: none; }
  </style>
</head>
<body>
  <main class="card">
    <h1>Opening the app…</h1>
    <p id="status">Taking you to the app.</p>
    <div class="code hidden" id="codeBox"></div>
    <a class="btn btn-primary" id="openBtn" href="#">Open in the app</a>
    <a class="btn btn-store hidden" id="storeBtn" href="#">Get the app</a>
    <p class="hidden" id="hint">If the app didn't open, enter the code above in the app.</p>
  </main>

  <script>
    // ── Config — set for your project ─────────────────────────────────────
    var SCHEME          = '<<SCHEME>>';
    var APP_PATH        = '<<PATH>>'.replace(/^\//, '');   // strip leading slash
    var PARAM           = '<<PARAM>>';
    var ANDROID_PACKAGE = '<<ANDROID_PACKAGE>>';
    var PLAYSTORE_URL   = '<<PLAYSTORE_URL>>';
    var APPSTORE_URL    = '<<APPSTORE_URL>>';
    // ──────────────────────────────────────────────────────────────────────

    function getCode() {
      var c = new URLSearchParams(location.search).get(PARAM) || '';
      return c.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 8);
    }
    var ua = navigator.userAgent || '';
    var isAndroid = /android/i.test(ua);
    var isIOS = /iphone|ipad|ipod/i.test(ua) || (/Mac/.test(ua) && navigator.maxTouchPoints > 1);
    var code = getCode();
    var query = code ? '?' + PARAM + '=' + code : '';
    var schemeUrl = SCHEME + '://' + APP_PATH + query;
    var intentUrl = 'intent://' + APP_PATH + query +
      '#Intent;scheme=' + SCHEME + ';package=' + ANDROID_PACKAGE +
      ';S.browser_fallback_url=' + encodeURIComponent(PLAYSTORE_URL) + ';end';
    var storeUrl = isIOS ? APPSTORE_URL : isAndroid ? PLAYSTORE_URL : null;

    if (code) { var b = document.getElementById('codeBox'); b.textContent = code; b.classList.remove('hidden'); }
    var openBtn = document.getElementById('openBtn');
    var storeBtn = document.getElementById('storeBtn');
    var statusEl = document.getElementById('status');
    openBtn.setAttribute('href', isAndroid ? intentUrl : schemeUrl);

    var appOpened = false;
    function markOpened() { appOpened = true; }
    document.addEventListener('visibilitychange', function () { if (document.hidden) markOpened(); });
    window.addEventListener('pagehide', markOpened);
    window.addEventListener('blur', markOpened);

    function revealStore() {
      document.getElementById('hint').classList.remove('hidden');
      if (storeUrl) {
        statusEl.textContent = "Don't have the app yet? Get it below, then enter the code.";
        storeBtn.setAttribute('href', storeUrl);
        storeBtn.textContent = isIOS ? 'Download on the App Store' : 'Get it on Google Play';
        storeBtn.classList.remove('hidden');
      } else {
        statusEl.textContent = 'Open this link on your phone, or enter the code in the app.';
      }
    }
    function attemptOpen() {
      if (isAndroid) { location.href = intentUrl; return; }     // handles store fallback itself
      location.href = schemeUrl;
      setTimeout(function () {
        if (!appOpened && storeUrl) location.href = storeUrl; else revealStore();
      }, 1600);
    }
    openBtn.addEventListener('click', function (e) { e.preventDefault(); attemptOpen(); });
    window.addEventListener('load', function () {
      attemptOpen();
      setTimeout(function () { if (!appOpened) revealStore(); }, 2500);
    });
  </script>
</body>
</html>
```

---

## 13. Deploy the hosting site

```sh
# first time only:
npm install -g firebase-tools && firebase login

cd deep_links
firebase deploy --only hosting
```

> `<<FIREBASE_PROJECT>>.web.app` is Firebase's built-in domain — it serves files
> immediately after deploy, no DNS needed. For a custom domain, add it in
> Firebase Console → Hosting, repoint DNS, then update `<<HOST>>` everywhere.

---

## 14. Verify

```sh
# Fallback page loads:
curl -i "https://<<HOST>><<PATH>>?<<PARAM>>=ABC12345"

# Verification files return application/json (NOT text/html):
curl -i "https://<<HOST>>/.well-known/assetlinks.json"
curl    "https://app-site-association.cdn-apple.com/a/v1/<<HOST>>"   # iOS; allow cache time

# Android (reinstall first — verification runs at install time):
adb shell am start -a android.intent.action.VIEW \
  -d "https://<<HOST>><<PATH>>?<<PARAM>>=ABC12345" <<ANDROID_PACKAGE>>
adb shell am start -a android.intent.action.VIEW -d "<<SCHEME>>://<<PATH-no-leading-slash>>?<<PARAM>>=ABC12345"
```

A successful run opens the app on the destination screen with the code prefilled.

---

## 15. Final checklist (Claude: confirm each)

- [ ] `app_links`, `go_router`, `share_plus` added; `pub get` run.
- [ ] `deep_links.dart` + `deep_link_service.dart` created with real values.
- [ ] `main.dart` resolves `initialLocation` and starts the service.
- [ ] Destination `GoRoute` reads the query param.
- [ ] Manifest: `flutter_deeplinking_enabled=false` + both intent-filters.
- [ ] MainActivity.kt history-clear fix in place.
- [ ] Info.plist: `FlutterDeepLinkingEnabled=false` + custom scheme.
- [ ] Runner.entitlements + Associated Domains capability added in Xcode (user).
- [ ] `assetlinks.json` (package + SHA-256) and `apple-app-site-association`
      (TeamID.bundleId) filled and deployed.
- [ ] `index.html` config block filled; site deployed.
- [ ] All `curl` + `adb` verifications pass.

---

## Notes / gotchas

- **One code path:** both `https://` and `<<SCHEME>>://` resolve through
  `DeepLinks.toLocation` — keep the path matching an existing route so go_router
  navigates automatically.
- **`flutter_deeplinking_enabled` / `FlutterDeepLinkingEnabled` MUST be false** —
  otherwise Flutter's built-in handler competes with `app_links`.
- **SHA-256 must be the RELEASE signing cert** (and the Play App Signing cert if
  used) — debug builds won't verify with a release `assetlinks.json`.
- **iOS verification is cached by Apple's CDN** — allow time after first deploy,
  and reinstall the app to re-fetch the association.
- **apple-app-site-association has NO extension** and must be served as
  `application/json` (the `firebase.json` header handles this).
