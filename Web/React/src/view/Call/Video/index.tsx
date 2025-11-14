import { Button, FloatingBubble } from 'antd-mobile';
import { useContext, useEffect, useRef, useState } from 'react';

import { isMobile } from '@/common/utils';
import ControllerContext from 'call/ControlerContext';
import useCallStore from 'call/store';

import { switchViewSVG } from '../components/Icons';

import Video from '../components/Video';
import './index.less';

function VideoActor() {
  const controller = useContext(ControllerContext);

  const primaryVideoRef = useRef<HTMLVideoElement>(null);
  const secondaryVideoRef = useRef<HTMLVideoElement>(null);

  const cameraMuted = useCallStore((state) => state.cameraMuted);

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
  }, [controller, primaryVideoType]);

  useEffect(() => {
    return () => {
      controller?.engine?.setLocalView();
      controller?.engine?.setAgentView();
    };
  }, [controller]);

  const switchView = (e: React.MouseEvent<HTMLDivElement, MouseEvent>) => {
    e.stopPropagation();
    if (isMobile()) {
      setPrimaryVideoType((current) => (current === 'agent' ? 'local' : 'agent'));
    }
  };

  return (
    <div className={`actor video  ${cameraMuted ? '' : 'has-camera'}`}>
      <Video
        ref={primaryVideoRef}
        className={primaryVideoType === 'agent' ? 'is-remote' : 'is-local'}
        muted={primaryVideoType !== 'agent' && cameraMuted}
      />

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
        <Video
          ref={secondaryVideoRef}
          className={primaryVideoType === 'agent' ? 'is-remote' : 'is-local'}
          muted={primaryVideoType === 'agent' && cameraMuted}
        />
        <Button className='_switch-view-btn'>{switchViewSVG}</Button>
      </FloatingBubble>
    </div>
  );
}

export default VideoActor;
