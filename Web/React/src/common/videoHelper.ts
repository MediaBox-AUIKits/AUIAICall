import { isMobile } from './utils';

export const addVideoBackground = (element: HTMLVideoElement) => {
  // 移动端不支持
  if (isMobile()) return;

  // 已经添加过
  if (element.getAttribute('data-has-background')) return;
  const handleTimeUpdate = () => {
    if (!element.videoWidth || !element.videoHeight) return;
    const currentTime = element.currentTime;
    if (currentTime > 0) {
      element.removeEventListener('timeupdate', handleTimeUpdate);
      const canvas = document.createElement('canvas');
      canvas.width = element.videoWidth;
      canvas.height = element.videoHeight;
      const ctx = canvas.getContext('2d');
      ctx?.drawImage(element, 0, 0, canvas.width, canvas.height);

      element.setAttribute('data-has-background', 'true');

      // 转换为 Blob
      canvas.toBlob(function (blob) {
        if (!blob) {
          return;
        }

        // 获取 Blob 地址
        const blobUrl = URL.createObjectURL(blob);
        const parent = element.parentElement as HTMLDivElement;
        const div = document.createElement('div');
        div.className = '_video-background';
        div.style.backgroundImage = `url(${blobUrl})`;
        parent.appendChild(div);
      }, 'image/png');
    }
  };

  element.addEventListener('timeupdate', handleTimeUpdate);
};
