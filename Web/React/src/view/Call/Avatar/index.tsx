import { useContext, useEffect, useRef, useState } from 'react';
import './index.less';
import ControllerContext from '@/view/Call/ControlerContext';
import { isMobile } from '@/common/utils';
import { addVideoBackground } from '@/common/videoHelper';

function Avatar() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const controller = useContext(ControllerContext);

  const [avatarLoading, setAvatarLoading] = useState(true);

  useEffect(() => {
    if (isMobile()) return;
    if (videoRef.current) {
      addVideoBackground(videoRef.current);
    }
  }, []);

  useEffect(() => {
    const videoElement = videoRef.current;
    const loaded = () => {
      setAvatarLoading(false);
    };

    if (avatarLoading) {
      // canplay / timeupdate 都认为是加载完成
      videoElement?.addEventListener('canplay', loaded);
      videoElement?.addEventListener('timeupdate', loaded);
    }
    return () => {
      videoElement?.removeEventListener('canplay', loaded);
      videoElement?.removeEventListener('timeupdate', loaded);
    };
  }, [avatarLoading]);

  useEffect(() => {
    if (videoRef.current) {
      controller?.setAgentView(videoRef.current);
    }
  }, [controller]);

  return (
    <div className='character avatar'>
      <div className={`_video-box ${avatarLoading ? 'is-loading' : 'is-loaded'}`}>
        <ul className='_video-loading'>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
        </ul>
        <video ref={videoRef} />
      </div>
    </div>
  );
}

export default Avatar;
