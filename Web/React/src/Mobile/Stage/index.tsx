import { useContext, useEffect, useRef } from 'react';
import ControllerContext from '@/common/ControlerContext';
import Footer from './Footer';
import Header from './Header';
import Subtitle from './Subtitle';
import Tip from './Tip';

import Voice from './Voice';
import Avatar from './Avatar';
import Vision from './Vision';

import './index.less';
import useCallStore from '@/common/store';
import { debounce, getRootElement } from '@/common/utils';
import ARTCAICallEngine, { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';
import i18n, { getErrorMessage } from '@/common/i18n';
import { Dialog, Toast } from 'antd-mobile';
import Connecting from './Connecting';

interface StageProps {
  autoCall?: boolean;
  agentType: AICallAgentType;
  onStateChange?: (callState: AICallState) => void;
  onExit: () => void;
  onAuthFail: () => void;
  limitSecond?: number;
}

function Stage({ agentType, onStateChange, onExit, onAuthFail, limitSecond, autoCall = false }: StageProps) {
  const controller = useContext(ControllerContext);
  const callState = useCallStore((state) => state.callState);
  const cameraMuted = useCallStore((state) => state.cameraMuted);

  const countdownRef = useRef(0);
  const startTimeRef = useRef(0);

  // 切换 controller 后重置状态
  useEffect(() => {
    if (!controller) return;
    controller.config.agentType = agentType;

    useCallStore.setState({
      agentType,
    });

    if (autoCall) {
      startCall();
    }

    return () => {
      controller?.handup();
      useCallStore.getState().reset();
      if (countdownRef.current) {
        window.clearInterval(countdownRef.current);
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    onStateChange?.(callState);
  }, [onStateChange, callState]);

  const interruptSpeaking = debounce(() => {
    controller?.interruptSpeaking();
  }, 100);

  // 开始通话
  const startCall = async () => {
    if (!controller) return;

    const supportedResult = await ARTCAICallEngine.isSupported();
    if (!supportedResult.support) {
      Dialog.show({
        closeOnMaskClick: true,
        content: (
          <div style={{ textAlign: 'center' }}>
            {window.isSecureContext === false ? (
              <>
                由于浏览器安全限制，
                <br />
                您需要通过HTTPS访问页面。
              </>
            ) : (
              <>
                当前浏览器不支持WebRTC，
                <br />
                建议您使用钉钉或微信打开
              </>
            )}
          </div>
        ),
        actions: [],
      });
      return;
    }

    // 保证事件只监听一次
    controller.removeAllListeners();
    controller.on('AICallStateChanged', async (newState) => {
      if (newState === AICallState.Error) {
        await controller?.handup();
        useCallStore.setState({
          callState: AICallState.Error,
          callErrorMessage: getErrorMessage(controller.errorCode),
        });
      } else {
        useCallStore.setState({
          callState: newState,
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

    controller.on('AICallAgentEmotionNotify', (emotion, sentenceId) => {
      console.log(`智能体情绪：${emotion}, 语句：${sentenceId}`);
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
      Toast.show({ content: i18n['login.tokenExpired'], getContainer: () => getRootElement() });
      onAuthFail?.();
    });

    controller.on('AICallBegin', () => {
      if (countdownRef.current) {
        window.clearInterval(countdownRef.current);
      }
      if (controller.config.agentType === AICallAgentType.AvatarAgent && limitSecond && limitSecond > 0) {
        startTimeRef.current = Date.now();
        countdownRef.current = window.setInterval(() => {
          const delta = Date.now() - startTimeRef.current;
          if (delta > limitSecond * 1000) {
            Toast.show({
              content: i18n['avatar.timeLimit'],
              getContainer: () => getRootElement(),
            });
            stopCall();
            if (countdownRef.current) {
              window.clearInterval(countdownRef.current);
            }
          }
        }, 5000);
      }
    });

    controller.on('AICallAgentWillLeave', (reason) => {
      let toast = '通话已经结束';
      if (reason == 2001) {
        toast = '由于你长时间未进行通话，该通话已经结束';
      } else if (reason == 2002) {
        toast = '该通话已经结束';
      }
      Toast.show({
        content: toast,
        getContainer: () => getRootElement(),
      });
    });

    controller.on('AICallReceivedAgentCustomMessage', (data) => {
      Toast.show({
        content: '收到智能体自定义消息：' + JSON.stringify(data),
        getContainer: () => getRootElement(),
      });
    });

    controller.on('AICallHumanTakeoverWillStart', () => {
      Toast.show({
        content: i18n['humanTakeover.willStart'],
        getContainer: () => getRootElement(),
      });
    });
    controller.on('AICallHumanTakeoverConnected', () => {
      Toast.show({
        content: i18n['humanTakeover.connected'],
        getContainer: () => getRootElement(),
      });
    });

    const currentTemplateConfig = controller.config.templateConfig;
    useCallStore.setState({
      enablePushToTalk: currentTemplateConfig.enablePushToTalk,
      enableVoiceInterrupt: currentTemplateConfig.enableVoiceInterrupt,
      voiceId: currentTemplateConfig.agentVoiceId || '',
    });

    try {
      await controller.start();
      if (controller.config.templateConfig?.agentVoiceId) {
        useCallStore.setState({
          voiceId: controller.config.templateConfig.agentVoiceId,
        });
      }
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      useCallStore.setState({
        callState: AICallState.Error,
        callErrorMessage: getErrorMessage(controller.errorCode),
      });
    }
  };

  const stopCall = async () => {
    controller?.handup();
    useCallStore.getState().reset(!!controller?.shareConfig);
    onExit();
  };

  // 已连接且是数字人或者有摄像头
  const hasVideo =
    callState === AICallState.Connected &&
    (agentType === AICallAgentType.AvatarAgent || (agentType === AICallAgentType.VisionAgent && !cameraMuted));

  let CharacterComponent = Voice;
  if (agentType === AICallAgentType.AvatarAgent) {
    CharacterComponent = Avatar;
  } else if (agentType === AICallAgentType.VisionAgent) {
    CharacterComponent = Vision;
  }

  return (
    <div className='stage'>
      <Header />
      <div className={`stage-bd  ${hasVideo ? 'has-video' : ''}`} onClick={interruptSpeaking}>
        <Subtitle />
        {callState === AICallState.Connected ? <CharacterComponent /> : <Connecting />}
        {callState === AICallState.Connected && <Tip />}
        <Footer onStop={stopCall} onCall={startCall} />
      </div>
      {callState === AICallState.Error && (
        <Dialog
          visible
          closeOnMaskClick
          getContainer={() => getRootElement()}
          onClose={() => {
            useCallStore.setState({
              callState: AICallState.None,
            });
          }}
          content={<div className='stage-error-message'>{useCallStore.getState().callErrorMessage}</div>}
        />
      )}
    </div>
  );
}

export default Stage;
