import { useContext, useEffect, useRef, useState } from 'react';

import './index.less';
import useCallStore from '@/Mobile/Call/store';
import ControllerContext from '@/Mobile/Call/ControlerContext';
import VoiceHero from './Hero';

function Voice() {
  const controller = useContext(ControllerContext);
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const [showSpeaking, setShowSpeaking] = useState(false);
  const speakingTimerRef = useRef(0);

  const avatarUrl = controller?.config.templateConfig?.avatarUrl;

  useEffect(() => {
    if (isSpeaking === showSpeaking) return;
    if (isSpeaking) {
      // 如果准备停止显示，则取消
      // in case of prepare to stop showing, cancel it
      if (speakingTimerRef.current) {
        clearTimeout(speakingTimerRef.current);
      }
      setShowSpeaking(true);
    } else {
      speakingTimerRef.current = window.setTimeout(() => {
        setShowSpeaking(false);
      }, 200);
    }
  }, [isSpeaking, showSpeaking]);

  return (
    <div className='character voice'>
      {avatarUrl ? (
        <div className='_box'>
          <div className='_agent-status-with-avatar'>
            <div></div>
          </div>
          <div className='_avatar'>
            <img src={avatarUrl} />
          </div>
        </div>
      ) : (
        <VoiceHero />
      )}
    </div>
  );
}

export default Voice;
