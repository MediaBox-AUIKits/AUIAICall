import { forwardRef, useEffect, useState } from 'react';

import { isMobile } from '@/common/utils';

import { videoMutedSVG } from './Icons';

import './video.less';

interface VideoProps {
  className?: string;
  muted?: boolean;
}

const addVideoBlurBackground = (element: HTMLVideoElement) => {
  // 移动端处理
  if (isMobile()) return;

  // 已经添加过
  if (element.getAttribute('data-has-background')) return;
  const handleTimeUpdate = () => {
    if (!element.videoWidth || !element.videoHeight) return;
    const videoAspect = element.videoWidth / element.videoHeight;
    const elementAspect = element.offsetWidth / element.offsetHeight;

    // 比例接近不加背景
    if (Math.abs(videoAspect - elementAspect) < 0.05) {
      return;
    }

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
        div.className = '_background';
        div.style.backgroundImage = `url(${blobUrl})`;
        div.style.opacity = '0';
        parent.appendChild(div);

        //确保元素已添加到 DOM 后再开始动画
        setTimeout(() => {
          div.style.opacity = '1';
        }, 100);
      }, 'image/png');
    }
  };

  element.addEventListener('timeupdate', handleTimeUpdate);
};

const Video = forwardRef<HTMLVideoElement, VideoProps>(({ className, muted }, ref) => {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const videoElement = typeof ref === 'object' && ref?.current ? ref.current : null;
    if (!videoElement) return;

    const loaded = () => {
      setLoading(false);
    };

    // canplay / timeupdate 都认为是加载完成
    videoElement.addEventListener('canplay', loaded);
    videoElement.addEventListener('timeupdate', loaded);

    addVideoBlurBackground(videoElement);

    return () => {
      videoElement.removeEventListener('canplay', loaded);
      videoElement.removeEventListener('timeupdate', loaded);
    };
  }, [ref]);

  return (
    <div className={`ai-video ${loading ? 'is-loading' : 'is-loaded'} ${muted ? 'is-muted' : ''} ${className || ''}`}>
      <div className='_box'>
        <ul className='_loading'>
          {Array.from({ length: 5 }).map((_, index) => (
            <li key={index} />
          ))}
        </ul>
        <div className='_none'>{videoMutedSVG}</div>
        <video ref={ref} />
      </div>
    </div>
  );
});

Video.displayName = 'Video';

export default Video;
