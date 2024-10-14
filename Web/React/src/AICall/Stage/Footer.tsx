import { useEffect, useMemo, useRef, useState } from 'react';
import { Button } from 'antd';
import Icon from '@ant-design/icons';

import useCallStore from '../store';
import { AICallAgentState, AICallState } from 'aliyun-auikit-aicall';

import Phone from './svg/phone.svg?react';
import Microphone from './svg/microphone.svg?react';
import MicrophoneClosed from './svg/microphone_closed.svg?react';

import './footer.less';
import i18n from '../i18n';

interface CallActionsProps {
  onStop: () => void;
  toggleMicrophoneMuted: () => void;
}

function CallTip() {
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
        return i18n['status.listeningToStart'];
      }
      return i18n['status.listening'];
    }

    if (agentState === AICallAgentState.Thinking) {
      return i18n['status.thinking'];
    }

    if (agentState === AICallAgentState.Speaking) {
      if (enableVoiceInterrupt) {
        return i18n['status.speaking'];
      } else {
        return i18n['status.speakingNoInterrupt'];
      }
    }

    return '';
  }, [hasSpeaked, agentState, enableVoiceInterrupt]);

  const durationText = useMemo(() => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    return `${hours > 0 ? (hours < 10 ? '0' : '') + hours + ':' : ''}${minutes < 10 ? '0' : ''}${minutes}:${
      remainingSeconds < 10 ? '0' : ''
    }${remainingSeconds}`;
  }, [seconds]);

  return (
    <div className='call-tip'>
      {tipText}
      {callState === AICallState.Connected && <div className='_time'>{durationText}</div>}
    </div>
  );
}

function CallFooter({ onStop, toggleMicrophoneMuted }: CallActionsProps) {
  const microphoneMuted = useCallStore((state) => state.microphoneMuted);

  return (
    <div className='call-footer'>
      <CallTip />
      <div className='call-actions'>
        <ul>
          <li className='call-btn'>
            <Button onClick={onStop}>
              <Icon component={Phone} />
            </Button>
            <div className='_label'>
              <span className='_text'>挂断</span>
            </div>
          </li>
          <li className='call-btn'>
            <Button onClick={toggleMicrophoneMuted}>
              <Icon component={microphoneMuted ? MicrophoneClosed : Microphone} />
            </Button>
            <div className='_label'>
              <span className='_text'>{microphoneMuted ? '开' : '关'}麦克风</span>
            </div>
          </li>
        </ul>
      </div>
    </div>
  );
}

export default CallFooter;
