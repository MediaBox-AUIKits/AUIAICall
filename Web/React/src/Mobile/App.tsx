import { useMemo } from 'react';
import ControllerContext from '@/common/ControlerContext';
import AUIAICallStandardController from '@/controller/AUIAICallStandardController';
import Stage from './Stage';
import Welcome from './Welcome';

import useCallStore from '@/common/store';

import './App.css';
import { Toast } from 'antd-mobile';

interface AppProps {
  userId?: string;
  userToken?: string;
  shareToken?: string;
  appServer?: string;
  onAuthFail?: () => void;
}

function App({ userId = 'YourUserId', userToken = 'YourToken', shareToken, appServer, onAuthFail }: AppProps) {
  const agentType = useCallStore((state) => state.agentType);

  const controller = useMemo(() => {
    if (!userId) return null;
    const _controller = new AUIAICallStandardController(userId, userToken);

    if (appServer) {
      _controller.appServer = appServer;
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

      useCallStore.setState({
        agentType: _controller.shareConfig.agentType,
      });
    }

    return _controller;
  }, [userId, userToken, shareToken, appServer]);

  if (agentType === undefined)
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
        agentType={agentType}
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
