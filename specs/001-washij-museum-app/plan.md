# Implementation Plan: WASHIJ Digital Art Museum

**Branch**: `001-washij-museum-app` | **Date**: 2026-10-28 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-washij-museum-app/spec.md`

## Summary

Port the WASHIJ web prototype to a Flutter web-first PWA in `app/`. Editorial Arabic text and structure are bundled as JSON ported from `prototype/src/data.js`. Facts, images and credits are fetched from Wikidata, Wikimedia Commons and Arabic Wikipedia through one typed repository, cached, and backed by bundled facts and images. Routing uses go_router with real URLs, state uses Riverpod, and the logo and Long Thread are drawn with CustomPaint.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (installed at `~/sdks/flutter`, not on PATH; no upgrade)

**Primary Dependencies**: go_router, flutter_riverpod, http, shared_preferences (cache); no code generation

**Storage**: bundled JSON and JPEG fallbacks; fetched Wikidata facts and Commons metadata cached in browser storage for 7 days; service worker caches app assets

**Testing**: `flutter test` (unit for normalisation, filter/sort, repository merge; widget tests per page at 390/820/1280), `integration_test` smoke run in Chrome

**Target Platform**: Web PWA (Chrome, Safari, Firefox); the usual Flutter platform folders are generated but not shipped

**Project Type**: single Flutter app (web-first)

**Performance Goals**: first meaningful content under 3 s on mobile; 60 fps scrolling; initial image budget under 1.5 MB

**Constraints**: offline-capable; RTL; dark only; bundled fonts; no backend, auth or payments

**Scale/Scope**: 14 works, 12 artists, 9 movements, 4 periods, 7 route types

## Constitution Check

*GATE: passed before research and re-checked after design.*

| Principle | Status | How the plan satisfies it |
|---|---|---|
| I Museum not marketplace | Pass | No commerce fields in the model; a test greps strings for purchase words |
| II Original colours | Pass | Images use plain `Image` with no colour filters; only the hero crops, labelled |
| III Dark only | Pass | Single `ThemeData` from tokens; 2px focus ring; Long Thread in margin layer |
| IV Arabic-first RTL | Pass | Root `Directionality` RTL, fonts as assets, no Arabic letter spacing |
| V Accessible | Pass | Reduced-motion check, focus visibility, layout tests at 3 widths |
| VI Hybrid data | Pass | `ArtworkRepository` merges bundled and fetched; credit line required |
| VII Editorial integrity | Pass | Editorial fields labelled WASHIJ; interpretation attribution required in the model |
| VIII Simple stack | Pass | Flutter, go_router, Riverpod only; no backend |

## Project Structure

### Documentation (this feature)

```text
specs/001-washij-museum-app/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── routes.md
│   ├── editorial-data.schema.json
│   └── remote-sources.md
└── tasks.md             # created by /speckit-tasks
```

### Source Code (repository root)

```text
app/
├── pubspec.yaml
├── assets/
│   ├── data/             # works.json, artists.json, movements.json, periods.json
│   ├── img/              # 13 JPEGs copied from prototype/img
│   └── fonts/            # Aref Ruqaa, Scheherazade New, Readex Pro, Cormorant Garamond, Amiri
├── lib/
│   ├── main.dart
│   ├── app.dart                  # MaterialApp.router, theme, RTL
│   ├── router.dart               # go_router with the 7 routes
│   ├── theme/                    # tokens.dart, typography.dart, theme.dart
│   ├── paint/                    # logo_symbol.dart, long_thread.dart, wordmark.dart
│   ├── data/
│   │   ├── models/               # artwork, artist, movement, period, credit, interpretation
│   │   ├── arabic_normalise.dart
│   │   ├── bundled_source.dart
│   │   ├── remote_source.dart    # Wikidata facts and Commons image/credit clients
│   │   ├── fact_cache.dart
│   │   └── repository.dart       # merge, fallback
│   ├── state/                    # providers: repository, search, filters, sort, pager, hero
│   ├── widgets/                  # shell, header, drawer, search overlay, cards, mat, lightbox, footer
│   └── pages/                    # home, collection, artwork, artists, artist, movements, movement, not_found
├── web/                          # index.html, manifest.json, icons, service worker
└── test/
    ├── unit/
    ├── widget/
    └── integration/
```

**Structure Decision**: one Flutter app under `app/`, layered by theme, paint, data, state, widgets and pages. The prototype folder stays as the reference and as the source of the data and images.

### Android home-screen widget (added after the web app)

A native Android App Widget reads the same bundled data and images as the Flutter app, so it works offline and needs no backend or Flutter code at runtime.

```text
app/android/app/src/main/
├── kotlin/com/washij/washij/PaintingWidgetProvider.kt   # hourly pick, refresh, tap
├── res/layout/painting_widget.xml                       # whole painting on a mat, title, artist, refresh
├── res/xml/painting_widget_info.xml                     # resizable, updatePeriodMillis = 1 hour
├── res/drawable/widget_background.xml, ic_widget_refresh.xml
├── res/values/colors.xml, strings.xml                   # tokens and Arabic strings
└── AndroidManifest.xml                                  # receiver for the provider
```

- **Data:** reads `flutter_assets/assets/data/museum_paintings_ar.json` and the `image_asset` WebP from the APK assets; only paintings with an image are eligible.
- **Choice:** seeded by hours since the Unix epoch so the pick is stable in an hour; the refresh button increments a counter stored in `SharedPreferences`; the counter resets each hour and never repeats the previous pick.
- **Tap:** an `ACTION_VIEW` intent with `washij:///artwork/museum/<id>` aimed at `MainActivity`; the Flutter router reads the path and opens the painting's page.
- **Images:** the painting fills the widget edge to edge (no mat, 8 dp top margin, slim caption below); decoded with `inSampleSize` to at most 1080 px per side to stay within the launcher's memory limit. `ImageView` uses `centerInside` and no tint, so tall paintings keep some side space rather than being cropped.
- **In-app twin:** `lib/widgets/hourly_painting.dart` and `lib/state/hourly_painting_state.dart` show the same hourly painting on the app home page.
- **Not covered:** an iOS widget (needs Xcode and a Mac); exact on-the-hour updates (Android updates a widget about hourly, not precisely on the hour).

### Zoom, download and share for museum paintings (added)

```text
app/lib/
├── data/models/shareable_painting.dart   # one shape for translated and Cleveland paintings
├── data/painting_export.dart             # load image bytes, render the card PNG, save (file_saver), share (share_plus)
├── widgets/painting_lightbox.dart        # the curated works' framed zoom container, for any painting: mat, corner marks (CornerMarksPainter from mat.dart), up to 4x, Escape
└── widgets/painting_actions.dart         # zoom, download image, share image, download card, share card
```

- **Dependency:** `file_saver` (saves on Android, iOS and web); sharing reuses the existing `share_plus`.
- **Image:** the original image is fetched when online and passed through unchanged; the bundled WebP is the offline fallback. Live Cleveland paintings have no bundled copy, so they need a connection.
- **Card:** drawn with `dart:ui` from the app's tokens and bundled fonts, with the whole painting contained in the mat. The curated-works card in `artwork_share_card.dart` is left as it is; the new renderer follows its layout.
- **Pages:** `museum_painting_page.dart` and `cleveland_artwork_page.dart` open the lightbox on tap and show the five buttons under the image. `artwork_page.dart` (the 14 curated works) shows the four download and share buttons (its own yellow zoom button stays); a curated work with no image keeps the original typographic share card.
- **Where files go:** `saveToDownloads` writes to `Download/WASHIJ` on Android (MediaStore, no permission on Android 10+), the browser download on web, and the Downloads folder on desktop; iOS uses the app's Documents folder. The first build used `saveFile`, which on Android writes to the app's private folder and is invisible to the user; this was found on a real device and fixed.
- **Known limit:** on the web, fetching images from another site needs that site to allow cross-origin requests; the bundled copy covers the 399 translated paintings.

## Complexity Tracking

No constitution violations; nothing to justify.
