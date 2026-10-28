'use strict';

const version = new URL(self.location.href).searchParams.get('v') || 'dev';
const cacheName = `washij-shell-${version}`;
const scopeUrl = self.registration.scope;
const shellFiles = [
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-maskable-512.png',
];
const networkFirstFiles = new Set([
  new URL('flutter_bootstrap.js', scopeUrl).pathname,
  new URL('flutter.js', scopeUrl).pathname,
  new URL('main.dart.js', scopeUrl).pathname,
  new URL('manifest.json', scopeUrl).pathname,
]);

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(cacheName);
      await cache.addAll(shellFiles.map((file) => new URL(file, scopeUrl)));
      await self.skipWaiting();
    })(),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const cacheNames = await caches.keys();
      await Promise.all(
        cacheNames
          .filter((name) => name.startsWith('washij-shell-') && name !== cacheName)
          .map((name) => caches.delete(name)),
      );
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const requestUrl = new URL(request.url);
  if (requestUrl.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
    event.respondWith(
      (async () => {
        try {
          const response = await fetch(request);
          if (response.ok) {
            const cache = await caches.open(cacheName);
            await cache.put(request, response.clone());
          }
          return response;
        } catch (_) {
          return (
            (await caches.match(new URL('index.html', scopeUrl))) ||
            Response.error()
          );
        }
      })(),
    );
    return;
  }

  if (networkFirstFiles.has(requestUrl.pathname)) {
    event.respondWith(
      (async () => {
        const cache = await caches.open(cacheName);
        try {
          const response = await fetch(request);
          if (response.ok && response.type === 'basic') {
            await cache.put(request, response.clone());
          }
          return response;
        } catch (_) {
          return (await cache.match(request)) || Response.error();
        }
      })(),
    );
    return;
  }

  event.respondWith(
    (async () => {
      const cached = await caches.match(request);
      if (cached) return cached;

      const response = await fetch(request);
      if (response.ok && response.type === 'basic') {
        const cache = await caches.open(cacheName);
        await cache.put(request, response.clone());
      }
      return response;
    })(),
  );
});
