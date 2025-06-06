import { useCallback, useContext, useEffect, useRef, useState } from 'react';
import './index.less';
import ControllerContext from '@/Mobile/Call/ControlerContext';

function Video() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const controller = useContext(ControllerContext);

  const [avatarLoading, setAvatarLoading] = useState(true);

  const loaded = useCallback(() => {
    setAvatarLoading(false);
  }, []);

  useEffect(() => {
    const videoElement = videoRef.current;
    if (avatarLoading) {
      // canplay / timeupdate 都认为是加载完成
      // canplay / timeupdate both are considered as video loaded
      videoElement?.addEventListener('canplay', loaded);
      videoElement?.addEventListener('timeupdate', loaded);
    }
    return () => {
      videoElement?.removeEventListener('canplay', loaded);
      videoElement?.removeEventListener('timeupdate', loaded);
    };
  }, [avatarLoading, loaded]);

  useEffect(() => {
    if (videoRef.current) {
      controller?.setAgentView(videoRef.current);
    }
  }, [controller]);

  return (
    <div className='avatar-show'>
      {avatarLoading && (
        <div className='_loading'>
          <div></div>
          <div></div>
          <div></div>
        </div>
      )}
      <video ref={videoRef} className={avatarLoading ? '' : '_loaded'} />
    </div>
  );
}

export default Video;
