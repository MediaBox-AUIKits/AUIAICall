import { AICallState } from 'aliyun-auikit-aicall';
import { Button, SafeArea, Toast } from 'antd-mobile';
import { ReactNode, useContext, useEffect, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { getRootElement, isMobile } from '@/common/utils';
import ControllerContext from 'call/ControlerContext';
import useCallStore from 'call/store';

import { hasVideoOutbound } from '../utils';
import {
  footerCallSVG,
  footerCameraClosedSVG,
  footerCameraSVG,
  footerCameraSwitchSVG,
  footerHandupSVG,
  footerMicrophoneClosedSVG,
  footerMicrophoneSVG,
  footerPushingSVG,
} from './Icons';

import './footer.less';

interface CallFooterProps {
  onCall: () => void;
  onStop: () => void;
}

function Footer({ onStop, onCall }: CallFooterProps) {
  const { t } = useTranslation();

  const controller = useContext(ControllerContext);
  const agentType = useCallStore((state) => state.agentType);
  const callState = useCallStore((state) => state.callState);
  const microphoneMuted = useCallStore((state) => state.microphoneMuted);
  const cameraMuted = useCallStore((state) => state.cameraMuted);
  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const pushingToTalk = useCallStore((state) => state.pushingToTalk);
  const pushingStartTimeRef = useRef(0);
  const pushingTimerRef = useRef(0);
  const startYRef = useRef(0);
  const [willCancel, setWillCancel] = useState(false);
  const willCancelRef = useRef(false);
  const pushButtonRef = useRef<HTMLDivElement>(null);

  const isTouchSupported = 'ontouchstart' in window;

  const toggleMicrophoneMuted = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    if (enablePushToTalk) return;
    const to = !useCallStore.getState().microphoneMuted;
    controller?.muteMicrophone(to);
    useCallStore.setState({
      microphoneMuted: to,
    });
  };

  const toggleCameraMuted = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    const to = !useCallStore.getState().cameraMuted;
    controller?.muteCamera(to);
    useCallStore.setState({
      cameraMuted: to,
    });
  };
  const switchCamera = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    controller?.switchCamera();
  };

  // 使用 useEffect 绑定原生事件监听器
  useEffect(() => {
    const element = pushButtonRef.current;
    if (!element || !enablePushToTalk) return;

    const stopPushToTalk = () => {
      if (!pushingStartTimeRef.current || !useCallStore.getState().enablePushToTalk) return;
      if (pushingTimerRef.current) {
        clearTimeout(pushingTimerRef.current);
      }
      const duration = Date.now() - pushingStartTimeRef.current;
      if (duration < 500) {
        Toast.show({
          content: t('pushToTalk.speakTimeTooShort'),
          getContainer: () => getRootElement(),
        });
        controller?.cancelPushToTalk();
      } else if (willCancelRef.current) {
        controller?.cancelPushToTalk();
      } else {
        controller?.finishPushToTalk();
      }
      useCallStore.setState({
        pushingToTalk: false,
      });
      pushingStartTimeRef.current = 0;
    };

    const startPushToTalk = (event: TouchEvent | MouseEvent) => {
      event.preventDefault();
      if (!useCallStore.getState().enablePushToTalk) return;
      setWillCancel(false);
      const clientY = 'touches' in event ? event.touches[0].clientY : (event as MouseEvent).clientY;
      startYRef.current = clientY || 0;
      willCancelRef.current = false;
      controller?.startPushToTalk();
      useCallStore.setState({
        pushingToTalk: true,
      });
      pushingStartTimeRef.current = Date.now();
      pushingTimerRef.current = window.setTimeout(() => {
        stopPushToTalk();
      }, 60 * 1000);
    };

    const handleTouchMove = (event: TouchEvent) => {
      event.preventDefault();
      const y = event.touches[0].clientY || 0;
      if (!willCancelRef.current && Math.abs(y - startYRef.current) > 40) {
        setWillCancel(true);
        willCancelRef.current = true;
      }
    };

    // 绑定事件监听器

    if (isTouchSupported) {
      element.addEventListener('touchstart', startPushToTalk, { passive: false });
      element.addEventListener('touchmove', handleTouchMove, { passive: false });
      element.addEventListener('touchend', stopPushToTalk, { passive: false });
    } else {
      element.addEventListener('mousedown', startPushToTalk, { passive: false });
      element.addEventListener('mouseup', stopPushToTalk, { passive: false });
    }

    // 清理函数
    return () => {
      if (isTouchSupported) {
        element.removeEventListener('touchstart', startPushToTalk);
        element.removeEventListener('touchmove', handleTouchMove);
        element.removeEventListener('touchend', stopPushToTalk);
      } else {
        element.removeEventListener('mousedown', startPushToTalk);
        element.removeEventListener('mouseup', stopPushToTalk);
      }
    };
  }, [enablePushToTalk, isTouchSupported]);

  const onCallClick = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    if (callState === AICallState.Connected || callState === AICallState.Connecting) {
      onStop();
    } else {
      onCall();
    }
  };

  const btns: ReactNode[] = [];

  const callBtn = (
    <li
      key='call'
      className={`_call ${callState === AICallState.None || callState === AICallState.Over ? 'is-none' : ''}`}
    >
      <Button fill='none' onClick={onCallClick}>
        {callState === AICallState.None || callState === AICallState.Over ? footerCallSVG : footerHandupSVG}
      </Button>
    </li>
  );

  const hasCamera = hasVideoOutbound(agentType);

  if (callState === AICallState.Connected) {
    const microphoneBtn = (
      <li key='microphone' className={`_microphone`} onContextMenu={(e) => e.preventDefault()}>
        <Button fill='none' onClick={toggleMicrophoneMuted} className={microphoneMuted ? 'is-muted' : ''}>
          {microphoneMuted ? footerMicrophoneClosedSVG : footerMicrophoneSVG}
        </Button>
      </li>
    );
    if (!enablePushToTalk) {
      btns.push(microphoneBtn);
    }

    if (hasCamera) {
      const cameraBtn = (
        <li key='camera' className='_camera'>
          <Button fill='none' className={cameraMuted ? 'is-muted' : ''} onClick={toggleCameraMuted}>
            {cameraMuted ? footerCameraClosedSVG : footerCameraSVG}
          </Button>
        </li>
      );

      btns.push(cameraBtn);
    }

    btns.push(callBtn);

    if (hasCamera && !cameraMuted && isMobile()) {
      const cameraSwitchBtn = (
        <li key='camera-switch' className='_camera-switch'>
          <Button fill='none' onClick={switchCamera}>
            {footerCameraSwitchSVG}
          </Button>
        </li>
      );

      btns.push(cameraSwitchBtn);
    }
  } else {
    btns.push(callBtn);
  }

  return (
    <div className='footer'>
      <ul className={`_actions ${btns.length > 3 ? 'is-multi' : ''}`}>{btns.map((btn) => btn)}</ul>

      {enablePushToTalk && (
        <div className={`_pushtotalk ${pushingToTalk ? 'is-pushing' : ''} ${willCancel ? 'is-will-cancel' : ''}`}>
          <div ref={pushButtonRef}>
            <Button className='_push-btn' block fill='none'>
              <span className='_text'>{t('pushToTalk.holdToSpeak')}</span>
              <span className='_icon'>{footerPushingSVG}</span>
            </Button>
          </div>

          <div className='_pushtotalk-mask'></div>
          <div className='_pushtotalk-pushing'>
            <Button fill='none' className='_tip-btn'>
              {footerHandupSVG}
            </Button>
            <span className='_tip'>{t('pushToTalk.releaseToSendSwipeToCancel')}</span>
            <div className='_bg'>
              <div className='_arc'></div>
              <SafeArea position='bottom' />
            </div>
          </div>
        </div>
      )}
      <div className='ai-flex-1'></div>
      <div className='_statement'>{t('system.statement')}</div>
      <SafeArea position='bottom' />
    </div>
  );
}
export default Footer;
