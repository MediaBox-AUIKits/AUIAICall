import { useEffect, useRef, useState } from 'react';

import './index.less';
import useCallStore from '@/Mobile/Call/store';
import VoiceHero from './Hero';

function Voice() {
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const [showSpeaking, setShowSpeaking] = useState(false);
  const speakingTimerRef = useRef(0);

  const voiceAvatarUrl = useCallStore((state) => state.voiceAvatarUrl);

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
      {voiceAvatarUrl ? (
        <div className='_box'>
          <div className='_agent-status-with-avatar'>
            <div></div>
          </div>
          <div className='_avatar'>
            <img src={voiceAvatarUrl} />
          </div>
        </div>
      ) : (
        <VoiceHero />
      )}
    </div>
  );
}

export default Voice;
