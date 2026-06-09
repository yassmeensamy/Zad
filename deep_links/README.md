# Team-invite deep links — smart sharing

Shareable link (always HTTPS):

```
https://zaad-7a0a8.web.app/teams/join?code=ABC12345
```

## Flow

**App installed**
- If App/Universal Links are verified → the OS opens the app directly on the
  Join screen. The web page never loads. (Smoothest path.)
- Otherwise → the link opens the fallback page below, which launches
  `zad://teams/join?code=ABC12345` to open the app.

**App not installed**
- Fallback page loads → tries `zad://…` → on failure redirects to the store:
  - Android: handled by an `intent://` URL with a Play Store
    `browser_fallback_url` (no timing guesswork).
  - iOS: custom scheme + a ~1.6s timer → App Store.
- Desktop / in-app browsers: the code is shown with an "Open in the app"
  button and store link — never a dead end.

`zad://` is **only** used to open the app — it is never the shared link.

## App side (already wired in the Flutter project)

| Concern | Where |
| --- | --- |
| Link/scheme definitions | [lib/core/navigation/deep_links.dart](../lib/core/navigation/deep_links.dart) |
| `?code=` → screen | `/teams/join` route in [app_router.dart](../lib/core/navigation/app_router.dart) |
| `zad://teams/join` → route match | top-level `redirect:` calling `DeepLinks.normalizeLocation` |
| Prefill + auto-submit (8 chars) | [team_join_screen.dart](../lib/features/teams/presentation/screens/team_join_screen.dart) |
| Android https App Link + `zad://` scheme | `AndroidManifest.xml` |
| iOS Universal Link + `zad://` scheme | `Info.plist` + `Runner.entitlements` |

## Deploy (Firebase Hosting)

This folder is a ready Firebase site. From `deep_links/`:

```sh
firebase init hosting   # only the first time; pick existing project, keep "public"
firebase deploy --only hosting
```

`zaad-7a0a8.web.app` is Firebase's **built-in** Hosting domain for project
`zaad-7a0a8` — it serves your files **immediately after deploy**, no DNS or
custom-domain setup needed. Confirm with:

```sh
curl -i https://zaad-7a0a8.web.app/teams/join?code=ABC12345   # should return your index.html
```

(If you later move to a real custom domain, add it in Firebase Console →
Hosting and repoint DNS, then change `host` in
`lib/core/navigation/deep_links.dart`, the Android manifest, the entitlement,
and these files to match.)

### ⚠️ Fill these placeholders before deploying

1. `public/index.html` → `APPSTORE_URL` — replace `REPLACE_WITH_APPLE_APP_ID`
   with your numeric App Store ID (e.g. `id1234567890`).
2. `public/.well-known/assetlinks.json` → `sha256_cert_fingerprints` — your
   **release** signing SHA-256 (Play Console → App signing, or `keytool -list -v
   -keystore <ks> -alias <alias>`). Add both upload and Play app-signing
   fingerprints if you use Play App Signing.
3. `public/.well-known/apple-app-site-association` → `appID` —
   `<AppleTeamID>.com.zad.islamic`.

### iOS one-time Xcode step

`ios/Runner/Runner.entitlements` declares `applinks:zaad-7a0a8.web.app`. Link it to the
target: Runner target → **Signing & Capabilities → + Associated Domains**.
`Info.plist` already has `FlutterDeepLinkingEnabled = true` and the `zad` URL
scheme.

## Verify (must pass before testing the app)

```sh
# JSON, not text/html:
curl -i https://zaad-7a0a8.web.app/.well-known/assetlinks.json
# Your JSON, not "Not Found" (Apple CDN, allow time to cache):
curl   https://app-site-association.cdn-apple.com/a/v1/zaad-7a0a8.web.app
# Android: opens the app (reinstall first — verification runs at install time):
adb shell am start -a android.intent.action.VIEW \
  -d "https://zaad-7a0a8.web.app/teams/join?code=ABC12345" com.zad.islamic
# Custom scheme directly:
adb shell am start -a android.intent.action.VIEW -d "zad://teams/join?code=ABC12345"
```
