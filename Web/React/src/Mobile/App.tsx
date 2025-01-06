import { useEffect, useMemo } from 'react';
import ControllerContext from '@/common/ControlerContext';
import AUIAICallStandardController from '@/controller/AUIAICallStandardController';
import Stage from './Stage';
import Welcome from './Welcome';
import { AICallAgentType, AICallTemplateConfig } from 'aliyun-auikit-aicall';

import useCallStore from '@/common/store';

import './App.css';
import { Toast } from 'antd-mobile';

Toast.config({
  position: 'bottom',
});

interface AppProps {
  userId?: string;
  userToken?: string;
  shareToken?: string;
  appServer?: string;
  onAuthFail?: () => void;
  agentType?: AICallAgentType;
  userData?: string;
  templateConfig?: AICallTemplateConfig;
}

function App({
  userId = 'YourUserId',
  userToken = 'YourToken',
  shareToken,
  appServer,
  onAuthFail,
  agentType,
  userData,
  templateConfig,
}: AppProps) {
  const storeAgentType = useCallStore((state) => state.agentType);

  useEffect(() => {
    if (agentType !== undefined) {
      useCallStore.setState({
        agentType,
      });
    }
  }, [agentType]);

  const controller = useMemo(() => {
    if (!userId) return null;
    const _controller = new AUIAICallStandardController(userId, userToken);
    if (templateConfig) {
      _controller.config.templateConfig = templateConfig;
    }

    if (appServer) {
      _controller.appServer = appServer;
    }
    if (userData) {
      _controller.config.userData = userData;
    }

    const urlParams = new URLSearchParams(location.search);
    const _shareToken = shareToken || urlParams.get('token');
    if (_shareToken) {
      _controller.shareConfig = _shareToken;

      if (!_controller.shareConfig) {
        Toast.show({
          content: '分享链接有误',
          position: 'bottom',
        });
        return null;
      }

      if (_controller.shareConfig.templateConfig) {
        _controller.config.templateConfig = AICallTemplateConfig.fromJsonString(
          _controller.shareConfig.agentType || AICallAgentType.VoiceAgent,
          _controller.shareConfig.templateConfig
        );
      }

      useCallStore.setState({
        agentType: _controller.shareConfig.agentType,
      });
    }

    return _controller;
  }, [userId, userToken, shareToken, appServer, userData, templateConfig]);

  const resultAgentType = useMemo(() => {
    if (agentType !== undefined) {
      return agentType;
    }
    return storeAgentType;
  }, [agentType, storeAgentType]);

  if (resultAgentType === undefined)
    return (
      <Welcome
        onAgentTypeSelected={(type) => {
          useCallStore.setState({
            agentType: type,
          });
        }}
      />
    );

  return (
    <ControllerContext.Provider value={controller}>
      <Stage
        agentType={resultAgentType}
        onExit={() => {}}
        autoCall
        onAuthFail={() => {
          onAuthFail?.();
        }}
      />
    </ControllerContext.Provider>
  );
}

export default App;
