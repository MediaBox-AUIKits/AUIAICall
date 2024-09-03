import { useEffect, useMemo, useRef, useState } from 'react';
import { AICallAgentState, AICallState } from '../../aiCall/type';
import useCallStore from '../store';

import './tip.less';

const AgentStateTipMap = {
  [AICallAgentState.Listening]: '你说，我在听...',
  [AICallAgentState.Thinking]: '你说，我在听...',
  [AICallAgentState.Talking]: '我正在回复中，可以点击“tab”键或说话打断我',
};

function CallTip() {
  const [seconds, setSeconds] = useState(0);
  const durationTimerRef = useRef(0);
  const startTimeRef = useRef(0);

  const [hasSpeaked, setHasSpeaked] = useState(false);
  const callState = useCallStore((state) => state.callState);
  const agentState = useCallStore((state) => state.agentState);
  const isSpeaking = useCallStore((state) => state.isSpeaking);

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

  const tipText = AgentStateTipMap[agentState];

  const durationText = useMemo(() => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    return `${hours > 0 ? (hours < 10 ? '0' : '') + hours + ':' : ''}${minutes < 10 ? '0' : ''}${minutes}:${
      remainingSeconds < 10 ? '0' : ''
    }${remainingSeconds}`;
  }, [seconds]);

  return (
    <div className='voice-call-tip'>
      {!hasSpeaked && agentState === AICallAgentState.Listening ? '请开始说话' : tipText}

      {callState === AICallState.Connected && <div className='_time'>{durationText}</div>}
    </div>
  );
}

export default CallTip;
