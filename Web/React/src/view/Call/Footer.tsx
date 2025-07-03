import { ReactNode, useContext, useMemo, useRef } from 'react';
import { Button, Toast } from 'antd-mobile';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import ControllerContext from '@/view/Call/ControlerContext';
import useCallStore from '@/view/Call/store';
import { CallPhoneSVG, CameraClosedSVG, CameraSVG, CameraSwitchSVG, MicrophoneClosedSVG, MicrophoneSVG } from './Icons';

import './footer.less';
import { getRootElement, isMobile } from '@/common/utils';
import { useTranslation } from '@/common/i18nContext';

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

  const stopPushToTalk = useMemo(
    () => () => {
      if (!pushingStartTimeRef.current || !useCallStore.getState().enablePushToTalk) return;
      if (pushingTimerRef.current) {
        clearTimeout(pushingTimerRef.current);
      }
      const duration = Date.now() - pushingStartTimeRef.current;
      if (duration < 500) {
        Toast.show({
          content: '说话时间太短',
          getContainer: () => getRootElement(),
        });
        controller?.cancelPushToTalk();
      } else {
        controller?.finishPushToTalk();
      }
      useCallStore.setState({
        pushingToTalk: false,
      });
      pushingStartTimeRef.current = 0;
    },
    [controller]
  );

  const startPushToTalk = useMemo(
    () => () => {
      if (!useCallStore.getState().enablePushToTalk) return;
      controller?.startPushToTalk();
      useCallStore.setState({
        pushingToTalk: true,
      });
      pushingStartTimeRef.current = Date.now();
      pushingTimerRef.current = window.setTimeout(() => {
        stopPushToTalk();
      }, 60 * 1000);
    },
    [controller, stopPushToTalk]
  );

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
      className={`_call ${
        callState === AICallState.Connected || callState === AICallState.Connecting ? 'is-connected' : ''
      }`}
    >
      <Button onClick={onCallClick}>{CallPhoneSVG}</Button>
      <div className='_label'>
        {callState === AICallState.Connected || callState === AICallState.Connecting
          ? t('actions.handup')
          : t('actions.call')}
      </div>
    </li>
  );

  const emptyBtn = <li key='empty'></li>;

  if (callState === AICallState.Connected) {
    const microphoneBtn = (
      <li
        key='microphone'
        className={`_microphone ${enablePushToTalk ? 'is-push-to-talk' : ''}`}
        onContextMenu={(e) => e.preventDefault()}
      >
        <Button
          onTouchStart={startPushToTalk}
          onTouchEnd={stopPushToTalk}
          onMouseDown={!isTouchSupported ? startPushToTalk : undefined}
          onMouseUp={!isTouchSupported ? stopPushToTalk : undefined}
          onClick={toggleMicrophoneMuted}
          className={pushingToTalk ? 'is-pushing' : ''}
        >
          {microphoneMuted ? MicrophoneClosedSVG : MicrophoneSVG}
        </Button>

        {enablePushToTalk ? (
          <div className='_label'>{pushingToTalk ? t('pushToTalk.releaseToSend') : t('pushToTalk.push')}</div>
        ) : (
          <div className='_label'>{microphoneMuted ? t('microphone.closed') : t('microphone.close')}</div>
        )}
      </li>
    );

    if (agentType === AICallAgentType.VisionAgent || agentType === AICallAgentType.VideoAgent) {
      const cameraBtn = (
        <li key='camera' className='_camera'>
          {!cameraMuted && isMobile() && (
            <div className='_camera-switch'>
              <Button onClick={switchCamera}>{CameraSwitchSVG}</Button>
              <div className='_label'>{t('camera.switch')}</div>
            </div>
          )}
          <Button onClick={toggleCameraMuted}>{cameraMuted ? CameraClosedSVG : CameraSVG}</Button>
          <div className='_label'>{cameraMuted ? t('camera.closed') : t('camera.close')}</div>
        </li>
      );
      btns.push(cameraBtn);

      // push to talk mode, button order is different
      if (enablePushToTalk) {
        btns.push(microphoneBtn);
        btns.push(callBtn);
      } else {
        btns.push(callBtn);
        btns.push(microphoneBtn);
      }
    } else {
      btns.push(callBtn);
      btns.push(microphoneBtn);
      // 对讲机模式，新增占位按钮，让声音按钮在中间
      // push to talk mode, add empty button to make voice button center
      if (enablePushToTalk) {
        btns.push(emptyBtn);
      }
    }
  } else {
    btns.push(callBtn);
  }

  return (
    <div className='footer'>
      <ul className='_action-list'>{btns.map((btn) => btn)}</ul>
    </div>
  );
}
export default Footer;
