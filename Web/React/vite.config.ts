import legacy from '@vitejs/plugin-legacy';
import react from '@vitejs/plugin-react-swc';
import path from 'path';
import { defineConfig } from 'vite';
import svgr from 'vite-plugin-svgr';

import packageJSON from './package.json';

// https://vitejs.dev/config/
export default defineConfig({
  define: {
    __VERSION__: JSON.stringify(packageJSON.version),
  },

  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'), // 将 '@' 映射到 './src' 目录
      call: path.resolve(__dirname, './src/view/Call'),
      chat: path.resolve(__dirname, './src/view/Chat'),
      components: path.resolve(__dirname, './src/view/components'),
      hooks: path.resolve(__dirname, './src/view/hooks'),
    },
  },
  build: {
    rollupOptions: {
      input: {
        index: path.resolve(__dirname, 'index.html'),
        mobile: path.resolve(__dirname, 'mobile.html'),
      },
    },
  },

  plugins: [
    react(),
    svgr({ svgrOptions: { icon: true } }),
    legacy({
      targets: ['firefox 62', 'safari 11', 'chrome 63'], //需要兼容的目标列表，可以设置多个
      additionalLegacyPolyfills: ['regenerator-runtime/runtime'],
      renderLegacyChunks: true,
      modernPolyfills: ['es/global-this'],
    }),
  ],
  base: './',
});
