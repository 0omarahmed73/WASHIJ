# Route Contract

All routes use path URLs and must open correctly when entered directly. Unknown ids show the not-found page.

| Path | Page | Notes |
|---|---|---|
| `/` | Home | hero pager state is local, not in the URL |
| `/artworks` | Collection | optional query params: `q`, `movement`, `artist`, `period`, `sort` (restored on load) |
| `/artwork/:id` | Artwork detail | id = artwork slug |
| `/artwork/cleveland/:id` | Supplemental Cleveland artwork | id = museum's numeric record id |
| `/artwork/museum/:id` | Bundled translated museum artwork | id = source-prefixed id from the 400-record dataset |
| `/artists` | Artists index | |
| `/artist/:id` | Artist profile | |
| `/movements` | Movements index | |
| `/movement/:id` | Movement page | |
| `/readings` | Arabic art readings | short excerpts and source links |
| `/about` | Developer profile | name, role, and external professional links |
| any other | Not found | link back to `/artworks` |

Back navigation uses the router history, with a fallback to the parent index page when there is none.

## Deep link from the Android home-screen widget

The widget opens `washij:///artwork/museum/<id>` (custom scheme, empty host) explicitly in `MainActivity`; the router uses the path `/artwork/museum/<id>`. No other host or scheme is accepted, and no intent filter is declared for it, so other apps cannot open it.
