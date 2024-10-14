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

  const countdownRef = useRef(0);
  const startTimeRef = useRef(0);

  // 切换 controller 后重置状态
  useEffect(() => {
    controller?.handup();
    useCallStore.getState().reset();
  }, [controller]);

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
      }
    };
  }, [controller]);

  useEffect(() => {
    document.addEventListener('keydown', onKeyDown, true);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
      controller?.removeAllListeners();
      controller?.handup();
    };
  }, [controller, onKeyDown]);

  // 开始通话
  const startCall = async (agentType: AICallAgentType) => {
    if (!controller) return;
    controller.config.agentType = agentType;
    useCallStore.setState({
      agentType,
    });

    controller.on('AICallStateChanged', (newState) => {
      useCallStore.setState({
        callState: newState,
      });
      if (newState === AICallState.Error) {
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

  const toggleMicrophoneMuted = () => {
    const to = !useCallStore.getState().microphoneMuted;
    controller?.switchMicrophone(to);
    messageApi.success(to ? '麦克风已关闭' : '麦克风已开启');
    useCallStore.setState({
      microphoneMuted: to,
    });
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
            toggleMicrophoneMuted={toggleMicrophoneMuted}
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
