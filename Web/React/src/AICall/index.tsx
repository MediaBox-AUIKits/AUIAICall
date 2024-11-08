import { message } from 'antd';

import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import Stage from './Stage';
import Welcome from './Welcome';
import Message from './Message';
import useCallStore from './store';

import './index.less';
import { useContext, useEffect, useMemo, useRef, useState } from 'react';
import { debounce } from '../utils';
import ControllerContext from '../ControlerContext';
import i18n, { getErrorMessage } from './i18n';

interface AICallProps {
  limitSecond?: number;
  onAuthFail?: () => void;
}

function AICall(props: AICallProps) {
  const { limitSecond, onAuthFail } = props;
  const controller = useContext(ControllerContext);
  const callState = useCallStore((state) => state.callState);
  const agentType = useCallStore((state) => state.agentType);
  const [showMessage, setShowMessage] = useState(true);
  const [messageApi, contextHolder] = message.useMessage();
  const pushingStartTimeRef = useRef(0);
  const pushingTimerRef = useRef(0);

  const countdownRef = useRef(0);
  const startTimeRef = useRef(0);

  // 切换 controller 后重置状态
  useEffect(() => {
    controller?.handup();
    useCallStore.getState().reset();
  }, [controller]);

  const stopPushToTalk = useMemo(
    () => () => {
      if (!pushingStartTimeRef.current || !useCallStore.getState().enablePushToTalk) return;
      if (pushingTimerRef.current) {
        clearTimeout(pushingTimerRef.current);
      }
      const duration = Date.now() - pushingStartTimeRef.current;
      if (duration < 500) {
        messageApi.error('说话时间太短');
        controller?.cancelPushToTalk();
      } else {
        controller?.finishPushToTalk();
      }
      useCallStore.setState({
        pushingToTalk: false,
      });
      pushingStartTimeRef.current = 0;
    },
    [controller, messageApi]
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

  // Tab 键打断
  const onKeyDown = useMemo(() => {
    // 不把 debounce 放到 onKeyDown 是因为需要阻止 Tab 键的默认行为
    const interruptSpeaking = debounce(() => {
      controller?.interruptSpeaking();
    }, 100);
    return (e: KeyboardEvent) => {
      if (e.key === 'Tab') {
        e.stopImmediatePropagation();
        e.preventDefault();
        e.stopPropagation();
        interruptSpeaking();
      } else if (e.key === ' ') {
        if (pushingStartTimeRef.current) return;
        e.stopImmediatePropagation();
        e.preventDefault();
        e.stopPropagation();
        startPushToTalk();
      }
    };
  }, [controller, startPushToTalk]);

  const onKeyUp = useMemo(() => {
    return (e: KeyboardEvent) => {
      if (e.key === ' ') {
        stopPushToTalk();
      }
    };
  }, [stopPushToTalk]);

  useEffect(() => {
    document.addEventListener('keydown', onKeyDown, true);
    document.addEventListener('keyup', onKeyUp, true);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
      document.removeEventListener('keyup', onKeyUp);
      controller?.removeAllListeners();
      controller?.handup();
    };
  }, [controller, onKeyDown, onKeyUp]);

  // 开始通话
  const startCall = async (agentType: AICallAgentType) => {
    if (!controller) return;
    controller.config.agentType = agentType;
    // controller.config.enablePushToTalk = true;

    useCallStore.setState({
      agentType,
      // enablePushToTalk: true,
    });

    controller.on('AICallStateChanged', (newState) => {
      useCallStore.setState({
        callState: newState,
      });
      if (newState === AICallState.Error) {
        controller?.handup();
        useCallStore.setState({
          callErrorMessage: getErrorMessage(controller.errorCode),
        });
      }
    });

    controller.on('AICallAgentStateChanged', (newState) => {
      useCallStore.setState({
        agentState: newState,
      });
    });

    controller.on('AICallActiveSpeakerVolumeChanged', (userId, volume) => {
      if (userId === '') {
        // 本地说话状态
        useCallStore.setState({
          isSpeaking: volume > 30,
        });
      }
    });

    // 实时字幕相关呢
    controller.on('AICallAgentSubtitleNotify', (data) => {
      useCallStore.getState().setCurrentSubtitle({
        data,
        source: 'agent',
      });
    });
    controller.on('AICallUserSubtitleNotify', (data) => {
      useCallStore.getState().setCurrentSubtitle({
        data,
        source: 'user',
      });
    });

    controller.on('AICallUserTokenExpired', () => {
      messageApi.error(i18n['login.tokenExpired']);
      onAuthFail?.();
    });

    controller.on('AICallBegin', () => {
      if (countdownRef.current) {
        window.clearInterval(countdownRef.current);
      }
      if (controller.config.agentType === AICallAgentType.AvatarAgent && limitSecond && limitSecond > 0) {
        startTimeRef.current = Date.now();
        countdownRef.current = window.setInterval(() => {
          const time = Date.now() - startTimeRef.current;
          if (time > limitSecond * 1000) {
            stopCall();
          }
        }, limitSecond);
      }
    });

    try {
      await controller.start();
    } catch (error) {
      console.log(error, controller.errorCode);
      useCallStore.setState({ callState: AICallState.Error, callErrorMessage: getErrorMessage(controller.errorCode) });
    }
  };

  const stopCall = async () => {
    controller?.handup();
    useCallStore.getState().reset();
  };

  return (
    <div
      className={`call ${
        agentType === AICallAgentType.AvatarAgent && callState === AICallState.Connected ? 'is-avatar' : 'is-voice'
      }`}
    >
      {contextHolder}
      {callState === AICallState.Connected ? (
        <>
          <Stage
            showMessage={showMessage}
            onStop={stopCall}
            onShowMessage={() => {
              setShowMessage(true);
            }}
          />
          <Message
            showMessage={showMessage}
            onHideMessage={() => {
              setShowMessage(false);
            }}
          />
        </>
      ) : (
        <Welcome onStart={startCall} />
      )}
    </div>
  );
}

export default AICall;
