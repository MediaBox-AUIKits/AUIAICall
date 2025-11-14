import { AICallAgentConfig, AICallAgentType, AICallChatSyncConfig, AICallTemplateConfig } from 'aliyun-auikit-aicall';
import { Toast } from 'antd-mobile';
import { useEffect, useMemo } from 'react';

import { useTranslation } from '@/common/i18nContext';
import AUIAICallProxyController from '@/controller/call/AUIAICallProxyController.ts';
import AUIAICallStandardController from '@/controller/call/AUIAICallStandardController';
import { AICallRunConfig } from '@/interface.ts';

import Layout from '../components/Layout';
import ControllerContext from './ControlerContext';
import Stage from './Stage';
import useCallStore from './store';

export interface CallProps {
  mode?: string;
  rc: AICallRunConfig;
  userId?: string;
  userToken?: string;
  shareToken?: string;
  autoCall?: boolean;
  appServer?: string;

  agentType: AICallAgentType;
  agentId?: string;
  region?: string;
  userData?: string;
  agentConfig?: AICallAgentConfig;

  isShare?: boolean;
  onExit?: () => void;
  onAuthFail?: () => void;
  chatSyncConfig?: AICallChatSyncConfig;
  rtcEngineConfig?: {
    environment?: 'PRE' | 'PROD';
    useAudioPlugin?: boolean;
    dumpAudioData?: boolean;
  };
  children?: React.ReactNode;
}

function Call({
  mode,
  userId,
  userToken,
  autoCall,

  agentId,
  shareToken,
  region,
  agentType,
  userData,
  agentConfig,
  onExit,
  onAuthFail,
  chatSyncConfig,
  rtcEngineConfig,
  children,
}: CallProps) {
  const { t } = useTranslation();

  const controller = useMemo(() => {
    if (!userId || !userToken) return null;
    useCallStore.setState({
      agentType,
    });

    const _controller =
      mode === 'standard' || shareToken
        ? new AUIAICallStandardController(userId, userToken)
        : new AUIAICallProxyController(userId, userToken);

    if (rtcEngineConfig) _controller.engineConfig.rtcEngineConfig = rtcEngineConfig;

    _controller.config = {
      agentType,
      region: region || 'cn-shanghai',
      userData,
      agentConfig,
      agentId: agentId || '',
      userId,
      userJoinToken: '',
      chatSyncConfig,
    };

    if (shareToken) {
      _controller.shareConfig = shareToken;

      if (!_controller.shareConfig) {
        Toast.show({
          content: t('share.tokenInvalid'),
          position: 'bottom',
        });
        return null;
      }
      if (_controller.shareConfig.region) {
        _controller.config.region = _controller.shareConfig?.region;
      }
      if (_controller.shareConfig.templateConfig) {
        _controller.config.templateConfig = AICallTemplateConfig.fromJsonString(
          _controller.shareConfig?.agentType || AICallAgentType.VoiceAgent,
          _controller.shareConfig?.templateConfig
        );
      }
      if (_controller.shareConfig.userData) {
        _controller.config.userData = _controller.shareConfig?.userData;
      }
    }

    return _controller;
  }, [
    t,
    mode,
    userId,
    userToken,
    shareToken,
    region,
    agentId,
    agentType,
    userData,
    agentConfig,
    chatSyncConfig,
    rtcEngineConfig,
  ]);

  // 关闭页面时尝试挂断来停止智能体
  // try to handup when close page to release agent
  useEffect(() => {
    const beforeOnload = () => {
      controller?.handup();
    };
    window.addEventListener('beforeunload', beforeOnload);
    return () => {
      window.removeEventListener('beforeunload', beforeOnload);
    };
  }, [controller]);

  return (
    <ControllerContext.Provider value={controller}>
      <Layout showText themeBtn={false} settingBtn={false} onExit={onExit}>
        <Stage
          autoCall={autoCall}
          onAuthFail={() => {
            onAuthFail?.();
          }}
          onExit={() => {
            onExit?.();
          }}
        />
        {children}
      </Layout>
    </ControllerContext.Provider>
  );
}

export default Call;
