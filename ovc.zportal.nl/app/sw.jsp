


// xxxxxxxxxxxxxxxxxxx
const PRECACHE = 'precache-24.07j27';
const RUNTIME = 'runtime-24.07j27';





// A list of local resources we always want to be cached.
const PRECACHE_URLS = [
'/app/',
'/app/v/24.07j27/manifest.json',
'/app/v/24.07j27/img/logo_kleur.png','/app/v/24.07j27/img/menu_unread.svg','/app/v/24.07j27/img/ic_koppel_extern_default.svg','/app/v/24.07j27/img/announcements_unread_hover.svg','/app/v/24.07j27/img/preloader.json','/app/v/24.07j27/img/crown.svg','/app/v/24.07j27/img/logo_wit.png','/app/v/24.07j27/img/ic_koppel_extern_hover.svg','/app/v/24.07j27/img/es_geenresultaten.png','/app/v/24.07j27/img/logo_ios.png','/app/v/24.07j27/img/ic_zoek_opties_inactive.svg','/app/v/24.07j27/img/clipboard-removed_24dp.svg','/app/v/24.07j27/img/zermelo_loader.gif','/app/v/24.07j27/img/loadingcat.gif','/app/v/24.07j27/img/subjectSelection_unread.svg','/app/v/24.07j27/img/trophy.svg','/app/v/24.07j27/img/logo_zwart.svg','/app/v/24.07j27/img/logo_wit.svg','/app/v/24.07j27/img/ic_zoek_opties_active.svg','/app/v/24.07j27/img/subjectSelection_unread_hover.svg','/app/v/24.07j27/img/lln_school.svg','/app/v/24.07j27/img/announcements_unread_default.svg','/app/v/24.07j27/img/ic_comment_unread_default.svg','/app/v/24.07j27/img/logo_kleur.svg',
'/app/v/24.07j27/css/app.css',
'/app/v/24.07j27/fonts/roboto-regular.woff','/app/v/24.07j27/fonts/roboto-regular.woff2','/app/v/24.07j27/fonts/roboto-medium.woff2','/app/v/24.07j27/fonts/roboto-light.woff2','/app/v/24.07j27/fonts/MaterialIcons-Regular.ttf','/app/v/24.07j27/fonts/roboto-medium.woff','/app/v/24.07j27/fonts/MaterialIcons-Regular.woff2','/app/v/24.07j27/fonts/MaterialIcons-Regular.eot','/app/v/24.07j27/fonts/MaterialIcons-Regular.woff','/app/v/24.07j27/fonts/roboto-light.woff',
'/app/v/24.07j27/nl.zermelo.online.App/clear.cache.gif','/app/v/24.07j27/nl.zermelo.online.App/nl.zermelo.online.App.devmode.js','/app/v/24.07j27/nl.zermelo.online.App/compilation-mappings.txt','/app/v/24.07j27/nl.zermelo.online.App/nl.zermelo.online.App.nocache.js','/app/v/24.07j27/nl.zermelo.online.App/C672072EBF113B22AB08076B5119BBBD.cache.js','/app/v/24.07j27/nl.zermelo.online.App/14DE2B6CD4C5DB9C6A334BEF75CE432D.cache.js',
];

// The install handler takes care of precaching the resources we always need.
self.addEventListener('install', event => {
  console.log("[Service Worker] Installing service worker.");
  event.waitUntil(
    caches.open(PRECACHE)
      .then(cache => cache.addAll(PRECACHE_URLS))
	  .catch(error => {
		console.log("[Service Worker] Error while adding files to cache: " + error);
	  })
  );
});

// The activate handler takes care of cleaning up old caches.
self.addEventListener('activate', event => {
});

// The fetch handler serves responses for same-origin resources from a cache.
// If no response is found, it populates the runtime cache with the response
// from the network before returning it to the page.
self.addEventListener('fetch', event => {
  // Skip cross-origin requests, like those for Google Analytics.
  if (event.request.url.startsWith(self.location.origin)
    && !event.request.url.includes("/api/")
    && !event.request.url.includes("reset")
    && !event.request.url.includes("nocache")
    ) {
    event.respondWith(
      caches.match(event.request).then(cachedResponse => {
        if (cachedResponse) {
          return cachedResponse;
        }

        return caches.open(RUNTIME).then(cache => {
          return fetch(event.request).then(response => {
            // Put a copy of the response in the runtime cache.
            cache.put(event.request, response.clone());
            return response;
          }).catch(error => { console.log("[Service Worker]  Error fetching: " + error);});
        });
      })
      .catch(error => { console.log("[Service Worker]  Error in caches.match: " + error);})
    );
  }
});

self.addEventListener('push', function(event) {
    console.log('[Service Worker] Push Received.');
    console.log(`[Service Worker] Push had this data: ""`);
  
    const title = 'Zermelo';
    const options = {
      body: event.data.text(),
      icon: 'images/icon.png',
      badge: 'images/badge.png'
    };
  
    event.waitUntil(self.registration.showNotification(title, options));
  });

  self.addEventListener('notificationclick', function(event) {
    console.log('[Service Worker] Notification click Received.');
  
    event.notification.close();
  
    event.waitUntil(
      clients.openWindow('/app')
    );
  });
  
  self.addEventListener('message', function(event) {
	  if (event.data == "clearCache") {
		console.log("[Service Worker] Clearing Service Worker caches");
		caches.keys().then(function(names) {
		    for (var name in names) {
		    	console.log("[Service Worker] Clearing cache " + names[name]);
		        caches.delete(names[name]);
		    }
		});
	  }
	  if (event.data == "skipWaiting") {
	    console.log('[Service Worker] skipWaiting');
		self.skipWaiting();
	  }
      if (event.data == "claim") {
        console.log('[Service Worker] claim');
        clients.claim();
      }
      if (event.data == "cleanup") {
		  const currentCaches = [PRECACHE, RUNTIME];
		  console.log("[Service Worker] Cleaning up. New caches: " + currentCaches);
		  event.waitUntil(
		    caches.keys().then(cacheNames => {
		      return cacheNames.filter(cacheName => !currentCaches.includes(cacheName));
		    }).then(cachesToDelete => {
		      console.log("[Service Worker] Deleting old caches: " + cachesToDelete);
		      return Promise.all(cachesToDelete.map(cacheToDelete => {
		        console.log("[Service Worker] Deleting cache " + cacheToDelete);
		        return caches.delete(cacheToDelete)
		            .catch(error => {
		            console.log("[Service Worker] Error while deleting cache service worker: " + error);
		    })
		      }));
		    })
		    .catch(error => {
		        console.log("[Service Worker] Error while cleaning up: " + error);
		    })
		  );
       }
  });
  
    self.addEventListener('statechange', function(event) {
    	console.log('[Service Worker] ' + event);
  });
