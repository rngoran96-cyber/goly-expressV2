// Goly Express — Service Worker
// Rôle : rendre le site installable comme une app, et garder l'essentiel
// disponible même avec une connexion faible (fréquent en scooter en pleine course).

const CACHE_NAME = 'goly-express-v1';
const PRECACHE_URLS = [
  'index.html',
  'suivi.html',
  'livreur.html',
  'manifest.json',
  'icon-192.png',
  'icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(PRECACHE_URLS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// Stratégie : réseau d'abord (pour avoir les données fraîches), secours sur le cache si hors-ligne.
// Les appels à l'API Supabase (autre domaine) ne sont jamais mis en cache.
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return; // laisse passer les appels Supabase/Leaflet tels quels

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const clone = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
