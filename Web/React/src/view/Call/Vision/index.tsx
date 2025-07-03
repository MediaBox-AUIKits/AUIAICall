import { useContext, useEffect, useRef, useState } from 'react';
import ControllerContext from '@/view/Call/ControlerContext';

import './index.less';
import useCallStore from '@/view/Call/store';
import { NoCameraSVG } from '../Icons';

function Vision() {
  const previewRef = useRef<HTMLVideoElement>(null);
  const controller = useContext(ControllerContext);
  const [cameraLoading, setCameraLoading] = useState(true);
  const cameraMuted = useCallStore((state) => state.cameraMuted);

  useEffect(() => {
    if (previewRef.current) {
      controller?.startPreview(previewRef.current);
    }
  }, [controller]);

  useEffect(() => {
    const videoElement = previewRef.current;
    const loaded = () => {
      setCameraLoading(false);
    };

    if (cameraLoading) {
      // canplay / timeupdate 都认为是加载完成
      videoElement?.addEventListener('canplay', loaded);
      videoElement?.addEventListener('timeupdate', loaded);
    }
    return () => {
      videoElement?.removeEventListener('canplay', loaded);
      videoElement?.removeEventListener('timeupdate', loaded);
    };
  }, [cameraLoading]);

  let videoClassName = 'is-loaded';
  if (cameraLoading) {
    videoClassName = 'is-loading';
  } else if (cameraMuted) {
    videoClassName = 'is-muted';
  }

  return (
    <div className={`character vision`}>
      <div className={`_video-box ${videoClassName}`}>
        <ul className='_video-loading'>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
        </ul>
        <div className='_video-none'>{NoCameraSVG}</div>
        <video ref={previewRef} />
      </div>
    </div>
  );
}

export default Vision;
