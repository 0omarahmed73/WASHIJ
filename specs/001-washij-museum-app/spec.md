# Feature Specification: WASHIJ Digital Art Museum

**Feature Branch**: `001-washij-museum-app`

**Created**: 2026-10-28

**Status**: Draft

**Input**: User description: "Build WASHIJ (وَشيج), an Arabic-first digital art museum as an installable web app, porting the existing web prototype: home, collection with search and filters, artwork detail, artists, movements, navigation, hybrid data (bundled editorial text plus fetched facts, images and credits), real URLs, offline support, responsive at 390, 820 and 1280 px."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse and search the collection (Priority: P1)

A visitor opens the collection, finds paintings by typing an Arabic or Latin title or artist name, narrows them by movement, artist or period, sorts them, and loads more works.

**Why this priority**: Finding a painting is the core museum action and works on its own with the 14-work data set.

**Independent Test**: Open the collection URL, search, filter, sort and load more; no other page is needed.

**Acceptance Scenarios**:

1. **Given** the collection shows its first 6 works, **When** the visitor activates "load more", **Then** 6 more appear, until all 14 are shown.
2. **Given** the visitor types "ليلة" or "starry" or a name with diacritics or alternate alef/ya/ta marbuta spellings, **When** results update, **Then** matching works appear regardless of those spelling variants.
3. **Given** a movement, artist or period filter is chosen, **When** results update, **Then** only matching works show, with a removable chip for each active filter and a reset control.
4. **Given** no work matches, **When** results update, **Then** a clear no-results message with a reset action appears.
5. **Given** the visitor chooses sort by date or by title, **When** results update, **Then** the order changes accordingly.

---

### User Story 2 - View a painting in depth (Priority: P1)

A visitor opens an artwork and sees the whole painting uncropped on a mat, can zoom it, and reads its story, artistic reading, details worth noticing, attributed interpretations, sources and credits, and related works with the reason for each connection.

**Why this priority**: The artwork page is the museum's main content.

**Independent Test**: Open `/artwork/<id>` directly by URL and verify every section and the credit line.

**Acceptance Scenarios**:

1. **Given** an artwork page, **When** it loads, **Then** the whole painting shows in its original colours with titles, one poem line, an artist chip and facts (date, medium, size, place, collection).
2. **Given** the painting, **When** the visitor opens the zoom view, **Then** a full-screen view appears that can be closed with the keyboard or a control.
3. **Given** an interpretation, **When** it is displayed, **Then** its attribution is shown with it.
4. **Given** any artwork, **When** the page loads, **Then** a credit line with links to the file page and article is present.
5. **Given** a work with no image (The Persistence of Memory), **When** its page loads, **Then** a respectful placeholder explains the image is withheld, and no image is shown.
6. **Given** a wide screen, **When** scrolling, **Then** a sub-navigation stays visible and the Long Thread appears only in the side margin.

---

### User Story 3 - Explore through the home page (Priority: P2)

A visitor lands on the home page and is guided through three featured works, a tagline, a manifesto, curated and discoverable works, featured artists, movements, and connections between paintings.

**Why this priority**: It is the first impression and the main route into the other pages.

**Independent Test**: Open `/`, page through the hero, and follow links to the collection, an artwork, an artist and a movement.

**Acceptance Scenarios**:

1. **Given** the home page, **When** the visitor uses the 01/02/03 pager, **Then** the hero changes between Starry Night, The Great Wave and The Night Watch.
2. **Given** the hero shows a cropped detail, **When** displayed, **Then** it is labelled as a crop and links to the full work.
3. **Given** the call to action "استكشف اللوحات", **When** activated, **Then** the collection opens.

---

### User Story 4 - Explore artists and movements (Priority: P2)

A visitor browses all artists and movements, opens a profile or movement page, and sees related works.

**Why this priority**: Artists and movements connect paintings into the museum's "threads".

**Independent Test**: Open `/artists`, `/artist/<id>`, `/movements` and `/movement/<id>` directly.

**Acceptance Scenarios**:

1. **Given** the artists index, **When** an artist is chosen, **Then** the profile lists their works in the collection.
2. **Given** a movement page, **When** displayed, **Then** it shows period, place, introduction, traits, its artists and its works.

---

### User Story 5 - Navigate and use the app offline (Priority: P3)

A visitor moves between pages with the header, search overlay, mobile menu and back navigation, installs the app, and keeps reading when offline.

**Why this priority**: It makes the museum usable everywhere but depends on the content pages.

**Independent Test**: Visit pages, go offline, reload, and confirm previously seen pages still open.

**Acceptance Scenarios**:

1. **Given** a phone-width screen, **When** the menu is opened, **Then** a drawer shows the five destinations.
2. **Given** the visitor goes offline and reloads, **When** a page opens, **Then** bundled pages and cached curated facts remain readable, reading excerpts use their local cache, and online-only sections show a clear unavailable state.
3. **Given** a direct URL or browser back/forward, **When** used, **Then** the correct page appears.

---

### User Story 6 - Discover open-access paintings online (Priority: P2)

A visitor browses source-linked paintings from a 400-record translated museum sample and additional live Cleveland Museum of Art records.

**Independent Test**: Open `/artworks` offline and online, load translated sample paintings, and follow one to its museum record.

**Acceptance Scenarios**:

1. **Given** the visitor is online or offline, **When** the collection loads, **Then** the bundled 400-record translated sample remains browseable with images loaded from the original museums when available.
2. **Given** a sample painting, **When** its detail page opens, **Then** its Arabic draft, original title, source metadata, applicable licence attribution, and museum record link appear.
3. **Given** an internet connection, **When** the collection loads, **Then** eligible CC0 paintings from the live Cleveland API appear separately from the bundled sample.
4. **Given** a live museum service is unavailable, **When** the collection loads, **Then** the bundled WASHIJ and translated museum works remain browseable and the live section reports that it could not refresh.

---

### User Story 7 - Read Arabic art articles (Priority: P3)

A visitor browses short, credited excerpts from selected Arabic art publications and opens the original article at its source.

**Independent Test**: Open `/readings`, inspect an article's source metadata, and follow its original link.

**Acceptance Scenarios**:

1. **Given** an internet connection, **When** the readings page loads, **Then** matching Arabic art articles show their title, source, author, date when available, short excerpt, and original link.
2. **Given** an article excerpt, **When** it is shown, **Then** the source publication is identified and the full article remains on its original site.
3. **Given** the feeds are unavailable, **When** the page opens, **Then** cached reading metadata and excerpts are used when available.

---

### User Story 8 - See a new painting every hour (Priority: P3)

A visitor sees one painting from the translated museum sample that changes every hour, can ask for another, and can open it from the phone's home screen without first finding it in the app. Two surfaces show it: a section on the app's home page, and an Android home-screen widget.

**Why this priority**: It brings visitors back and lets the museum live on the phone's home screen. It adds no new data.

**Independent Test**: Add the widget to an Android home screen, tap the refresh button, wait for the next hour, and tap the painting.

**Acceptance Scenarios**:

1. **Given** the home page or the home-screen widget, **When** it is shown, **Then** it displays the whole painting uncropped and unfiltered with its Arabic title and artist, chosen only from paintings that have a local image.
2. **Given** an hour boundary passes, **When** the surface next updates, **Then** it shows a different painting for the new hour; within one hour every visitor sees the same painting until they refresh.
3. **Given** the refresh button is pressed, **When** the surface updates, **Then** a different painting than the one just shown appears for the rest of that hour.
4. **Given** the painting is tapped, **When** the app opens, **Then** that painting's detail page (`/artwork/museum/<id>`) is shown inside the app.
5. **Given** the device is offline, **When** the widget updates, **Then** it still works because the paintings and their images are bundled with the app.

---

### User Story 9 - Zoom, download and share a painting (Priority: P2)

A visitor opens any painting (the 14 curated works, the translated museum paintings, or a live online museum painting), zooms into it, saves the image or a shareable card to the device, and shares either with other apps.

**Why this priority**: Visitors want to look closely at a painting and take it with them; the museum's open-access images make this possible.

**Independent Test**: Open `/artwork/museum/<id>` and `/artwork/cleveland/<id>`; use zoom, download and share for the image and the card.

**Acceptance Scenarios**:

1. **Given** a translated or online painting page, **When** the visitor taps the painting or "تكبير الصورة", **Then** the same framed zoom container the 14 curated works use opens (square dialog, mat with corner marks, sized to the painting) showing the whole painting with pinch and wheel zoom up to 4 times, closable with a button or Escape.
2. **Given** the painting page, **When** the visitor chooses "تنزيل الصورة", **Then** the original image (or the bundled copy when offline) is saved to the device's public Downloads folder (`Download/WASHIJ` on Android) where the Files and Gallery apps can see it, with a safe file name, unchanged in colour.
3. **Given** the painting page, **When** the visitor chooses "مشاركة الصورة", **Then** the system share sheet opens with the image attached, or on web the browser downloads it.
4. **Given** the painting page, **When** the visitor chooses "تنزيل البطاقة" or "مشاركة البطاقة", **Then** a 1080 × 1350 PNG card with the whole painting, Arabic and original titles, artist, date, museum credit line and licence is saved or shared.
5. **Given** a failed download or offline source with no bundled copy, **When** the visitor tries, **Then** a clear Arabic message appears and the page stays usable.

---

### Edge Cases

- The facts or image service is slow, unreachable or returns incomplete data: bundled facts show and the page stays usable.
- An unknown artwork, artist or movement URL: a clear not-found page links to the collection.
- Reduced-motion preference: hero transitions and thread effects become static.
- Very long Arabic titles at 390 px: no horizontal page scroll.
- Search with only diacritics or only whitespace: treated as empty search.
- An image fails to load: the page shows its title and credit without a broken image.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST present 14 works, 12 artists, 9 movements and 4 period buckets (before 1600, 17th century, 18th and 19th centuries, 20th century).
- **FR-001a**: The 14 bundled WASHIJ works MUST remain available offline; online museum paintings MUST appear as a separate supplemental collection.
- **FR-002**: Every page MUST have its own real URL (`/`, `/artworks`, `/artwork/:id`, `/artwork/cleveland/:id`, `/artists`, `/artist/:id`, `/movements`, `/movement/:id`, `/readings`) that opens correctly when entered directly.
- **FR-003**: The interface MUST be right-to-left and Arabic-first, with a single dark theme.
- **FR-004**: The app MUST contain no prices, carts, bidding or purchase language.
- **FR-005**: Paintings MUST be shown in original colours with no tint or filter; artwork pages MUST show the whole painting uncropped; only the home hero MAY crop and MUST label it and link to the full work.
- **FR-006**: Search MUST match titles and artist names in Arabic and Latin, ignoring diacritics and treating alef, ya and ta marbuta variants as equal.
- **FR-007**: The collection MUST support filters by movement, artist and period, sort by date or title, active-filter chips, reset, load-more in steps of 6, and a no-results state.
- **FR-008**: Each artwork MUST show Arabic and original titles, an editorial poem line, artist, date, medium, size, place, collection, story, reading, details, attributed interpretations, sources and credits, and related works each with a reason.
- **FR-009**: Poem lines and readings MUST be labelled as WASHIJ's own, and each interpretation MUST show its attribution.
- **FR-010**: Every artwork page MUST show a credit line linking to the image file page and the article; text derived from Wikipedia MUST show CC BY-SA attribution.
- **FR-011**: The Persistence of Memory MUST show no image.
- **FR-012**: Editorial text for the curated collection MUST be bundled; its facts, images and credits MUST be fetched from public sources, cached for reuse, and fall back to bundled facts when unavailable.
- **FR-012a**: Supplemental museum works MAY come from the bundled translated sample or live public sources. Live Cleveland records MUST be validated as paintings with CC0 status and an image before display. Every supplemental detail page MUST show source-provided facts and credits without inventing WASHIJ editorial text.
- **FR-012c**: AI-assisted Arabic translations MUST be labelled as unreviewed drafts until a native Arabic editor and art historian approve them. AIC descriptions MUST retain CC BY 4.0 attribution; CMA records MUST retain CC0 and museum attribution.
- **FR-012b**: The readings page MUST show only short excerpts from selected Arabic RSS feeds, identify each publication, link to the original article, and cache excerpts for offline reading. It MUST NOT present source articles as WASHIJ-authored content.
- **FR-013**: The home page MUST include a hero with a 3-item pager, tagline, poem line, call to action, manifesto, Long Thread frames strip, curated collection, Great Wave spotlight, discovery rail, featured artists, movements list, threads between paintings, entry tiles and a footer with credits.
- **FR-014**: The app MUST offer a header with logo and five destinations, a search overlay, a mobile drawer and back navigation.
- **FR-015**: The Long Thread MUST stay in margins and never cross faces or key details; focus indicators MUST be a visible 2px yellow ring.
- **FR-016**: The app MUST respect reduced-motion preferences and keep motion minimal.
- **FR-017**: Layouts MUST work at 390, 820 and 1280 px widths with no horizontal page scroll.
- **FR-018**: The app MUST be installable and MUST keep previously visited pages readable offline.
- **FR-019**: All fonts MUST be bundled and available offline.
- **FR-020**: The app MUST need no sign-in, payment or custom server.
- **FR-021**: The app MUST show one painting per hour on its home page, chosen only from translated museum paintings that have a local image, with a control to show another painting and a tap target that opens the painting's detail page.
- **FR-022**: On Android, the app MUST provide a resizable home-screen widget that shows the hourly painting whole (never cropped, tinted or filtered) with its Arabic title and artist, a refresh button, and a tap that opens the painting's detail page in the app. It MUST work offline from bundled data and images and MUST NOT use a backend.
- **FR-023**: The hourly choice MUST be stable within an hour, MUST change at the next hour, and a manual refresh MUST NOT repeat the painting just shown.
- **FR-024**: Every painting page (the 14 curated works, the translated museum paintings and the live online museum paintings) MUST open in one shared framed zoom container (the one the curated works use) that shows the whole painting uncropped and unfiltered, with pinch and wheel zoom and a visible close control.
- **FR-025**: Each painting page MUST let the visitor download and share the painting image without altering its colours, using the original image when online and the bundled image when offline.
- **FR-026**: Each painting page MUST let the visitor download and share a generated 1080 × 1350 PNG card showing the whole painting, its Arabic and original titles, artist, date, museum credit line, and source and licence.
- **FR-027**: Download and share controls MUST be outlined controls (no yellow primary), have visible focus, and report failures in Arabic without breaking the page.

### Key Entities *(include if feature involves data)*

- **Artwork**: Arabic and original title, artist, year and date text, medium, size, collection, movement, intro, story, reading, details, interpretations, related works with reasons, poem line, image availability and credit.
- **Artist**: name, life dates, movements, biography, works.
- **Movement**: name, original name, period, place, introduction, traits, artists, works.
- **Period bucket**: label and date range used for filtering.
- **Interpretation**: text with its attribution.
- **Credit**: image author, licence, file page and article links.
- **Supplemental museum artwork**: museum record id and accession number, original title, optional Arabic Wikidata label, artist, date, medium, dimensions, CC0 image URL, credit line and museum record URL.
- **Art reading**: title, short excerpt, publication, author, optional publication date and original article URL.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time visitor finds a named painting from the collection in under 30 seconds in 9 of 10 trials.
- **SC-002**: 100% of the 14 works open from their direct URL and, except The Persistence of Memory, show a credit line and a whole uncropped painting.
- **SC-003**: Arabic searches with and without diacritics or alef/ya/ta marbuta variants return the same results for all 14 works.
- **SC-004**: The first meaningful content of any page is visible within 3 seconds on a typical mobile connection.
- **SC-005**: With the network off, bundled routes remain readable, cached curated facts and reading excerpts remain available, and online-only records show a clear unavailable state.
- **SC-006**: No horizontal page scroll and no overlapping text at 390, 820 and 1280 px on all seven page types.
- **SC-007**: A review finds zero price, cart, bidding or purchase wording and zero tinted or filtered paintings.
- **SC-008**: Online supplemental works are displayed only when the museum record identifies a painting, marks it CC0, and supplies an image; each detail links to its museum record.
- **SC-009**: Every reading card identifies its publication and links to the original article; only a short excerpt is retained locally.
- **SC-010**: All 400 translated museum records are available from the bundled data offline, and each detail page identifies its source, licence, and draft translation status.
- **SC-011**: The home-screen widget shows a different painting after each hour boundary or refresh press, and tapping it opens the matching detail page, on a real Android device or emulator.
- **SC-012**: On a real device, a visitor can zoom a translated painting and a live Cleveland painting, save the image and the card, and share both, and the saved image is byte-identical to the source image.

## Assumptions

- Visitors are primarily Arabic readers on phones and desktops with a modern browser.
- The 14-work prototype collection remains the curated offline base; additional paintings come from live public museum data.
- Arabic art readings are a separate feed and do not become the museum's artwork records.
- The editorial Arabic copy is a draft until reviewed by a native editor and an art historian.
- Native mobile app stores are out of scope; the installable web app is the deliverable. The Android home-screen widget ships inside the Android build of the same app; an iOS widget needs Xcode and a Mac and is out of scope for now.
- Images come from public-domain files credited on Wikimedia Commons; copying them to the project's own hosting is acceptable.
- The approved visual design in the prototype and design system is final and not redesigned here.
