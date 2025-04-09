import { useEffect, useMemo } from 'react';
import { AICallAgentType, AICallChatSyncConfig, AICallTemplateConfig } from 'aliyun-auikit-aicall';
import AUIAICallStandardController from '@/controller/call/AUIAICallStandardController';

import './index.less';
import useCallStore from './store';
import { Toast } from 'antd-mobile';
import ControllerContext from './ControlerContext';
import Stage from './Stage';
import { isAndroidWeChatBrowser } from '@/common/utils';

export interface CallProps {
  agentType: AICallAgentType;
  userId?: string;
  userToken?: string;
  autoCall?: boolean;

  shareToken?: string;
  fromShare?: boolean;

  agentId?: string;
  appServer?: string;
  region?: string;
  userData?: string;
  templateConfig?: AICallTemplateConfig;
  isShare?: boolean;
  onExit?: () => void;
  onAuthFail?: () => void;
  chatSyncConfig?: AICallChatSyncConfig;
  rtcEngineConfig?: {
    environment?: 'PRE' | 'PROD';
    useAudioPlugin?: boolean;
    dumpAudio?: boolean;
  };
  children?: React.ReactNode;
}

function Call({
  userId,
  userToken,
  agentId,
  autoCall,
  shareToken,
  fromShare,
  appServer,
  region,
  agentType,
  userData,
  templateConfig,
  onExit,
  onAuthFail,
  chatSyncConfig,
  rtcEngineConfig,
  children,
}: CallProps) {
  const controller = useMemo(() => {
    if (!userId || !userToken) return null;
    useCallStore.setState({
      agentType,
    });
    const _controller = new AUIAICallStandardController(userId, userToken);
    if (appServer) _controller.appServer = appServer;

    if (shareToken) {
      _controller.shareConfig = shareToken;

      if (!_controller.shareConfig) {
        Toast.show({
          content: '分享链接有误',
          position: 'bottom',
        });
        return null;
      }
      if (_controller.shareConfig.templateConfig) {
        _controller.config.templateConfig = AICallTemplateConfig.fromJsonString(
          _controller.shareConfig?.agentType || AICallAgentType.VoiceAgent,
          _controller.shareConfig?.templateConfig
        );
      }
      _controller.config.fromShare = true;
    } else {
      _controller.config.fromShare = !!fromShare;
      if (agentId) {
        _controller.config.agentId = agentId;
      }
      if (chatSyncConfig) {
        _controller.config.chatSyncConfig = chatSyncConfig;
      }
    }

    if (appServer) _controller.appServer = appServer;
    if (rtcEngineConfig) _controller.config.rtcEngineConfig = rtcEngineConfig;
    if (region) _controller.config.region = region;
    if (userData) {
      _controller.config.userData = userData;
    }
    if (templateConfig) {
      _controller.config.templateConfig = templateConfig;
    }

    return _controller;
  }, [
    userId,
    userToken,
    shareToken,
    fromShare,
    appServer,
    region,
    agentId,
    userData,
    templateConfig,
    agentType,
    chatSyncConfig,
  ]);

  // 关闭页面时尝试挂断，减少出现 Agent 需要超时才能退出的 Case
  useEffect(() => {
    const beforeOnload = () => {
      controller?.handup();
    };
    window.addEventListener('beforeunload', beforeOnload);
    return () => {
      window.removeEventListener('beforeunload', beforeOnload);
    };
  }, []);

  return (
    <ControllerContext.Provider value={controller}>
      <Stage
        // 微信安卓端自动播放会失败，分享场景需要手动点击通话
        agentType={agentType}
        autoCall={
          autoCall ||
          (new URLSearchParams(location.search).get('nocall') ||
          (controller?.config.fromShare && isAndroidWeChatBrowser())
            ? false
            : true)
        }
        onAuthFail={() => {
          onAuthFail?.();
        }}
        onExit={() => {
          onExit?.();
        }}
        
      />
      {children}
    </ControllerContext.Provider>
  );
}

export default Call;
