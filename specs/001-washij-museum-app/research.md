# Research: WASHIJ Digital Art Museum

No `NEEDS CLARIFICATION` items remained in the Technical Context. The decisions below record the choices.

## 1. Routing with real URLs on the web
- **Decision**: go_router with path URL strategy (`usePathUrlStrategy`), and a hosting rewrite of unknown paths to `index.html`.
- **Rationale**: the spec needs real, directly openable URLs; hash URLs would not match them.
- **Alternatives**: hash routing (rejected: not real URLs); Navigator 1.0 (rejected: no deep links).

## 2. State management
- **Decision**: flutter_riverpod with plain `Provider`/`NotifierProvider`, no code generation.
- **Rationale**: matches the handoff; fewer build steps.
- **Alternatives**: Bloc, Provider (rejected: not the decided stack).

## 3. Data layering
- **Decision**: bundled JSON holds all editorial text plus fallback facts and a Wikidata Q-ID per work. A `RemoteSource` fetches facts and credit data, and `ArtworkRepository` merges them, with bundled values winning for editorial fields and fetched values winning for facts and credit when present.
- **Rationale**: the constitution requires editorial text to be bundled and facts fetched with a fallback.
- **Alternatives**: all-remote (rejected: no editorial text in APIs); all-bundled (rejected: user chose hybrid).

## 4. Remote sources
- **Decision**: Wikidata `wbgetentities` (Arabic labels, dates, medium, dimensions, collection, place and article sitelinks) for facts; Commons `imageinfo` with `extmetadata` and `url` for remote image URLs and credits. The article link uses the Arabic sitelink when present and a verified English sitelink otherwise. No Wikipedia prose is copied into the app.
- **Rationale**: free, keyless, CORS-enabled, and limited to the facts, image URLs and credits selected for the hybrid model.
- **Alternatives**: museum APIs (rejected: partial coverage); scraping (rejected: fragile).
- **Verified**: all 14 Q-IDs and the 13 Commons image files resolve in the public APIs; the Scream has no Wikidata article sitelink, so its verified English Wikipedia page is used.

## 5. Images
- **Decision**: fetch the Commons image URL when online and show the bundled JPEG as an offline or load-failure fallback. The detail page always shows the entire image uncropped; the home hero may crop only with the required label and full-work link.
- **Rationale**: the selected hybrid fetches images from the public API while the bundled copy keeps first visits and offline use reliable.
- **Constraint**: remote image requests are best-effort; do not tint or filter either source. The Starry Night file is 1.2 MB and should be resized only if the measured initial image budget is exceeded, without changing its colours.

## 6. Caching and offline
- **Decision**: fetched facts and Commons metadata are stored with `shared_preferences` keyed by Q-ID with a timestamp (7-day refresh); Flutter's generated service worker caches app assets; bundled JSON and JPEGs cover first and offline visits.
- **Rationale**: simplest path that satisfies the offline requirement.
- **Alternatives**: custom service worker (rejected for now: more risk); IndexedDB (rejected: not needed for this size).

## 7. Fonts
- **Decision**: download Aref Ruqaa, Scheherazade New, Readex Pro, Cormorant Garamond and Amiri TTFs from the Google Fonts repository into `assets/fonts`, declared in `pubspec.yaml`. User approval to download is required before this step.
- **Rationale**: constitution requires bundled fonts.

## 8. Logo and Long Thread
- **Decision**: CustomPaint painters using the 120-grid geometry from the handoff (frame 54×90, thread from (6,98) to (114,22), gaps computed from stroke width), with stroke 5 at 32 px and 7 at 16 px.
- **Rationale**: geometry is fully specified; `prototype/src/app.js` `sym()` is the reference to port.

## 9. Arabic search normalisation
- **Decision**: port `norm` from the prototype: lower-case Latin, strip Arabic diacritics and tatweel, unify alef forms, ya and ta marbuta, collapse whitespace. Unit-test it against the 14 works.

## 10. PWA
- **Decision**: manifest with midnight tile, ivory frame and yellow thread icons (192, 512, maskable), `theme_color` #081B33, standalone display, RTL and Arabic language.

## 11. Reduced motion
- **Decision**: read `MediaQuery.disableAnimations` and use zero-duration transitions and a static hero.

## 12. Hourly painting and home-screen widget
- **Decision**: a native Android App Widget (Kotlin `AppWidgetProvider`, no extra Flutter plugin) that reads the app's bundled JSON and WebP images, plus an in-app section on the home page with the same hourly logic.
- **Rationale**: the user wants a widget that sits on the phone's home screen; a native widget works offline, uses the data already bundled, and needs no background Dart isolate.
- **Alternatives**: the `home_widget` plugin (rejected: adds a dependency and a Dart-to-native data sync that the bundled data does not need); an in-app section only (rejected: not a home-screen widget).
- **Limits**: `updatePeriodMillis` of one hour is approximate (Android may delay it); iOS WidgetKit needs a Mac and Xcode; Arabic text in the widget uses the system font because `RemoteViews` cannot load the bundled fonts reliably.
- **Open check**: the `washij:///artwork/museum/<id>` deep link must be confirmed on a real device or emulator (cold start and app already open).

## 13. Zoom, download and share
- **Decision**: a shared full-screen zoom view, plus `file_saver` for downloads and the existing `share_plus` for sharing; the card is drawn with `dart:ui` rather than captured from a widget.
- **Rationale**: one set of controls for both collections; saving to the device and sharing are separate user intents; drawing the card directly gives a fixed 1080 × 1350 output regardless of screen size.
- **Alternatives**: gallery-saving plugins (rejected: Android and iOS only, no web); capturing a widget with `RepaintBoundary` (rejected: output size depends on the screen).
- **Risks**: cross-origin image fetches on web; Android 10+ saves go through the system, so the exact folder is chosen by the plugin.
