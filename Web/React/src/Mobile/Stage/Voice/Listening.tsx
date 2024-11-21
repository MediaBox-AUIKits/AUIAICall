import useCallStore from '@/common/store';

import './listening.less';
import { useContext, useEffect, useRef } from 'react';
import ControllerContext from '@/common/ControlerContext';

function VoiceListening() {
  const agentState = useCallStore((state) => state.agentState);
  const controller = useContext(ControllerContext);
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const onVolume = (uid: string, volume: number) => {
      if (uid === '') {
        rootRef.current?.style.setProperty('--strong', `${volume / 100}`);
      }
    };

    controller?.on('AICallActiveSpeakerVolumeChanged', onVolume);
    return () => {
      controller?.off('AICallActiveSpeakerVolumeChanged', onVolume);
    };
  }, [controller, agentState]);

  return (
    <div className='voice-listening' ref={rootRef}>
      <ul className='is-line-1'>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
      </ul>
      <ul className='is-line-2'>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
      </ul>
      <ul className='is-line-3'>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
      </ul>
    </div>
  );
}

export default VoiceListening;
