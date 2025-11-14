import { createRoot } from 'react-dom/client';

import { I18nProvider } from '@/common/i18nContext.tsx';
import { addRootClass } from '@/common/utils.ts';

import App from './App.tsx';

const root = document.getElementById('root');
if (!root) throw new Error('root element not found');
addRootClass(root);
createRoot(root).render(
  <I18nProvider>
    <App />
  </I18nProvider>
);
