# WASHIJ web hosting

Build the installable web app with `flutter build web --release`. The custom
`flutter_bootstrap.js` registers `washij_service_worker.js`, waits for it to
control the app, and then starts Flutter. The worker precaches the app shell,
caches same-origin assets as they are requested, and serves `index.html` for
offline route loads. This includes the bundled fonts, JSON catalogue, and
fallback paintings as visitors use them. Flutter's generated cleanup worker is
not registered.

The five WASHIJ typefaces, CanvasKit's Roboto default, and a tiny renamed Noto
CJK subset for the catalog's Japanese names are bundled locally. The Flutter
loader points its fallback-font base at this origin, and the worker refreshes
the bootstrap and release entrypoints from the network with a cached offline
fallback so a new release can replace the old shell.

The service worker cache version comes from Flutter's build token. A new release
uses a fresh cache and removes the previous WASHIJ cache after activation.

WASHIJ uses path URLs such as `/artwork/starry-night`. Configure the host to
serve `index.html` for unknown application paths while continuing to serve
existing files directly. For Nginx, the application location can use
`try_files $uri $uri/ /index.html;`. Configure the equivalent history fallback
on other static hosts. `vercel.json` provides the route rewrites and service
worker headers for Vercel deployments.
