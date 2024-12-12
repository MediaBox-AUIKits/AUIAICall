export function debounce<F extends (...args: Parameters<F>) => ReturnType<F>>(
  func: F,
  waitFor: number
): (...args: Parameters<F>) => void {
  let timeout: ReturnType<typeof setTimeout>;

  return (...args: Parameters<F>): void => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), waitFor);
  };
}

export const ROOT_CLASS_NAME = 'aicall-root';
export const getRootElement = () => {
  const root = document.querySelector(`.${ROOT_CLASS_NAME}`);
  if (!root) {
    return null;
  }
  return root;
};

export const addRootClass = (element: HTMLElement) => {
  if (!element.classList.contains(ROOT_CLASS_NAME)) {
    element.classList.add(ROOT_CLASS_NAME);
  }
};

export const copyText = (text: string) => {
  if (navigator.clipboard && navigator.clipboard.writeText) {
    return navigator.clipboard.writeText(text);
  } else {
    throw new Error('clipboard is not supported');
  }
};

export const isMobile = () => {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
};

export const isAndroidWeChatBrowser = () => {
  const ua = navigator.userAgent;

  // 检查是否包含 Android 和 MicroMessenger
  return /Android/i.test(ua) && /MicroMessenger/i.test(ua);
};
