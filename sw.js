/* PAC Media service worker - offline app shell */
const CACHE = 'pac-media-v2';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './assets/pac-logo.png',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-maskable-512.png',
  './icons/apple-touch-icon.png'
];

self.addEventListener('install', (e) => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS).catch(() => {})));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((ks) => Promise.all(ks.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET') return;
  // Always fresh: config, database calls, the JS library
  if (url.pathname.endsWith('/config.js')) return;
  if (url.hostname.endsWith('.supabase.co') || url.hostname === 'cdn.jsdelivr.net') return;
  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request)
        .then((r) => { const cp = r.clone(); caches.open(CACHE).then((c) => c.put('./index.html', cp)); return r; })
        .catch(() => caches.match('./index.html'))
    );
    return;
  }
  e.respondWith(
    caches.match(e.request).then((m) => m || fetch(e.request).then((r) => {
      if (r.ok && url.origin === location.origin) {
        const cp = r.clone();
        caches.open(CACHE).then((c) => c.put(e.request, cp));
      }
      return r;
    }).catch(() => caches.match('./index.html')))
  );
});
