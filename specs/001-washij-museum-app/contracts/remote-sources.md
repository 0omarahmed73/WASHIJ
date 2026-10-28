# Remote Sources Contract

The repository fetches only read-only, keyless public endpoints. Curated artwork calls use a bounded timeout (6 s); supplemental museum and reading-feed calls use their own bounded timeouts. Failures must leave the bundled curated collection usable.

| Source | Request | Used for |
|---|---|---|
| Bundled translated museum sample | `app/assets/data/museum_paintings_ar.json` plus `app/assets/images/museum_paintings/` (derived from `tools/out/paintings/translated_400_ar.json`) | 400 Arabic translation drafts from CMA and AIC; 399 optimized WebP images bundled offline |
| Wikidata | `https://www.wikidata.org/w/api.php?action=wbgetentities&ids=<QID>&props=labels|claims|sitelinks&languages=ar|en&sitefilter=arwiki|enwiki&format=json&origin=*` | Arabic labels, dates, medium, dimensions, collection, place, verified article sitelink |
| Wikimedia Commons | `https://commons.wikimedia.org/w/api.php?action=query&titles=File:<name>&prop=imageinfo&iiprop=extmetadata|url&format=json&origin=*` | remote image URL, author, licence, file page URL |
| Cleveland Museum of Art Open Access API | `https://openaccess-api.clevelandart.org/api/artworks/?type=Painting&cc0&has_image=1&skip=<offset>&limit=<limit>&fields=id,accession_number,type,share_license_status,title,creation_date,creators,technique,measurements,creditline,tombstone,url,images`; app-bar search adds `q=<search term>` | Supplemental paintings and full-text search across the Cleveland collection; only records with Painting type, CC0 status, and a web image are eligible |
| Wikidata (Cleveland match) | SPARQL query using `wdt:P11110` and the museum accession number | Optional Arabic title for a matching Cleveland record; the museum title remains when no unique Arabic label exists |
| Selected Arabic art RSS feeds | `https://shamsb52.substack.com/feed`; `https://sabahfenoon.blogspot.com/feeds/posts/default?alt=rss&max-results=12` | Reading title, short excerpt, publication, author, date and original article link |

## Merge rules
1. Editorial fields (poem, intro, story, reading, details, interpretations, related) always come from the bundled file.
2. Fact fields (dateText, medium, dims, collection, place) use the fetched value only when it is non-empty; otherwise the bundled value.
3. Credit uses fetched author, licence and file page when present; the verified article link and attribution text are always present from the bundled fallback.
4. Commons image URL is used when available; the bundled JPEG is the offline or load-failure fallback. Works with held rights have neither image URL nor bundled image.
5. Fetched values are cached by Q-ID for 7 days; stale cache is used while offline.
6. Wikipedia prose is not copied; the artwork page links to the verified article and identifies its CC BY-SA terms.
7. Supplemental Cleveland records remain separate from the curated catalogue and are displayed only when type, CC0 status and image fields pass validation. The museum accession number, not its internal numeric record id, is used to match Wikidata property P11110.
8. On web, the two allowlisted RSS feeds may be fetched through `https://proxy.cors.dev/` to satisfy browser CORS. Only public GET requests are sent; native platforms request the feed URLs directly.
9. Reading cards retain at most the configured excerpt length and link to the article on its source site. Article text beyond that excerpt is not imported into WASHIJ.
10. The bundled 400-record translation sample keeps each museum's record URL, credit line, source and licence. Its Claude-assisted Arabic translations remain labelled as drafts until reviewed by a native editor and an art historian. AIC descriptions carry CC BY 4.0 attribution; CMA records are CC0.

## Mapping data lives in
`assets/data/works.json` holds each curated work's `qid`, Commons file name and verified Wikipedia article URL. Image metadata is taken from `prototype/index.html` (`IMGS`); the prototype's referenced `wp.json` and `imgmeta.json` are not present. Q-IDs and Commons files were checked against the public APIs during implementation. Translated museum images are downloaded and optimized by `tools/paintings/build_local_images.py`; live CMA records and readings are fetched at runtime.
