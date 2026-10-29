# WASHIJ | وَشيج

**كل لوحة خيط في حكاية الفن** — Every painting is a thread in the story of art.

WASHIJ is an Arabic-first digital art museum for exploring paintings, artists,
art movements, and the relationships between them. It is a museum experience:
there are no prices, carts, bids, or purchase flows.

| | |
|---|---|
| **Open the museum** | [washij.vercel.app](https://washij.vercel.app) |
| **Android and source releases** | [GitHub Releases](https://github.com/0omarahmed73/WASHIJ/releases) |
| **Repository** | [github.com/0omarahmed73/WASHIJ](https://github.com/0omarahmed73/WASHIJ) |

## What’s inside

- An Arabic-first, right-to-left interface with a dark museum palette, bundled
  Arabic and Latin fonts, and responsive layouts for phones, tablets, and desktop.
- A curated collection with artwork, artist, and movement pages; normalized
  Arabic search; filters for artist, movement, and period; sorting; and
  shareable route URLs.
- A featured home experience with a rotating painting selection, an hourly
  painting, curated sections, and the WASHIJ Long Thread motif.
- Artwork pages with zoom, image download and sharing, designed share-card
  export, source links, and artwork-specific credits.
- A separate **قراءات الفن** feed with short, attributed excerpts from Arabic art
  publications.
- Optional daily painting notifications on native mobile builds and an Android
  home-screen painting widget that refreshes hourly, with a manual refresh
  control.
- An installable web PWA with an offline app shell and cached same-origin assets.

## The collection and its sources

WASHIJ combines bundled editorial content with public museum and knowledge-base
data. Online sources add records and refresh selected facts; the core collection
does not require a WASHIJ account or a WASHIJ backend.

| Collection | Contents | Source and availability |
|---|---|---|
| Curated WASHIJ collection | 14 artworks, 12 artists, 9 movements, and 4 period groups, with Arabic editorial copy and relationships | Bundled in `app/assets/data/`; available offline after the app assets are cached |
| Arabic museum collection | 400 translated artwork records: 249 from the Cleveland Museum of Art and 151 from the Art Institute of Chicago | Bundled in `app/assets/data/museum_paintings_ar.json`; 399 optimized WebP images are included locally |
| Online paintings | Additional paintings with an image and CC0 sharing status | Fetched on demand from the [Cleveland Museum of Art Open Access API](https://openaccess-api.clevelandart.org/) |
| Artwork facts and credits | Selected labels, dates, materials, collection/place facts, and Commons credit metadata | Refreshed from [Wikidata](https://www.wikidata.org/wiki/Wikidata:Data_access) and [Wikimedia Commons](https://commons.wikimedia.org/wiki/Commons:API) and cached locally for seven days |
| Art readings | Filtered RSS/Atom entries and short source excerpts | [نشرة شَمْس](https://shamsb52.substack.com/feed) and [صباح فنون](https://sabahfenoon.blogspot.com/feeds/posts/default?alt=rss&max-results=12); up to 30 excerpts are cached locally |

The Art Institute of Chicago records are bundled data; the app’s live
supplemental painting search currently uses the Cleveland Open Access API. See
the [Art Institute API documentation](https://api.artic.edu/docs/) for its
public API and data details.

Museum records retain source and licensing information where available. Image
rights vary by work, so use the credit and rights links shown with each record
before reusing an image. The 400 Arabic translations were machine-assisted and
need review by a native Arabic editor and an art historian before production.
Poem lines are WASHIJ editorial text, not quotations from artists.

### Network and offline behavior

- Bundled works, artists, movements, translations, fonts, and image assets are
  part of the app package. The PWA service worker caches its shell and
  same-origin assets as they are requested; previously loaded material can be
  available offline.
- Wikidata, Commons, Cleveland API results, and RSS feeds need an internet
  connection when they are first fetched. Cached facts and readings can be used
  when a later request is unavailable.
- Browser requests that need CORS use the public `proxy.cors.dev` GET proxy.
  Native mobile builds request the source feeds and museum API directly.
- The app does not include sign-in, user accounts, payments, or a server-side
  translation service. Daily reminder preferences and cached feed/fact data are
  stored on the device.

## Pages and routes

WASHIJ uses real path URLs. The Vercel rewrite configuration serves the Flutter
app for direct visits and browser refreshes on these routes.

| Route | Page |
|---|---|
| `/` | Home and featured paintings |
| `/artworks` | Searchable and filterable collection; query parameters preserve search and filters |
| `/artwork/:id` | Curated artwork detail |
| `/artwork/museum/:id` | Bundled translated museum artwork detail |
| `/artwork/cleveland/:id` | Online Cleveland artwork detail |
| `/artists` and `/artist/:id` | Artist index and profile |
| `/movements` and `/movement/:id` | Art-movement index and detail |
| `/readings` | Arabic art-reading feed |
| `/about` | Developer profile and links |

## Design and app architecture

- **Flutter and Dart** power Android and web. The repository also contains an
  iOS project; current published binaries are Android and web.
- **Riverpod** manages catalog, collection filters, search, the home pager,
  hourly painting, and reminder preferences.
- **go_router** handles page routes and browser URLs.
- The visual system is dark-only, Arabic-first, and right-to-left. Bundled fonts
  and `CustomPaint` brand geometry keep the interface usable offline without
  runtime font downloads.
- Artwork color is preserved. Detail pages show the full painting; the home
  hero is the cropped presentation and links to the full work.

Key directories:

```text
app/lib/data/       Models, bundled catalog, museum APIs, RSS, cache, exports
app/lib/state/      Riverpod state and controllers
app/lib/pages/      Route-level screens
app/lib/widgets/    Shared UI, artwork actions, and home sections
app/lib/paint/      WASHIJ symbol, wordmark, and Long Thread drawing
app/assets/data/    Curated catalog and translated museum records
app/assets/images/  Bundled optimized painting images
app/assets/fonts/   Local fonts used by web and native builds
app/web/            PWA shell, bootstrap, service worker, and Vercel rewrites
prototype/          Earlier standalone web prototype
design-system/      Brand tokens, guidance, and component references
```

The earlier prototype is kept for design reference. Its original published
copies are [the web prototype](https://claude.ai/artifact/MQdFiBJhXB3STsQozethz9)
and [the design system](https://claude.ai/artifact/2siAkqCYvWpV8Evw2Qw8k2).

## Run locally

Install a Flutter SDK compatible with the Dart constraint in `app/pubspec.yaml`.
If Flutter is installed at `~/sdks/flutter`, add it to `PATH` first:

More app-specific source and data notes are in [`app/README.md`](app/README.md);
PWA hosting details are in [`app/web/README.md`](app/web/README.md).

```sh
export PATH="$HOME/sdks/flutter/bin:$PATH"
cd app
flutter pub get
flutter run -d chrome
```

To run on an attached Android device, use `flutter devices` to find its device
ID, then replace `DEVICE_ID` in this command:

```sh
flutter run -d DEVICE_ID
```

## Build

Run these from `app/`:

```sh
# Static analysis and tests
flutter analyze
flutter test

# Installable web app
flutter build web --release

# Android release APKs, one per ABI
flutter build apk --release --split-per-abi
```

The split APKs are written to `app/build/app/outputs/flutter-apk/`:

- `app-arm64-v8a-release.apk` — most current Android phones and tablets.
- `app-armeabi-v7a-release.apk` — 32-bit ARM Android devices.
- `app-x86_64-release.apk` — x86-64 Android devices and some emulators.

Install the APK matching the device architecture. Android builds use package ID
`com.washij.washij`.

### Android signing

The current Gradle release build uses the generated Android **debug signing
key**. These APKs are useful for testing and direct installation, but they are
not suitable for publishing through Google Play. Configure a private release or
upload keystore before producing a store-ready build; never commit keystore
files or passwords.

## Web PWA and Vercel

The web build is generated in `app/build/web`. Its manifest and service worker
are configured in `app/web/`; the worker precaches the app shell, caches
same-origin assets as they are requested, and supports offline route loads.
Vercel rewrites route requests to `index.html` while leaving real assets
available at their own URLs.

Build and deploy with the Vercel CLI:

```sh
cd app
flutter build web --release
vercel deploy --prod --cwd build/web --project washij
```

The current production site is [washij.vercel.app](https://washij.vercel.app).

## Download Android builds

The latest published version and its notes are on the
[GitHub Releases page](https://github.com/0omarahmed73/WASHIJ/releases/latest).
Direct downloads for the current split assets:

- [Android arm64 APK](https://github.com/0omarahmed73/WASHIJ/releases/latest/download/app-arm64-v8a-release.apk)
- [Android armeabi-v7a APK](https://github.com/0omarahmed73/WASHIJ/releases/latest/download/app-armeabi-v7a-release.apk)
- [Android x86_64 APK](https://github.com/0omarahmed73/WASHIJ/releases/latest/download/app-x86_64-release.apk)

Choose one APK for your device; split APKs are not installed together.

## Credits and editorial notes

WASHIJ links to its museum and source records and shows available image credits
in artwork details. The [Cleveland Open Access API](https://openaccess-api.clevelandart.org/),
[Art Institute of Chicago API](https://api.artic.edu/docs/), [Wikidata](https://www.wikidata.org/wiki/Wikidata:Data_access),
and [Wikimedia Commons](https://commons.wikimedia.org/wiki/Commons:API) are
independent sources with their own terms and licensing. Please check the rights
information for each work before reuse.

The Arabic museum descriptions and translations are editorial drafts and need
specialist review before production. Any short poem or reflective line is
written for WASHIJ and must not be attributed to the artist.
