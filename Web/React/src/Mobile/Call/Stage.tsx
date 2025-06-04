import { useContext, useEffect, useRef } from 'react';
import ControllerContext from '@/Mobile/Call/ControlerContext';
import Footer from './Footer';
import Header from './Header';
// import Subtitle from './Subtitle';
import Tip from './Tip';

import Voice from './Voice';
import Avatar from './Avatar';
import Vision from './Vision';

import useCallStore from '@/Mobile/Call/store';
import { debounce, getRootElement } from '@/common/utils';
import ARTCAICallEngine, {
  AICallAgentError,
  AICallAgentType,
  AICallState,
  AICallVoiceprintResult,
} from 'aliyun-auikit-aicall';
import { Dialog, Toast } from 'antd-mobile';
import Connecting from './Connecting';
import { useTranslation } from '@/common/i18nContext';
import Video from './Video';

interface StageProps {
  autoCall?: boolean;
  onStateChange?: (callState: AICallState) => void;
  onExit: () => void;
  onAuthFail: () => void;
  limitSecond?: number;
}

function Stage({ onStateChange, onExit, onAuthFail, limitSecond, autoCall = false }: StageProps) {
  const controller = useContext(ControllerContext);
  const { t, e } = useTranslation();
  const callState = useCallStore((state) => state.callState);
  const cameraMuted = useCallStore((state) => state.cameraMuted);

  const resumeDialogVisibleRef = useRef(false);

  const countdownRef = useRef(0);
  const startTimeRef = useRef(0);

  // 切换 controller 后重置状态
  // if controller changed, reset state
  useEffect(() => {
    if (!controller) return;

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

  const startCall = async () => {
    if (!controller) return;

    const supportedResult = await ARTCAICallEngine.isSupported();
    if (!supportedResult.support) {
      Dialog.show({
        content: t('system.notSupported'),
        actions: [],
      });
      return;
    }

    controller.on('AICallStateChanged', (newState) => {
      useCallStore.setState({
        callState: newState,
      });
      if (newState === AICallState.Error) {
        controller?.handup();
        useCallStore.setState({
          callErrorMessage: e(controller.errorCode),
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
        // local user speaking
        useCallStore.setState({
          isSpeaking: volume > 30,
        });
      }
    });

    controller.on('AICallAgentEmotionNotify', (emotion, sentenceId) => {
      console.log(`Agent emotion notify: ${emotion}, sentenceId: ${sentenceId}`);
    });

    controller.on('AICallAgentSubtitleNotify', (data) => {
      useCallStore.getState().updateSubtitle({
        data,
        source: 'agent',
      });
    });
    controller.on('AICallUserSubtitleNotify', (data, voiceprintResult) => {
      useCallStore.getState().updateSubtitle({
        data,
        source: 'user',
        voiceprintResult,
      });
      if (voiceprintResult === AICallVoiceprintResult.UndetectedSpeaker) {
        Toast.show({
          content: t('agent.voiceprintIgnored'),
          getContainer: () => getRootElement(),
        });
      } else if (voiceprintResult === AICallVoiceprintResult.UndetectedSpeakerWithAIVad) {
        Toast.show({
          content: t('agent.aivadIgnored'),
          getContainer: () => getRootElement(),
        });
      }

      console.log(`voiceprintResult to ${voiceprintResult}`);
    });

    controller.on('AICallUserTokenExpired', () => {
      Toast.show({ content: t('login.tokenExpired'), getContainer: () => getRootElement() });
      onAuthFail?.();
    });

    controller.on('AICallBegin', (elapsedTime) => {
      console.log(`Connected Time: ${elapsedTime}ms`);
      if (countdownRef.current) {
        window.clearInterval(countdownRef.current);
      }
      if (
        (controller.agentType === AICallAgentType.AvatarAgent || controller.agentType === AICallAgentType.VideoAgent) &&
        limitSecond &&
        limitSecond > 0
      ) {
        startTimeRef.current = Date.now();
        countdownRef.current = window.setInterval(() => {
          const delta = Date.now() - startTimeRef.current;
          if (delta > limitSecond * 1000) {
            Toast.show({
              content: t('avatar.timeLimit'),
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
      let toast = t('agent.ended');
      if (reason == 2001) {
        toast = t('agent.endedByInactivity');
      } else if (reason == 2002) {
        toast = t('agent.endedByAgent');
      }
      Toast.show({
        content: toast,
        getContainer: () => getRootElement(),
      });
    });

    controller.on('AICallReceivedAgentCustomMessage', (data) => {
      Toast.show({
        content: t('agent.receivedCustomMessage', { msg: JSON.stringify(data) }),
        getContainer: () => getRootElement(),
      });
    });

    controller.on('AICallHumanTakeoverWillStart', () => {
      Toast.show({
        content: t('humanTakeover.willStart'),
        getContainer: () => getRootElement(),
      });
    });
    controller.on('AICallHumanTakeoverConnected', () => {
      Toast.show({
        content: t('humanTakeover.connected'),
        getContainer: () => getRootElement(),
      });
    });
    controller.on('AICallVisionCustomCaptureChanged', (enabled) => {
      console.log(t('agent.visionCustomCaptureState', { enabled: `${enabled}` }));
      if (enabled) {
        Toast.show({
          content: t('vision.customCapture.enabled'),
          getContainer: () => getRootElement(),
        });
      } else {
        Toast.show({
          content: t('vision.customCapture.disabled'),
          getContainer: () => getRootElement(),
        });
      }
    });
    controller.on('AICallSpeakingInterrupted', (reason) => {
      console.log(t('agent.interrupted', { reason: `${reason}` }));
    });
    controller.on('AICallAgentConfigLoaded', (config) => {
      if (config.AvatarUrl) {
        useCallStore.setState({
          voiceAvatarUrl: config.AvatarUrl as string,
        });
      }
      if (config.VoiceId) {
        useCallStore.setState({
          voiceId: config.VoiceId as string,
        });
      }
      if (config.VoiceIdList) {
        useCallStore.setState({
          agentVoiceIdList: config.VoiceIdList as string[],
        });
      }
    });
    controller.on('AICallAgentAutoPlayFailed', async () => {
      if (resumeDialogVisibleRef.current) return;
      resumeDialogVisibleRef.current = true;
      await Dialog.alert({
        closeOnMaskClick: true,
        getContainer: getRootElement,
        title: t('resume.title'),
        content: t('resume.content'),
        confirmText: t('resume.btn'),
      });

      resumeDialogVisibleRef.current = false;
    });

    const currentAgentConfig = controller.config.agentConfig;
    useCallStore.setState({
      enablePushToTalk: !!currentAgentConfig?.enablePushToTalk,
      enableVoiceInterrupt: !!currentAgentConfig?.interruptConfig.enableVoiceInterrupt,
      voiceId: currentAgentConfig?.ttsConfig.agentVoiceId,
    });

    try {
      await controller.start();
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      if ((error as AICallAgentError).name === 'ServiceAuthError') {
        onAuthFail?.();
      }

      useCallStore.setState({
        callState: AICallState.Error,
        callErrorMessage: e(controller.errorCode),
      });
    }
  };

  const stopCall = async () => {
    controller?.handup();
    useCallStore.getState().reset(!!controller?.shareConfig);
    onExit();
  };

  // 已连接且是数字人或者有摄像头
  // is avatar or vision agent or camera not muted
  const hasVideo =
    callState === AICallState.Connected &&
    (controller?.agentType === AICallAgentType.AvatarAgent ||
      controller?.agentType === AICallAgentType.VideoAgent ||
      (controller?.agentType === AICallAgentType.VisionAgent && !cameraMuted));

  let CharacterComponent = Voice;
  if (controller?.agentType === AICallAgentType.AvatarAgent) {
    CharacterComponent = Avatar;
  } else if (controller?.agentType === AICallAgentType.VisionAgent) {
    CharacterComponent = Vision;
  } else if (controller?.agentType === AICallAgentType.VideoAgent) {
    CharacterComponent = Video;
  }

  return (
    <div className='stage'>
      <Header />
      <div className={`stage-bd  ${hasVideo ? 'has-video' : ''}`} onClick={interruptSpeaking}>
        {/* <Subtitle /> */}
        {callState === AICallState.Connected ? <CharacterComponent /> : <Connecting />}
        {callState === AICallState.Connected && <Tip />}
        <Footer onStop={stopCall} onCall={startCall} />
      </div>
      {callState === AICallState.Error && (
        <Dialog
          visible
          getContainer={() => getRootElement()}
          onClose={() => {
            useCallStore.setState({
              callState: AICallState.None,
            });
          }}
          content={<div className='stage-error-message'>{useCallStore.getState().callErrorMessage}</div>}
          actions={[
            [
              {
                key: 'close',
                text: t('common.close'),
                onClick: () => {
                  useCallStore.setState({
                    callState: AICallState.None,
                  });
                },
              },
              {
                key: 'exit',
                text: t('common.exit'),
                onClick: stopCall,
              },
            ],
          ]}
        />
      )}
    </div>
  );
}

export default Stage;
