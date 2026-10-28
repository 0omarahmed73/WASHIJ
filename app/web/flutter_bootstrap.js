{{flutter_js}}
{{flutter_build_config}}

const workerVersion = {{flutter_service_worker_version}};

async function startWashij() {
  const base = new URL('.', document.baseURI);
  if ('serviceWorker' in navigator) {
    try {
      const worker = new URL(`washij_service_worker.js?v=${workerVersion}`, base);
      await navigator.serviceWorker.register(worker, { scope: base.pathname });
      await navigator.serviceWorker.ready;

      if (!navigator.serviceWorker.controller) {
        await new Promise((resolve) => {
          const timeout = setTimeout(resolve, 2000);
          navigator.serviceWorker.addEventListener(
            'controllerchange',
            () => {
              clearTimeout(timeout);
              resolve();
            },
            { once: true },
          );
        });
      }
    } catch (error) {
      console.warn('WASHIJ offline support could not start:', error);
    }
  }

  _flutter.loader.load({
    config: {
      canvasKitBaseUrl: 'canvaskit',
      fontFallbackBaseUrl: new URL('font-fallback/', base).href,
    },
  });
}

startWashij();
