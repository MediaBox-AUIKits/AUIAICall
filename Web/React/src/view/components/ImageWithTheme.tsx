import { ImgHTMLAttributes, useEffect, useState } from 'react';

interface ImageWithThemeProps extends ImgHTMLAttributes<HTMLImageElement> {
  'dark-src'?: string;
}

const ImageWithTheme = ({ src, 'dark-src': darkSrc, ...props }: ImageWithThemeProps) => {
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'attributes' && mutation.attributeName === 'data-prefers-color-scheme') {
          const isDark = document.documentElement.getAttribute('data-prefers-color-scheme') === 'dark';
          setIsDarkMode(isDark);
        }
      });
    });

    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-prefers-color-scheme'],
    });

    if (document.documentElement.getAttribute('data-prefers-color-scheme') === 'dark') {
      setIsDarkMode(true);
    }

    return () => {
      observer.disconnect();
    };
  }, []);

  // 优先使用暗黑模式图片（如果当前是暗黑模式且提供了暗黑模式图片）
  const imageSrc = isDarkMode && darkSrc ? darkSrc : src;

  return <img src={imageSrc} {...props} />;
};

export default ImageWithTheme;
