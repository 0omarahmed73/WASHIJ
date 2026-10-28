# Quickstart: Validating WASHIJ

## Prerequisites
```bash
export PATH=$HOME/sdks/flutter/bin:$PATH
cd /home/omarahmed/Downloads/WASHIJ/app
flutter pub get
```

## 1. Automated checks
```bash
flutter analyze
flutter test
```
Expect: all unit tests (Arabic normalisation, filter/sort/load-more, repository merge and fallback, data validation of 14/12/9/4 counts and no purchase words) and widget tests at 390, 820 and 1280 pass.

## 2. Run in Chrome
```bash
flutter run -d chrome
```
Walk through: `/` pager 01–03 and the call to action; `/artworks` search "ليلة", "starry" and a diacritic spelling, each filter, sort, load-more to 14, reset, no-results; `/artwork/starry-night` mat, zoom, credit line, related works; `/artwork/persistence-of-memory` shows no image; `/artists`, `/artist/van-gogh`, `/movements`, `/movement/renaissance`.

## 3. Production build and offline
```bash
flutter build web --release
```
Serve `build/web` with a path-rewrite server, load several pages, switch the browser to offline, reload, and confirm pages and bundled facts still show and the install prompt is offered.

## 4. Responsive and motion
Check 390, 820 and 1280 px widths for no horizontal scroll, and enable reduced motion to confirm the hero is static.

## Expected outcomes
Map to spec SC-001 to SC-007; see [spec.md](spec.md), [data-model.md](data-model.md) and [contracts/](contracts/).

## Validation record — 2026-10-28

- `flutter analyze`: no issues. `flutter test`: all 39 tests passed.
- `flutter build web --release`: succeeded after fixing the custom bootstrap's
  local font-fallback URL scope.
- A clean browser load rendered the 1280 px RTL home page. The bundled WASHIJ,
  Roboto and CJK fallback fonts loaded locally; no `fonts.gstatic.com` requests
  occurred. Wikidata and Commons requests returned HTTP 200.
- Served the release bundle with an application-path rewrite. Direct artist
  routing and browser back/forward worked. At 390, 820 and 1280 px, the page
  had no horizontal overflow.
- After loading the artist page online, the server was stopped. Direct route
  load, back and forward still rendered from the service-worker cache with no
  browser runtime errors. Previously fetched artwork images are available
  offline; an artwork's image is cached the first time it is requested.
- The cache included the shell, manifest, icons, CanvasKit, fonts, catalog JSON
  and requested fallback paintings. The manifest was readable offline and
  declared Arabic/RTL, standalone display, and 192/512 px icons. Browser
  automation did not expose the native install prompt UI, so that prompt still
  needs a manual check in a supported browser after deployment.
- Widget tests cover reduced-motion pager behavior. Arabic copy still needs
  native-editor and art-historian review before production.

## 5. Hourly painting and Android widget

```bash
export PATH=$HOME/sdks/flutter/bin:$PATH
cd /home/omarahmed/Downloads/WASHIJ/app
flutter test test/unit/hourly_painting_test.dart
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Then on the device: long-press the home screen, add the "لوحة الساعة | وَشيج" widget, press refresh (a different painting appears), tap the painting (its page opens in the app), and change the clock by one hour to see the painting change. Check it at 3 × 3 and 4 × 2 sizes and with the device offline.
