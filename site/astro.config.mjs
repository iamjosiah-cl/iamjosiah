// @ts-check
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://www.iamjosiah.cl',
  // URLs limpias tipo /portafolio/ servidas como carpetas con index.html
  trailingSlash: 'ignore',
  build: { format: 'directory' },
  // Precarga las páginas enlazadas al pasar el mouse: la navegación se siente instantánea.
  prefetch: { prefetchAll: true, defaultStrategy: 'hover' },
});
