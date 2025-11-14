import { useEffect, useState } from 'react';

/**
 * 在窗口宽度跨越 768px 时触发重新渲染的 Hook
 * @returns {boolean} isMobile - true 表示宽度 <= 768px（移动端），false 表示宽度 > 768px（桌面端）
 */
export const useResponsiveBreakpoint = () => {
  const [isMobileUI, setIsMobileUI] = useState(() => {
    // 初始值：服务端渲染时返回 false，客户端根据实际宽度判断
    if (typeof window === 'undefined') {
      return false;
    }
    return window.innerWidth <= 768;
  });

  useEffect(() => {
    // 定义断点检查函数
    const checkBreakpoint = () => {
      const currentIsMobile = window.innerWidth <= 768;
      setIsMobileUI(currentIsMobile);
    };

    // 初始检查
    checkBreakpoint();

    // 添加 resize 事件监听器
    let resizeTimer: number;
    const handleResize = () => {
      // 防抖处理，避免频繁触发
      window.clearTimeout(resizeTimer);
      resizeTimer = window.setTimeout(checkBreakpoint, 150);
    };

    window.addEventListener('resize', handleResize);

    // 清理函数
    return () => {
      window.removeEventListener('resize', handleResize);
      window.clearTimeout(resizeTimer);
    };
  }, []);

  return isMobileUI;
};
