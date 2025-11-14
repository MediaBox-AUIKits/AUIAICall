import { useContext, useEffect, useRef } from 'react';

import ControllerContext from 'call/ControlerContext';

import Video from '../components/Video';

import './index.less';

function Avatar() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const controller = useContext(ControllerContext);

  useEffect(() => {
    if (videoRef.current) {
      controller?.setAgentView(videoRef.current);
    }
  }, [controller]);

  return (
    <div className='actor avatar'>
      <Video ref={videoRef}></Video>
    </div>
  );
}

export default Avatar;
