import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import { addRootClass } from '@/common/utils.ts';

const root = document.getElementById('root');
if (!root) throw new Error('root element not found');
addRootClass(root);
createRoot(root).render(<App />);
