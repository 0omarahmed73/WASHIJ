<!--
Sync Impact Report
Version change: (unratified template) → 1.0.0
Modified principles: none renamed; all template placeholders replaced
Added sections: Core Principles I–VIII, Design and Technology Constraints,
  Content and Review Workflow, Governance
Removed sections: none
Follow-up TODOs: none
-->
# WASHIJ Constitution

## Core Principles

### I. Museum, Not Marketplace
WASHIJ is an Arabic-first digital art museum. No screen, string, route or data field MAY
contain prices, carts, bidding, checkout or purchase language. Works are presented to be
understood, never sold.

### II. Paintings Keep Their Original Colours
Paintings MUST NOT be tinted, filtered, overlaid or colour-adjusted. Detail pages MUST show
the whole painting uncropped. The only cropped use is the home hero, which MUST be labelled
as a crop and link to the full work. Works whose rights are held (The Persistence of Memory)
MUST have no image.

### III. Dark-Only Visual Language
There is one dark theme and no light theme. Corners are square, borders are fine hairlines,
and the focus ring is 2px star-yellow. Each screen MUST have at most one primary yellow
button. The Long Thread (a single yellow line) MUST stay in margins and MUST NOT cross faces
or key details. Colours come from the approved tokens in `design-system/project/tokens.json`.

### IV. Arabic-First, RTL by Default
The UI is right-to-left with Arabic as the primary language. Arabic text MUST NOT be
letter-spaced. All fonts (Aref Ruqaa, Scheherazade New, Readex Pro, Cormorant Garamond,
Amiri) MUST be bundled as assets and MUST NOT be fetched at runtime, so the PWA renders
correctly offline.

### V. Accessible and Calm
Reduced-motion preferences MUST be respected and motion kept minimal. Interactive elements
MUST have visible focus, and errors MUST carry a word, not colour alone. Layouts MUST work at
390, 820 and 1280 px widths with no horizontal page scroll.

### VI. Hybrid Data with Honest Credits
Editorial Arabic text is bundled with the app. Facts, images and credits are fetched from
Wikidata, Wikimedia Commons and Wikipedia, cached, and backed by a bundled fallback so the
app works offline. Every artwork page MUST show a credit line, and Wikipedia-derived text
MUST show CC BY-SA attribution with a link to its source. Screens MUST read data through one
typed repository and MUST NOT depend on where a field came from.

### VII. Editorial Integrity
Poem lines, readings and interpretations are WASHIJ's own words and MUST be labelled as
such, never as the artists' words. Each attributed interpretation MUST name its attribution.
Arabic copy MUST be reviewed by a native editor and an art historian before production.
Unverifiable links (such as the removed MoMA link) MUST NOT be published.

### VIII. Simple, Local Stack
The app is Flutter stable, web-first, shipped as a PWA, routed with go_router using real URLs
(`/`, `/artworks`, `/artwork/:id`, `/artists`, `/artist/:id`, `/movements`, `/movement/:id`)
and managed with Riverpod. There is no authentication, payment or custom backend. Adding any
of these requires a constitution amendment.

## Design and Technology Constraints

- Flutter is installed at `~/sdks/flutter` and MUST NOT be upgraded without being asked.
- The logo symbol and the Long Thread MUST be drawn with CustomPaint from the documented
  120-grid geometry, with strokes thickened at small sizes (5 at 32px, 7 at 16px).
- Search MUST normalise Arabic (strip diacritics, unify alef, ya and ta marbuta) and also
  match Latin names.
- The data set is 14 works, 12 artists, 9 movements and 4 period buckets, taken from
  `prototype/src/data.js`.

## Content and Review Workflow

- The web prototype in `prototype/` is the reference for screens and behaviour; the approved
  design MUST NOT be redesigned during the Flutter build.
- Changes MUST be checked at the three widths in Principle V and with Arabic search before
  being called done.
- Content or design changes that touch Principles I–VII MUST be reviewed against this
  document.

## Governance

This constitution supersedes other practices for WASHIJ. Amendments MUST be written into this
file with a rationale and a version bump: MAJOR for removing or redefining a principle, MINOR
for adding a principle or materially expanding guidance, PATCH for wording fixes. Every
feature spec, plan and review MUST verify compliance, and any departure MUST be justified in
writing. Runtime design guidance lives in `design-system/project/guidelines.md`.

**Version**: 1.0.0 | **Ratified**: 2026-10-28 | **Last Amended**: 2026-10-28
