import AICallEngine from '../aiCall/engine';
import { AICallState, AICallSubtitleData, AICallType } from '../aiCall/type';
import { AICallAgentInfo } from '../api/type';
import { getRtcAuthToken, startAIAgent, stopAIAgent } from '../api/service';

import Call from './Call';
import Message from './Message';
import useCallStore from './store';

import './index.less';
import { useEffect, useMemo, useRef, useState } from 'react';
import Welcome from './Welcome';
import { message } from 'antd';
import { debounce } from '../utils';

function Voice() {
  const engineRef = useRef<AICallEngine>();
  const callState = useCallStore((state) => state.callState);
  const [showMessage, setShowMessage] = useState(true);
  const [messageApi, contextHolder] = message.useMessage();

  // Tab 键打断
  const onKeyDown = useMemo(() => {
    // 不把 debounce 放到 onKeyDown 是因为需要阻止 Tab 键的默认行为
    const interruptSpeaking = debounce(() => {
      engineRef.current?.interruptSpeaking();
    }, 100);
    return (e: KeyboardEvent) => {
      if (e.key === 'Tab') {
        e.stopImmediatePropagation();
        e.preventDefault();
        e.stopPropagation();
        interruptSpeaking();
      }
    };
  }, []);

  const onRequestToken = () => {
    const channelId = useCallStore.getState().agentInfo?.channel_id;
    const userId = useCallStore.getState().agentInfo?.ai_agent_user_id;
    if (!channelId || !userId) {
      return;
    }

    getRtcAuthToken(channelId, userId).then((token) => {
      engineRef.current?.updateToken(token);
    });
  };

  useEffect(() => {
    document.addEventListener('keydown', onKeyDown, true);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
      engineRef.current?.removeAllListeners();
      engineRef.current?.handup();
    };
  }, [onKeyDown]);

  // 开始通话
  const startCall = async () => {
    useCallStore.setState({
      callState: AICallState.Connecting,
    });

    try {
      const microphoneList = await AICallEngine.getMicrophoneList();
      if (microphoneList?.length === 0) {
        throw new Error('no microphone');
      }
    } catch (error) {
      console.log('get microphone list fail', error);
      useCallStore.setState({
        callState: AICallState.Error,
        callErrorMessage: '无法获取到麦克风，可能是未授权或未找到麦克风',
      });
      throw error;
    }

    let instanceInfo: AICallAgentInfo | undefined;
    try {
      // 此处的 userId 应该从 AppServer 获取
      instanceInfo = (await startAIAgent('123', {
        VoiceChat: {
          VoiceId: useCallStore.getState().voiceId,
          EnableVoiceInterrupt: useCallStore.getState().enableVoiceInterrupt,
        },
      })) as AICallAgentInfo;
      if (!instanceInfo) {
        throw new Error();
      }
    } catch (error) {
      console.log('start call fail', error);
      useCallStore.setState({ callState: AICallState.Error, callErrorMessage: '无法启动会话，当前服务出问题了' });
      useCallStore.setState({
        agentInfo: undefined,
      });
    }

    if (instanceInfo) {
      try {
        useCallStore.setState({
          agentInfo: instanceInfo,
        });
        const callEngine = new AICallEngine();

        // Agent 状态相关
        callEngine.on('agentStateChange', (newState) => {
          useCallStore.setState({
            agentState: newState,
          });
        });

        // 实时字幕相关呢
        callEngine.on('agentSubtitleNotify', (data: AICallSubtitleData) => {
          useCallStore.getState().setCurrentSubtitle({
            data,
            source: 'agent',
          });
        });
        callEngine.on('userSubtitleNotify', (data: AICallSubtitleData) => {
          useCallStore.getState().setCurrentSubtitle({
            data,
            source: 'user',
          });
        });

        // 各种原因导致的离会
        callEngine.on('bye', (code: number) => {
          useCallStore.setState({ callState: AICallState.Error, callErrorMessage: `您已离会，code: ${code}` });
        });

        callEngine.on('authInfoWillExpire', onRequestToken);
        callEngine.on('authInfoExpired', onRequestToken);

        // 本地说话状态
        callEngine.on('speakingStatusChanged', (isSpeaking) => {
          useCallStore.setState({
            isSpeaking,
          });
        });
        engineRef.current = callEngine;

        await callEngine.call(
          instanceInfo.ai_agent_user_id,
          instanceInfo.rtc_auth_token,
          AICallType.AudioOnly,
          instanceInfo
        );
        useCallStore.setState({ callState: AICallState.Connected });
      } catch (error) {
        console.log('start call fail', error);
        useCallStore.setState({ callState: AICallState.Error, callErrorMessage: '无法启动会话，启动通话失败' });
        useCallStore.setState({
          agentInfo: undefined,
        });
      }
    }
  };

  const toggleMicrophoneMuted = () => {
    if (!engineRef.current || !engineRef.current.isOnCall) return;
    const to = !useCallStore.getState().microphoneMuted;
    engineRef.current?.mute(to);
    messageApi.success(to ? '麦克风已关闭' : '麦克风已开启');
    useCallStore.setState({
      microphoneMuted: to,
    });
  };

  const stopCall = async () => {
    useCallStore.getState().reset();
    const instanceId = useCallStore.getState().agentInfo?.ai_agent_instance_id;
    if (instanceId) {
      stopAIAgent(instanceId);
    }
    engineRef.current?.removeAllListeners();
    engineRef.current?.handup();
  };

  return (
    <div className='voice'>
      {contextHolder}
      {callState === AICallState.Connected ? (
        <>
          <Call onStop={stopCall} toggleMicrophoneMuted={toggleMicrophoneMuted} />
          {showMessage && (
            <Message
              onHideMessage={() => {
                setShowMessage(false);
              }}
            />
          )}
        </>
      ) : (
        <Welcome onStart={startCall} />
      )}
    </div>
  );
}

export default Voice;
