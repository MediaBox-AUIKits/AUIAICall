import { useCallback, useContext, useEffect, useRef, useState } from 'react';
import ControllerContext from '../../../ControlerContext';
import './index.less';
import useCallStore from '../../store';

import noCameraUrl from './noCamera.png';

function Vision() {
  const previewRef = useRef<HTMLVideoElement>(null);
  const controller = useContext(ControllerContext);
  const [cameraLoading, setCameraLoading] = useState(false);

  const cameraMuted = useCallStore((state) => state.cameraMuted);

  const loaded = useCallback(() => {
    setCameraLoading(false);
  }, []);

  useEffect(() => {
    if (previewRef.current) {
      controller?.startPreview(previewRef.current);
    }
  }, [controller]);

  useEffect(() => {
    const videoElement = previewRef.current;
    if (cameraLoading) {
      // canplay / timeupdate 都认为是加载完成
      videoElement?.addEventListener('canplay', loaded);
      videoElement?.addEventListener('timeupdate', loaded);
    }
    return () => {
      videoElement?.removeEventListener('canplay', loaded);
      videoElement?.removeEventListener('timeupdate', loaded);
    };
  }, [cameraLoading, loaded]);

  useEffect(() => {
    if (previewRef.current) {
      controller?.setAgentView(previewRef.current);
    }
  }, [controller]);

  return (
    <div className={`vision-show ${cameraMuted ? '' : 'has-camera'}`}>
      {cameraLoading && (
        <div className='_loading'>
          <div></div>
          <div></div>
          <div></div>
        </div>
      )}
      <div className='_muted'>
        <img src={noCameraUrl} alt='' />
      </div>
      <video ref={previewRef} className={cameraLoading ? '' : '_loaded'} />
    </div>
  );
}

export default Vision;
