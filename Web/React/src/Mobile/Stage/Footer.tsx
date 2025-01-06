import { ReactNode, useContext, useMemo, useRef } from 'react';
import { Button, Toast } from 'antd-mobile';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import ControllerContext from '@/common/ControlerContext';
import useCallStore from '@/common/store';
import { CallPhoneSVG, CameraClosedSVG, CameraSVG, CameraSwitchSVG, MicrophoneClosedSVG, MicrophoneSVG } from './Icons';

import './footer.less';
import { getRootElement, isMobile } from '@/common/utils';

interface CallFooterProps {
  onCall: () => void;
  onStop: () => void;
}

function Footer({ onStop, onCall }: CallFooterProps) {
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
    // messageApi.success(to ? '麦克风已关闭' : '麦克风已开启');
    useCallStore.setState({
      microphoneMuted: to,
    });
  };

  const toggleCameraMuted = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    const to = !useCallStore.getState().cameraMuted;
    controller?.muteCamera(to);
    // messageApi.success(to ? '摄像头已关闭' : '摄像头已开启');
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
    if (callState === AICallState.Connected) {
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
      <Button onClick={onCallClick} disabled={callState === AICallState.Connecting}>
        {CallPhoneSVG}
      </Button>
      <div className='_label'>
        {callState === AICallState.Connected || callState === AICallState.Connecting ? '挂断' : '拨打'}
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
          <div className='_label'>{pushingToTalk ? '松开发送' : '按住讲话'}</div>
        ) : (
          <div className='_label'>{microphoneMuted ? '麦克风已关' : '关麦克风'}</div>
        )}
      </li>
    );

    if (agentType === AICallAgentType.VisionAgent) {
      const cameraBtn = (
        <li key='camera' className='_camera'>
          {!cameraMuted && isMobile() && (
            <div className='_camera-switch'>
              <Button onClick={switchCamera}>{CameraSwitchSVG}</Button>
              <div className='_label'>镜头翻转</div>
            </div>
          )}
          <Button onClick={toggleCameraMuted}>{cameraMuted ? CameraClosedSVG : CameraSVG}</Button>
          <div className='_label'>{cameraMuted ? '摄像头已关' : '关摄像头'}</div>
        </li>
      );
      btns.push(cameraBtn);

      // 对讲机模式，按钮在中间
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
