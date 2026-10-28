# Data Model: WASHIJ

Source of truth for editorial fields: `prototype/src/data.js` (ported to JSON). Fetched fields are optional overlays.

## Artwork
| Field | Type | Source | Notes |
|---|---|---|---|
| id | string | bundled | slug, e.g. `starry-night`; used in `/artwork/:id` |
| qid | string | bundled | Wikidata Q-ID |
| titleAr / titleOrig | string | bundled, fetched overlay | |
| artistId | string | bundled | → Artist |
| movementId | string | bundled | → Movement |
| year | int | bundled | drives period and date sort |
| dateText, medium, dims, collection, place | string | bundled, fetched overlay | fetched wins when present |
| poem | string | bundled | labelled as WASHIJ's own |
| intro | string | bundled | |
| story, reading | list of string | bundled | paragraphs |
| details | list of Detail | bundled | Detail = title, text, crop rect {x,y,w,h in %}; crops only where defined |
| interpretations | list of Interpretation | bundled | text + required attribution |
| related | list of Related | bundled | Related = artworkId + reason |
| image | ImageRef? | Commons URL online; bundled fallback | null for The Persistence of Memory |
| credit | Credit | fetched, bundled fallback | required on every page |

## ImageRef
bundled asset path, width, height (for aspect ratio and mat), and optional Commons image URL.

## Credit
author, licence, fileUrl (Commons file page), articleUrl (verified Wikipedia sitelink), fetchedAt, isFallback.

## Artist
id, nameAr, nameOrig, born, died, place, leadArtworkId, movementIds, bio, style. Works are derived by `artistId`.

## Movement
id, nameAr, nameOrig, period, where, line (poem), intro, traits (list). Works and artists are derived.

## Period
id (`p1`–`p4`), labelAr, test on year: `<1600`, `1600–1699`, `1700–1899`, `>=1900`.

## FilterState (UI)
query, movementId?, artistId?, periodId?, sort (`date-asc` default, `date-desc`, `title`), shown (default 6, step 6).

## Validation rules
- Every Artwork has artist, movement, poem, credit, and at least one story paragraph.
- Every Interpretation has non-empty attribution.
- Every Related target exists; reason is non-empty.
- Artwork without image must not render any image widget.
- No field name or string contains price, cart, bid or purchase vocabulary.
- 14 works, 12 artists, 9 movements, 4 periods.

## State transitions
Search or filter change resets `shown` to 6. Load-more adds 6. Reset clears query and filters but keeps the sort.
