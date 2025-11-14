import { useLayoutEffect, useState } from 'react';

export const THEME_CACHE_KEY = 'ai-call-ui-theme';

const getInitialTheme = () => {
  const storedTheme = localStorage.getItem(THEME_CACHE_KEY);

  if (storedTheme === 'dark') {
    return true;
  } else if (storedTheme === 'light') {
    return false;
  }

  // 如果没有保存的设置，遵循系统偏好
  // return window.matchMedia('(prefers-color-scheme: dark)').matches;
  return false;
};

const useTheme = () => {
  const [enableDarkMode, setEnableDarkMode] = useState(getInitialTheme());

  useLayoutEffect(() => {
    document.documentElement.setAttribute('data-prefers-color-scheme', enableDarkMode ? 'dark' : 'light');
    localStorage.setItem(THEME_CACHE_KEY, enableDarkMode ? 'dark' : 'light');
  }, [enableDarkMode]);

  const toggleTheme = () => {
    setEnableDarkMode(!enableDarkMode);
  };

  return {
    enableDarkMode,
    toggleTheme,
  };
};

export default useTheme;
