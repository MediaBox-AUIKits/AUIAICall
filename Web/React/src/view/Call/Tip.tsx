import useCallStore from '@/view/Call/store';
import { AICallState, AICallAgentState } from 'aliyun-auikit-aicall';
import { useState, useRef, useEffect, useMemo } from 'react';
import './tip.less';
import { useTranslation } from '@/common/i18nContext';
import { isMobile } from '@/common/utils';

function CallTip() {
  const { t } = useTranslation();

  const [seconds, setSeconds] = useState(0);
  const durationTimerRef = useRef(0);
  const startTimeRef = useRef(0);

  const [hasSpeaked, setHasSpeaked] = useState(false);
  const callState = useCallStore((state) => state.callState);
  const agentState = useCallStore((state) => state.agentState);
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);

  useEffect(() => {
    if (isSpeaking) {
      setHasSpeaked(true);
    }
  }, [isSpeaking]);

  useEffect(() => {
    if (callState === AICallState.Connected) {
      setSeconds(0);
      startTimeRef.current = Date.now();
      durationTimerRef.current = window.setInterval(() => {
        setSeconds(Math.floor((Date.now() - startTimeRef.current) / 1000));
      }, 1000);
    } else {
      clearInterval(durationTimerRef.current);
    }
  }, [callState]);

  const tipText = useMemo(() => {
    if (agentState === AICallAgentState.Listening) {
      if (!hasSpeaked) {
        return t('status.listeningToStart');
      }
      return t('status.listening');
    }

    if (agentState === AICallAgentState.Thinking) {
      return t('status.thinking');
    }

    if (agentState === AICallAgentState.Speaking) {
      if (enableVoiceInterrupt) {
        if (isMobile()) {
          return t('status.mobile.speaking');
        }
        return t('status.speaking');
      } else {
        if (isMobile()) {
          return t('status.mobile.speakingNoInterrupt');
        }
        return t('status.speakingNoInterrupt');
      }
    }

    return '';
  }, [hasSpeaked, agentState, enableVoiceInterrupt, t]);

  const durationText = useMemo(() => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    return `${hours > 0 ? (hours < 10 ? '0' : '') + hours + ':' : ''}${minutes < 10 ? '0' : ''}${minutes}:${
      remainingSeconds < 10 ? '0' : ''
    }${remainingSeconds}`;
  }, [seconds]);

  return (
    <div className='tip'>
      <div className='_time'>{callState === AICallState.Connected ? durationText : ' '}</div>
      <div className='_text'>{tipText}</div>
    </div>
  );
}

export default CallTip;
