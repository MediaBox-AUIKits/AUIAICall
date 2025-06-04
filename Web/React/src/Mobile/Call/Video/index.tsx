import { useCallback, useContext, useEffect, useRef, useState } from 'react';
import ControllerContext from '@/Mobile/Call/ControlerContext';

import './index.less';
import useCallStore from '@/Mobile/Call/store';
import { Button, FloatingBubble } from 'antd-mobile';
import { SwitchViewSVG } from '../Icons';

function Video() {
  const controller = useContext(ControllerContext);

  const primaryVideoRef = useRef<HTMLVideoElement>(null);
  const secondaryVideoRef = useRef<HTMLVideoElement>(null);

  const [cameraLoading, setCameraLoading] = useState(false);
  const cameraMuted = useCallStore((state) => state.cameraMuted);

  const [primaryVideoType, setPrimaryVideoType] = useState<'local' | 'agent'>('agent');

  const loaded = useCallback(() => {
    setCameraLoading(false);
  }, []);

  useEffect(() => {
    if (!primaryVideoRef.current || !secondaryVideoRef.current) return;

    if (primaryVideoType === 'local') {
      controller?.engine?.setLocalView(primaryVideoRef.current);
      controller?.engine?.setAgentView(secondaryVideoRef.current);
    } else {
      controller?.engine?.setAgentView(primaryVideoRef.current);
      controller?.engine?.setLocalView(secondaryVideoRef.current);
    }
  }, [controller, primaryVideoType]);

  useEffect(() => {
    return () => {
      controller?.engine?.setLocalView();
      controller?.engine?.setAgentView();
    };
  }, [controller]);

  useEffect(() => {
    const videoElement = primaryVideoRef.current;
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

  const switchView = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    e.stopPropagation();
    setPrimaryVideoType((current) => (current === 'agent' ? 'local' : 'agent'));
  };

  return (
    <div className={`character vision  ${cameraMuted ? '' : 'has-camera'}`}>
      {cameraLoading && (
        <div className='_loading'>
          <div></div>
          <div></div>
          <div></div>
        </div>
      )}
      <video ref={primaryVideoRef} className={`_primaryVideo ${cameraLoading ? '' : '_loaded'}`} />

      <FloatingBubble
        className='_secondaryVideoBox'
        axis='xy'
        magnetic='x'
        style={{
          '--initial-position-top': '110px',
          '--initial-position-right': '18px',
          '--edge-distance': '18px',
          '--z-index': '6',
        }}
        onClick={switchView}
      >
        <video ref={secondaryVideoRef} className='_secondaryVideo' />
        <Button className='_switchViewBtn'>{SwitchViewSVG}</Button>
      </FloatingBubble>
    </div>
  );
}

export default Video;
