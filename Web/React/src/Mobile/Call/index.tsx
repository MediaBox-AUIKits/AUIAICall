import { AICallRunConfig } from '@/interface.ts';
import { useEffect, useMemo } from 'react';
import { AICallAgentType, AICallChatSyncConfig, AICallTemplateConfig } from 'aliyun-auikit-aicall';
import AUIAICallStandardController from '@/controller/call/AUIAICallStandardController';
import AUIAICallProxyController from '@/controller/call/AUIAICallProxyController.ts';
import './index.less';
import useCallStore from './store';
import { Toast } from 'antd-mobile';
import ControllerContext from './ControlerContext';
import Stage from './Stage';
import { isAndroidWeChatBrowser } from '@/common/utils';
import { useTranslation } from '@/common/i18nContext';

export interface CallProps {
  mode?: string;
  agentType: AICallAgentType;
  userId?: string;
  userToken?: string;
  autoCall?: boolean;
  rc: AICallRunConfig;
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
    dumpAudioData?: boolean;
  };
  children?: React.ReactNode;
}

function Call({
  mode,
  userId,
  userToken,
  agentId,
  autoCall,
  shareToken,
  fromShare,
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

    if (rtcEngineConfig) _controller.config.rtcEngineConfig = rtcEngineConfig;
    if (region) _controller.config.region = region;
    if (userData) {
      _controller.config.userData = userData;
    }
    if (templateConfig) {
      _controller.config.templateConfig = templateConfig;
    }

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

    return _controller;
  }, [
    t,
    userId,
    userToken,
    shareToken,
    fromShare,
    region,
    agentId,
    userData,
    templateConfig,
    agentType,
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
  }, []);

  return (
    <ControllerContext.Provider value={controller}>
      <Stage
        // 微信安卓端自动播放会失败，分享场景需要手动点击通话
        // Wechat Android will autoplay failed, need click call manually when share
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
