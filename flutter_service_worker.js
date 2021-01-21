'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"manifest.json": "9f3c04a3bc24b99465938d3169f49ded",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "d80ca32233940ebadc5ae5372ccd67f9",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "831eb40a2d76095849ba4aecd4340f19",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "a126c025bab9a1b4d8ac5534af76a208",
"assets/NOTICES": "d79ce1cb7618b3a88cecaf184e87547b",
"assets/assets/gift-card.png": "d8498d8a47948fffcdc09dd26be6cbe2",
"assets/assets/walnut%2520planter.png": "d07b571f2c1ef4eac8918ef790e63bb4",
"assets/assets/buy.png": "462a7b19628ec1d0048bdd91facb1c9f",
"assets/assets/email.png": "b9ac0f52730b365ae015dc3c6469388e",
"assets/assets/pos_printer.png": "771c028ed61d4b81a44d6ba651832be3",
"assets/assets/mastercard.png": "39b6b1565a35a70ed1de5f89a10b39e6",
"assets/assets/phone-call.png": "7147ca19cb88338682ba6ede7f2f6f53",
"assets/assets/smartphone.png": "924115c262fa7296fbd133582ba14344",
"assets/assets/chat-store.png": "23d4583e0ee895fc15772a5ae8577138",
"assets/assets/card_swiper.png": "643576846974e4e1d5dc70552f0c1039",
"assets/assets/product/random17.png": "bd4e11d9dc75ccceca935ad4c3d3d152",
"assets/assets/product/random10.png": "ff648566440f42a83986f00b19c02807",
"assets/assets/product/random1.png": "4354d45c404ec48a2c27c99c1950a477",
"assets/assets/product/random15.jpeg": "875a6081f353e8d0c8a163f59a03b22e",
"assets/assets/product/random15.png": "bc17fb282cd6fc04aebdb0e8f11373bd",
"assets/assets/product/random16.png": "0e45f736024e550ad2f190a3dc1d688f",
"assets/assets/product/random3.png": "e92e162bf801af6d4bd4370772b696a0",
"assets/assets/product/random6.png": "8f6912ce0cd3b45ca537246c379a387e",
"assets/assets/product/random12.png": "cae224da520e809f4b50a5130e9d5055",
"assets/assets/product/random7.png": "20e3f7c518bb187810b4a08ad4fd3165",
"assets/assets/product/random5.png": "d967f52316a8a1cf1c9f728517f216d9",
"assets/assets/product/random9.png": "a9cf7f55ede64b4df2390ccd4914fceb",
"assets/assets/product/random4.png": "49b9600514b8094b4c47b61fae401454",
"assets/assets/product/random8.png": "324ef581039f17d97a94a5408f7e6c8f",
"assets/assets/product/random11.png": "2e940013b9b4b7524461e421de8672e0",
"assets/assets/product/random0.png": "6b88ad2a2706247a1a48e158c901906c",
"assets/assets/product/random14.png": "663fd2f931b8baba14eba21fa57b6e8d",
"assets/assets/product/random2.png": "521945a4d850986d0ec93ff3cc471020",
"assets/assets/product/random19.png": "8966efb306a5beef91d20162af5f638c",
"assets/assets/product/random13.png": "5cfbc2f253ceb627e2c76ff457463bb7",
"assets/assets/product/random18.png": "095649db12ec986c907af210de1f89a8",
"assets/assets/chat_support.png": "23d4583e0ee895fc15772a5ae8577138",
"assets/assets/napkin.jpeg": "e916fad13477de308bc8e1deef406564",
"assets/assets/inventory.png": "bbe395c27077a804959b2c1f58f75889",
"assets/assets/product.png": "26297104c91e411590d1eab2072ee802",
"assets/assets/notebooks.jpg": "a1ec5737a183b11afb62ecf4968c6685",
"assets/assets/receipt.png": "8b8af8c06b0468220bdad0fa2a1e4277",
"assets/assets/placeholder.png": "31aab2e2b860315397d621ab0344ee5e",
"assets/assets/bug.png": "7760f718621adeb1601fd9625ed68a68",
"assets/assets/tumbler.jpg": "31fe6ace85678ed7a8d13905c43b71d9",
"assets/assets/card_swiper.jpg": "e70d50c4d00397cd9ed9f8a6fe55993f",
"assets/assets/tools.png": "552e7822c25107623a320ed12b0b4a2f",
"assets/assets/user.png": "02723a8b181c646ad15095dd4786dac1",
"assets/assets/credit-card-store.png": "cd42b19f19e443e53d6a2c95bbeac81b",
"assets/assets/tulip.jpg": "e06ce0d1e8719345ac63090c13ee87db",
"assets/assets/clock.jpg": "e06c9351b0113684638d3a17d0d50ffd",
"assets/assets/support.png": "7f888d2ca2474c447d0bb8b667c3a66a",
"assets/assets/gift-box.png": "5c15c1539c9c566b5413d98f9cf3592f",
"assets/assets/cup.jpeg": "6b54e6b7ef146aedb6b1b674f9ed2102",
"assets/assets/money.png": "7eee5bd8c0a80adca33ffc91c7f9a542",
"assets/assets/email_support.png": "07a1b1d18351d6d6b788e45d0a68baa5",
"assets/assets/starting.jpg": "8480964db657cd6d1dfd57b777f61986",
"assets/assets/app.png": "faa039ab03046a88bb90cef694efc243",
"assets/assets/chair.jpg": "ff9bb0f426104d5d8e473980076324da",
"assets/assets/star.png": "d88db0fbb5a55055311cfaefc74d9e18",
"assets/assets/products.png": "6020641aeee769a82113cc4dc1192d01",
"assets/assets/settings.png": "92c25f37d91bbc70ba1a197b38c0b57c",
"assets/assets/cloud-computing.png": "42adc35e42538063a3bf70b82a62b925",
"assets/assets/credit-card.png": "7786f1406ec5e0f91b1323c19933e458",
"assets/assets/background.jpg": "f525a95607e4238b60ce1e869ec37a18",
"assets/assets/cup.webp": "5d3d6bcc7c8803758957ae7cf6a001c2",
"assets/assets/chat.png": "517a046d0b45629b11c6f4df828068e4",
"assets/assets/printer.png": "f75d66ec0819a88d8b3217870681d1e7",
"assets/assets/packages.png": "e0623d4f984e41a248f4bfdd1a731a61",
"assets/assets/pos-terminal.png": "9f9f474a703ad2c56643a7226f086773",
"assets/assets/add-group.png": "07e14fc57877625d8ce872cf15eef912",
"assets/assets/button.png": "db5e577bd4f9e6575e099a3c1fce44eb",
"assets/assets/shopping-cart.png": "1500235893cc37d77b588e2631ddf9c2",
"assets/AssetManifest.json": "585451f048870936a03555dd76bd8332",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"index.html": "be1cea0a684c9a4ed5cab13f91fef663",
"/": "be1cea0a684c9a4ed5cab13f91fef663",
"version.json": "b99ea6d07a58391a9f00c81d2e8ad3b2",
"main.dart.js": "12113f691ff4a380dcd342a719e3c61b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
