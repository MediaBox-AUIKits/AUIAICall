import { useContext, useEffect, useRef } from 'react';

import ControllerContext from 'call/ControlerContext';
import useCallStore from 'call/store';

import Video from '../components/Video';
import './index.less';

function Vision() {
  const previewRef = useRef<HTMLVideoElement>(null);
  const controller = useContext(ControllerContext);
  const cameraMuted = useCallStore((state) => state.cameraMuted);

  useEffect(() => {
    if (previewRef.current) {
      controller?.startPreview(previewRef.current);
    }
  }, [controller]);

  return (
    <div className={`actor vision`}>
      <Video ref={previewRef} muted={cameraMuted} />
    </div>
  );
}

export default Vision;
