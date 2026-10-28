# WASHIJ

Arabic-first digital art museum built with Flutter. The web build is an
installable PWA; catalog pages also run from the bundled data when offline.

## Run locally

```sh
export PATH="$HOME/sdks/flutter/bin:$PATH"
cd /home/omarahmed/Downloads/WASHIJ/app
flutter pub get
flutter run -d chrome
```

Check and build:

```sh
flutter analyze
flutter test
flutter build web --release
```

Deploy the contents of `build/web` and configure the host to serve `index.html`
for application paths such as `/artwork/starry-night`. See [`web/README.md`](web/README.md)
for the service-worker and hosting details.

## Catalog and sources

The 14 bundled WASHIJ paintings, Arabic editorial copy, dates, and relationships
remain available offline. Wikidata and Wikimedia Commons can refresh facts and
image metadata, cached locally for seven days. The collection can also fetch
additional CC0 paintings with images from the Cleveland Museum of Art Open
Access API. These supplemental records show source facts and museum credit links
without generated editorial copy. Wikidata may supply an Arabic title when it
has a unique label for the matching museum accession number.

The collection also includes 400 bundled Arabic translation drafts from the
Cleveland Museum of Art and the Art Institute of Chicago. Each painting links
to its museum record and shows its licence attribution. The translations were
machine-assisted and still need review by a native Arabic editor and an art
historian before production.
The 399 available museum images are bundled as optimized WebP assets so they
appear quickly and remain available offline; one source record has no image.

The separate `قراءات الفن` page reads short excerpts from the allowlisted Shams
Substack and Sabah Fenoon RSS feeds, caches up to 30 excerpts, and links each
card to its original article. Web requests use the public `cors.dev` GET proxy
to satisfy browser CORS; native builds request the feeds directly. This feed
shows publication material as source content, not WASHIJ editorial text.

## Editorial review

Arabic copy needs review by a native editor and an art historian before
production. Poem lines are WASHIJ editorial text, not quotations from artists.
