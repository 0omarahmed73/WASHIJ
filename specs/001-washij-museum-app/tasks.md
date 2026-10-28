---

description: "Task list for the WASHIJ digital art museum"
---

# Tasks: WASHIJ Digital Art Museum

**Input**: Design documents from `/specs/001-washij-museum-app/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Included, because the plan requires Arabic normalisation unit tests and checks at 390, 820 and 1280 px.

**Environment**: run `export PATH=$HOME/sdks/flutter/bin:$PATH` before any flutter command. Paths are relative to `/home/omarahmed/Downloads/WASHIJ`. Do not upgrade Flutter.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [x] T001 Create the Flutter app with `flutter create --platforms=web,android,ios,linux --org com.washij --project-name washij app` in `app/`
- [x] T002 Add dependencies go_router, flutter_riverpod, http, shared_preferences to `app/pubspec.yaml` and run `flutter pub get`
- [x] T003 [P] Copy the 13 JPEGs from `prototype/img/` to `app/assets/img/` and declare the folder in `app/pubspec.yaml`
- [x] T004 [P] ASK THE USER FIRST, then download TTFs for Aref Ruqaa (400,700), Scheherazade New (400,700), Readex Pro (300–700), Cormorant Garamond (500) and Amiri Bold into `app/assets/fonts/`, and declare them in `app/pubspec.yaml`
- [x] T005 [P] Fix paths in `prototype/build.py` and `prototype/qa.py` so they point to the real project folder
- [x] T006 Configure `app/analysis_options.yaml` (flutter_lints) and enable `usePathUrlStrategy()` in `app/lib/main.dart`

## Phase 2: Foundational (blocks all user stories)

- [x] T007 [P] Define colour tokens from `design-system/project/tokens.json` in `app/lib/theme/tokens.dart` (midnight #081B33, deep-blue #0E2542, night-raised #14305A, indigo #1E3A8A, cobalt #2563EB, muted-sky #7DA3D8, mist #9FB3CF, ivory #F6F2E9, star-yellow #F2C94C, hairline #1F3A5F, border-control #5E7CA6, danger #E8907A)
- [x] T008 [P] Define text styles in `app/lib/theme/typography.dart` (headings Aref Ruqaa, reading Scheherazade New, UI Readex Pro, English display Cormorant Garamond, wordmark Amiri Bold; no Arabic letter spacing)
- [x] T009 Build the single dark `ThemeData` in `app/lib/theme/theme.dart`: square corners, hairline borders, 2px star-yellow focus ring, no light theme
- [x] T010 [P] Port Arabic normalisation (`norm` in `prototype/src/app.js`) to `app/lib/data/arabic_normalise.dart`: lower-case, strip diacritics and tatweel, unify alef, ya, ta marbuta, collapse whitespace
- [x] T011 [P] Write unit tests in `app/test/unit/arabic_normalise_test.dart` for diacritic, alef, ya, ta marbuta, Latin and whitespace cases
- [x] T012 [P] Create models Artwork, ImageRef, Credit, Detail, Interpretation, Related in `app/lib/data/models/artwork.dart` per `data-model.md` (Interpretation attribution non-empty; Related reason non-empty)
- [x] T013 [P] Create models Artist, Movement, Period in `app/lib/data/models/artist.dart`, `movement.dart`, `period.dart` (periods: p1 <1600, p2 1600–1699, p3 1700–1899, p4 >=1900)
- [x] T014 Convert `prototype/src/data.js` into `app/assets/data/works.json`, `artists.json`, `movements.json`, `periods.json` matching `contracts/editorial-data.schema.json` (14 works, 12 artists, 9 movements, 4 periods; Persistence of Memory has `image: null`), using a one-off script kept in `app/tool/convert_data.mjs`
- [x] T015 Add verified qid, Commons file name, Wikipedia URL and credit fallback to each work in `app/assets/data/works.json` using prototype image metadata; verify Q-IDs and Commons metadata against the public APIs
- [x] T016 Write `app/lib/data/bundled_source.dart` to load and parse the asset JSON
- [x] T017 [P] Write `app/test/unit/data_validation_test.dart`: counts 14/12/9/4, every artwork has artist, movement, poem, credit and story; every interpretation has attribution; every related target exists; no price, cart, bid or purchase words in any string
- [x] T018 [P] Write `app/lib/data/remote_source.dart` with Wikidata and Commons clients per `contracts/remote-sources.md` (6 s timeout, failures return null)
- [x] T019 [P] Write `app/lib/data/fact_cache.dart` using shared_preferences keyed by Q-ID with a 7-day refresh
- [x] T020 Write `app/lib/data/repository.dart` merging bundled and fetched data per the merge rules, with offline fallback
- [x] T021 [P] Write `app/test/unit/repository_test.dart` covering fetched-wins-for-facts, bundled-wins-for-editorial, failure fallback and stale cache
- [x] T022 Create Riverpod providers in `app/lib/state/providers.dart` (repository, works, artists, movements, periods)
- [x] T023 [P] Draw the logo symbol (120-grid, frame 54×90 at x33–87 y15–105, thread (6,98)→(114,22), stroke 3.2, thickening to 5 at 32 px and 7 at 16 px, over/under gaps) in `app/lib/paint/logo_symbol.dart` using `prototype/src/app.js` `sym()` as reference
- [x] T024 [P] Draw the Long Thread margin painter in `app/lib/paint/long_thread.dart` and the wordmark in `app/lib/paint/wordmark.dart` (Amiri Bold with yellow fatha; WASHIJ in Cormorant Garamond 500, uppercase, tracking 0.32em)
- [x] T025 Build the router in `app/lib/router.dart` for the 7 routes plus not-found per `contracts/routes.md`, and `app/lib/app.dart` with RTL `Directionality`, Arabic locale and the theme
- [x] T026 Build the shell in `app/lib/widgets/shell.dart` with header (logo and five destinations), footer, back navigation, and `app/lib/widgets/drawer.dart` for mobile widths
- [x] T027 [P] Build shared widgets in `app/lib/widgets/`: `artwork_card.dart`, `mat.dart` (original colours, no filter), `section_header.dart`, `thread_separator.dart`
- [x] T028 [P] Build `app/lib/pages/not_found_page.dart` linking to `/artworks`
- [x] T029 Add `app/test/widget/shell_test.dart` checking the shell at 390, 820 and 1280 px with no overflow

**Checkpoint**: app boots, routes resolve to placeholders, theme and data load.

## Phase 3: User Story 1 - Browse and search the collection (P1) 🎯 MVP

**Goal**: search, filter, sort and load more in the collection.

**Independent Test**: open `/artworks`, search "ليلة" and "starry", apply each filter, sort, load more to 14, reset, reach no-results.

- [x] T030 [P] [US1] Write `app/test/unit/collection_logic_test.dart`: search matches Arabic and Latin names with variants, filters combine, sort by date and title, load-more steps of 6, reset keeps sort
- [x] T031 [US1] Implement filter, sort and search logic in `app/lib/state/collection_state.dart` (query, movement, artist, period, sort default `date-asc`, shown 6; filter or search change resets shown to 6)
- [x] T032 [US1] Build `app/lib/pages/collection_page.dart` with search field, dropdown filters, sort, active-filter chips, reset, load-more button and results grid
- [x] T033 [US1] Add the no-results state with reset action in `app/lib/pages/collection_page.dart`
- [x] T034 [US1] Support query parameters `q`, `movement`, `artist`, `period`, `sort` on `/artworks` in `app/lib/router.dart`
- [x] T035 [US1] Build the search overlay in `app/lib/widgets/search_overlay.dart` and wire it to the header
- [x] T036 [US1] Add `app/test/widget/collection_page_test.dart` at 390, 820 and 1280 px

**Checkpoint**: US1 works alone.

## Phase 4: User Story 2 - View a painting in depth (P1)

**Goal**: full artwork page.

**Independent Test**: open `/artwork/starry-night` and `/artwork/persistence-of-memory` directly.

- [x] T037 [P] [US2] Build `app/lib/widgets/lightbox.dart` (zoom view closable with Escape and a visible control)
- [x] T038 [P] [US2] Build `app/lib/widgets/crop_detail.dart` for detail crops from the `crop` rect (Starry Night only where defined)
- [x] T039 [US2] Build `app/lib/pages/artwork_page.dart`: whole uncropped painting on a mat with corner marks, titles, poem line labelled as WASHIJ's, artist chip, facts, story, reading, details, interpretations each with attribution, sources and credits, related works each with reason
- [x] T040 [US2] Add the credit line (author, licence, file page link, article link, CC BY-SA attribution) to `app/lib/pages/artwork_page.dart`
- [x] T041 [US2] Render the withheld-image placeholder for works with `image: null` in `app/lib/pages/artwork_page.dart` and make sure no image widget renders
- [x] T042 [US2] Add the sticky sub-nav and the side-margin Long Thread on wide screens in `app/lib/pages/artwork_page.dart`
- [x] T043 [US2] Handle image load failure and unknown id (not-found) in `app/lib/pages/artwork_page.dart`
- [x] T044 [US2] Add `app/test/widget/artwork_page_test.dart` at 390, 820 and 1280 px, including the no-image work and the credit line

## Phase 5: User Story 3 - Explore through the home page (P2)

**Goal**: the home page.

**Independent Test**: open `/`, use the pager, follow links.

- [x] T045 [US3] Add hero state (index, pager) in `app/lib/state/hero_state.dart`
- [x] T046 [US3] Build the hero in `app/lib/widgets/hero.dart`: Starry Night, Great Wave and Night Watch, tagline, poem line, call to action "استكشف اللوحات", pager 01/02/03, yellow thread curve, crop label with link to the full work, static when reduced motion is on
- [x] T047 [P] [US3] Build `app/lib/widgets/manifesto_band.dart` and `app/lib/widgets/frames_strip.dart` (Long Thread frames strip ported from `weave()`)
- [x] T048 [P] [US3] Build `app/lib/widgets/spotlight.dart` for The Great Wave with historical context, and `app/lib/widgets/discovery_rail.dart` (scrolling rail)
- [x] T049 [P] [US3] Build `app/lib/widgets/featured_artists.dart`, `movements_list.dart`, `threads_section.dart` and `entry_tiles.dart`
- [x] T050 [US3] Assemble `app/lib/pages/home_page.dart` with curated collection and footer credits
- [x] T051 [US3] Add `app/test/widget/home_page_test.dart` at 390, 820 and 1280 px, including pager and reduced motion

## Phase 6: User Story 4 - Artists and movements (P2)

**Goal**: index and detail pages.

**Independent Test**: open `/artists`, `/artist/van-gogh`, `/movements`, `/movement/renaissance`.

- [x] T052 [P] [US4] Build `app/lib/pages/artists_page.dart` and `app/lib/pages/artist_page.dart` (bio, style, works by the artist)
- [x] T053 [P] [US4] Build `app/lib/pages/movements_page.dart` and `app/lib/pages/movement_page.dart` (period, place, introduction, traits, artists, works)
- [x] T054 [US4] Add `app/test/widget/artist_movement_pages_test.dart` at 390, 820 and 1280 px, including unknown ids

## Phase 7: User Story 5 - Navigation and offline (P3)

**Goal**: installable app that works offline.

**Independent Test**: build release, visit pages, go offline, reload.

- [x] T055 [US5] Write `app/web/manifest.json` (name WASHIJ, RTL, lang ar, standalone, theme and background #081B33)
- [x] T056 [P] [US5] Generate icons 192, 512 and maskable from the symbol (midnight tile, ivory frame, yellow thread) into `app/web/icons/`
- [x] T057 [US5] Update `app/web/index.html` (title, description, theme colour, RTL, manifest link)
- [x] T058 [US5] Verify the generated service worker caches fonts, images and data assets, and add a hosting rewrite note for path URLs in `app/web/README.md`
- [x] T059 [US5] Verify back navigation and browser back/forward on all routes in `app/test/integration/navigation_test.dart`
- [x] T060 [US5] Manually verify offline behaviour by following `specs/001-washij-museum-app/quickstart.md` section 3

## Phase 8: Polish & Cross-Cutting

- [x] T061 [P] Add a test in `app/test/unit/no_commerce_test.dart` that scans source strings and assets for price, cart, bid and purchase words
- [x] T062 [P] Confirm no `ColorFiltered`, `Opacity` or blend modes are applied to painting images (grep in `app/lib/`)
- [x] T063 [P] Check reduced-motion handling on every animated widget in `app/lib/widgets/`
- [x] T064 Run the quickstart validation in `specs/001-washij-museum-app/quickstart.md` and record results
- [x] T065 Resize `app/assets/img/starry-night.jpg` only if the initial image budget is exceeded, without changing its colours
- [x] T066 Run `flutter analyze` and `flutter test` in `app/` and fix all failures
- [x] T067 Add a note in `app/README.md` that Arabic copy needs native-editor and art-historian review before production

## Dependencies & Execution Order

- Phase 1 → Phase 2 → user stories. US1 and US2 can run in parallel after Phase 2; US3 and US4 after Phase 2 (they reuse shared widgets); US5 after at least US1 and US2 exist; Polish last.
- T004 (font download) needs user approval; T008 and T009 depend on it for final rendering but can use fallback fonts meanwhile.
- T014 before T015, T016, T017; T016 before T020; T020 before T022; T022 before every page task.
- T025 and T026 before any page can be viewed.

## Parallel Opportunities

- Phase 1: T003, T004, T005 together.
- Phase 2: T007, T008, T010, T012, T013, T018, T019, T023, T024 together; tests T011, T017, T021 alongside their code.
- US3: T047, T048, T049 together. US4: T052 and T053 together.

## Implementation Strategy

- **MVP**: Phases 1 and 2, then US1 (collection) and US2 (artwork), then stop and validate.
- Then add US3 (home), US4 (artists and movements), US5 (PWA), and Polish.
- Commit or checkpoint after each phase and run `flutter analyze` and `flutter test`.

## Phase 9: Live museum paintings and Arabic art readings

- [x] T068 Replace the blocked Chicago API integration with the Cleveland Museum of Art CC0 Painting source and optional Wikidata Arabic labels.
- [x] T069 Add a supplemental painting detail route and source-linked factual detail page.
- [x] T070 Add online supplemental paintings to the collection with loading, empty, error, retry, and pagination states.
- [x] T071 Add the allowlisted Arabic RSS reading repository with short excerpts, source attribution, local cache, and original links.
- [x] T072 Add the `/readings` route and navigation entry with responsive Arabic reading cards and clear loading/error/empty states.
- [x] T073 Update this specification, source contracts, route contract, and app README to describe the hybrid catalog and reading feed.
- [x] T074 Run static analysis and Android/web release builds after dataset integration; report runtime/device checks separately.
- [x] T075 Bundle the corrected 400-record translation file as source-validated offline museum data.
- [x] T076 Add source-specific detail pages with translation status and CC BY 4.0/CC0 attribution.

## Phase 10: Translated painting images and reminders

- [x] T077 Download and optimize the 399 available translated-painting images into bundled WebP assets.
- [x] T078 Use the local images in translated painting cards, details, and the hourly home painting.
- [x] T079 Include translated paintings in the alternating daily reminder schedule and route taps to their museum detail page.

**Pending external data**: `tools/out/paintings/wikidata_ar.json` contains 487 Arabic Wikipedia records but is not merged into the app. Its work-to-museum matching and CC BY-SA attribution need separate validation first.

## Phase 11: Convergence

- [x] T080 CRITICAL: Apply and verify a visible 2px star-yellow keyboard-focus ring to all interactive controls per Constitution III and V.

## Phase 12: Hourly painting and Android home-screen widget

- [x] T081 [US8] Add `app/lib/state/hourly_painting_state.dart`: hour slot, deterministic pick among paintings with a local image, no repeat on refresh, timer to the next hour, injectable clock.
- [x] T082 [US8] Add `app/lib/widgets/hourly_painting.dart` and place it after the curated collection in `app/lib/pages/home_page.dart`: whole painting, Arabic title, artist, source, outlined refresh button, tap opens `/artwork/museum/<id>`, no fade with reduced motion.
- [x] T083 [US8] Add `app/test/unit/hourly_painting_test.dart` (5 tests: hour boundary, stable pick, no repeat, image-less excluded, controller state); all 5 pass.
- [ ] T084 [US8] Fix `app/test/widget/hourly_painting_test.dart` (390/820/1280 px, refresh, tap): it fails at 820 and 1280 px and in the refresh test (the section text is not found after scrolling); the app's 3.3 s native start-up splash also blocks taps in tests, which breaks the existing `home_page_test.dart` hero test and `navigation_test.dart` independently of this feature.
- [x] T085 [US8] Add the native Android widget: `PaintingWidgetProvider.kt`, `painting_widget.xml` layout, `painting_widget_info.xml` (resizable, hourly update), background and refresh drawables, colours, Arabic strings, and the receiver in `AndroidManifest.xml`.
- [x] T086 [US8] Build the debug APK with the widget (`flutter build apk --debug` succeeded).
- [x] T087 [US8] Show the user a visual preview of the widget at 3 × 3 and 4 × 2 sizes using a real painting (a mock-up of the layout, not a device screenshot).
- [x] T088 [US8] Install the release APK on a real device (Samsung SM-S721B, Android 16), add the widget, and verify refresh and tap-to-open. Verified on 2026-10-29 with screenshots in `tools/out/device/`: the widget showed a painting, the refresh button changed it, and tapping it opened `/artwork/museum/<id>` (Poussin, *The Return of the Holy Family to Nazareth*) inside the app on a fresh install.
- [ ] T088a [US8] Still unverified on the device: the hourly automatic change, offline use, the 4 × 2 and small sizes, and the tap when the app is already open in the background.
- [ ] T089 [US8] Confirm the widget at small sizes (110 dp) and RTL: refresh button position (bottom-left) and Arabic text do not overlap.
- [ ] T090 [US8] Decide whether to bundle an Arabic font for the widget (RemoteViews uses the system font now) and whether to add an iOS WidgetKit widget (needs a Mac and Xcode).
- [x] T091 [US8] Enlarge the widget painting at the user's request: remove the mat and side padding, keep an 8 dp top margin, shrink the caption, decode up to 1080 px; rebuilt, installed on the device, and the user confirmed it looks better (2026-10-29).

## Phase 13: Zoom, download and share (US9)

- [x] T092 [US9] Add `app/lib/data/models/shareable_painting.dart` with factories for translated museum paintings and live Cleveland paintings.
- [x] T093 [US9] Add `app/lib/data/painting_export.dart`: original image with bundled fallback, card PNG renderer (whole painting, titles, artist, date, credit, licence), save and share helpers; add the `file_saver` dependency.
- [x] T094 [US9] Add `app/lib/widgets/painting_lightbox.dart`: full-screen zoom up to 6x with double-tap, close button and Escape.
- [x] T095 [US9] Add `app/lib/widgets/painting_actions.dart` (zoom, download image, share image, download card, share card; outlined, focus ring, Arabic messages) and use it with tap-to-zoom in `museum_painting_page.dart` and `cleveland_artwork_page.dart`.
- [x] T096 [US9] Add `app/test/unit/painting_export_test.dart` (6 tests, passing) and `app/test/widget/painting_actions_test.dart` (390/820/1280 px, zoom open and close; 3 tests, passing); add an optional `overrides` argument to `washijTestApp` in `app/test/support/test_catalog.dart`.
- [x] T097 [US9] Build the release APK and install it on the device.
- [x] T098 [US9] Verified on the device (Samsung SM-S721B, 2026-10-29): zoom, image download and card download work for a translated painting; see T102 and T105 for the rest. Share sheets and a live Cleveland painting are not yet exercised.
- [ ] T099 [US9] Verify on web (Chrome): downloads and the share fallback, and whether remote images load across origins.
- [x] T100 [US9] Fix: downloads on Android went to the app's private folder (`Android/data/com.washij.washij/files/`), which the user could not see. Switched `PaintingExport.save` to `saveToDownloads` with the `WASHIJ` subfolder (iOS keeps `saveFile`); found on the user's device.
- [x] T101 [US9] Add the same controls to the 14 curated works: `ShareablePainting.fromArtwork`, `PaintingActions(showZoom: false)` on `artwork_page.dart` next to the existing yellow zoom button; works without an image keep the typographic share card; 2 widget tests added (390 and 1280 px).
- [x] T102 [US9] Verified on the device: `Download/WASHIJ/washij-aic-81540.webp` (translated painting, 97 KB) and `washij-starry-night-card.png` (curated painting, 1080 x 1350) appear in the public Downloads folder. The live Cleveland painting is not yet checked.
- [ ] T103 Pre-existing, not from this feature: `app/test/widget/artwork_page_test.dart` (4 tests), `home_page_test.dart` (hero) and `navigation_test.dart` fail because the 3.3 s start-up splash overlay blocks taps in tests; give tests a way to skip the splash.
- [x] T104 [US9] At the user's request, replace the full-screen zoom with the same framed container the curated works use: `painting_lightbox.dart` now builds the square dialog, nightRaised mat, corner marks and 4x `InteractiveViewer`, sized to the painting once its image has decoded; `CornerMarksPainter` in `mat.dart` made public for reuse; widget test waits for the image to decode. The first design (full screen, 6x, double-tap) is removed.
- [x] T105 [US9] Verified on the device: a translated painting opens in the framed zoom container (mat, corner marks, close button). A live Cleveland painting is not yet checked.
- [x] T106 [US9] Card spacing fixed in `painting_export.dart` and `artwork_share_card.dart` (wordmark up 9 px, tagline down 10 px, artist box taller, detail line down 19 px); verified by downloading the card on the device and viewing it (2026-10-29).
- [ ] T107 [US9] Exercise the share sheets (image and card) and a live Cleveland painting on the device.
