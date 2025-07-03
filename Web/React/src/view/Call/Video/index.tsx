import { useContext, useEffect, useRef, useState } from 'react';
import ControllerContext from '@/view/Call/ControlerContext';

import './index.less';
import useCallStore from '@/view/Call/store';
import { Button, FloatingBubble } from 'antd-mobile';
import { NoCameraSVG, SwitchViewSVG } from '../Icons';
import { addVideoBackground } from '@/common/videoHelper';
import { isMobile } from '@/common/utils';

function Video() {
  const controller = useContext(ControllerContext);

  const primaryVideoRef = useRef<HTMLVideoElement>(null);
  const secondaryVideoRef = useRef<HTMLVideoElement>(null);

  const cameraMuted = useCallStore((state) => state.cameraMuted);

  const [remoteLoading, setRemoteLoading] = useState(true);
  const [primaryVideoType, setPrimaryVideoType] = useState<'local' | 'agent'>('agent');

  useEffect(() => {
    if (!primaryVideoRef.current || !secondaryVideoRef.current) return;

    if (primaryVideoType === 'local') {
      controller?.engine?.setLocalView(primaryVideoRef.current);
      controller?.engine?.setAgentView(secondaryVideoRef.current);
    } else {
      controller?.engine?.setAgentView(primaryVideoRef.current);
      controller?.engine?.setLocalView(secondaryVideoRef.current);
    }

    addVideoBackground(primaryVideoRef.current);
    addVideoBackground(secondaryVideoRef.current);
  }, [controller, primaryVideoType]);

  useEffect(() => {
    return () => {
      controller?.engine?.setLocalView();
      controller?.engine?.setAgentView();
    };
  }, [controller]);

  useEffect(() => {
    const videoElement = primaryVideoType === 'agent' ? primaryVideoRef.current : secondaryVideoRef.current;
    const loaded = () => {
      setRemoteLoading(false);
    };

    if (remoteLoading) {
      // canplay / timeupdate 都认为是加载完成
      videoElement?.addEventListener('canplay', loaded);
      videoElement?.addEventListener('timeupdate', loaded);
    }
    return () => {
      videoElement?.removeEventListener('canplay', loaded);
      videoElement?.removeEventListener('timeupdate', loaded);
    };
  }, [primaryVideoType, remoteLoading]);

  const switchView = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    e.stopPropagation();
    if (isMobile()) {
      setPrimaryVideoType((current) => (current === 'agent' ? 'local' : 'agent'));
    }
  };

  let localVideoClassName = 'is-loaded';
  if (cameraMuted) {
    localVideoClassName = 'is-muted';
  }

  let remoteVideoClassName = 'is-loaded';
  if (remoteLoading) {
    remoteVideoClassName = 'is-loading';
  }

  return (
    <div className={`character video  ${cameraMuted ? '' : 'has-camera'}`}>
      <div className={`_video-box ${primaryVideoType === 'agent' ? remoteVideoClassName : localVideoClassName}`}>
        <ul className='_video-loading'>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
        </ul>
        <div className='_video-none'>{NoCameraSVG}</div>
        <video ref={primaryVideoRef} className='_primary-video' />
      </div>

      <FloatingBubble
        className='_secondary-video-box'
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
        <div className={`_video-box ${primaryVideoType === 'agent' ? localVideoClassName : remoteVideoClassName}`}>
          <ul className='_video-loading'>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
          </ul>
          <div className='_video-none'>{NoCameraSVG}</div>
          <video ref={secondaryVideoRef} className='_secondary-video' />
        </div>
        <Button className='_switchViewBtn'>{SwitchViewSVG}</Button>
      </FloatingBubble>
    </div>
  );
}

export default Video;
