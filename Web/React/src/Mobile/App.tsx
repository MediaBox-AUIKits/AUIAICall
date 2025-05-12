import { useEffect, useState } from 'react';
import Welcome from './Welcome';
import { AICallAgentType, AICallTemplateConfig, AIChatAgentType, AIChatTemplateConfig } from 'aliyun-auikit-aicall';

import './App.css';
import { Toast } from 'antd-mobile';
import Call from './Call';
import Chat from './Chat';
import runUserConfig from '@/runConfig.ts';
import { JSONObject } from '@/service/interface.ts';
import { getCallAgentId, getRuntimeConfig } from '@/interface.ts';
import service from '@/service/standard';

Toast.config({
  position: 'bottom',
});

interface AppProps {
  userId?: string;
  userToken?: string;

  shareToken?: string;
  appServer?: string;
  region?: string;

  agentType?: AICallAgentType | AIChatAgentType;
  agentId?: string;

  userData?: string | JSONObject;
  templateConfig?: AICallTemplateConfig | AIChatTemplateConfig;

  onAuthFail?: () => void;
}

function App(props: AppProps) {
  const runConfig = getRuntimeConfig(runUserConfig);
  const {
    userId = 'YourUserId',
    userToken = 'YourToken',
    shareToken,
    appServer = runConfig.appServer,
    region = runConfig.region,
    onAuthFail,
    agentType = runConfig.agentType,
    agentId,
    userData,
    templateConfig,
  } = props;
  const [stateAgentType, setStateAgentType] = useState<AICallAgentType | AIChatAgentType | undefined>(agentType);

  useEffect(() => {
    if (runConfig.appServer) {
      service.setAppServer(runConfig.appServer);
    }

    const preventContextMenu = function (e: Event) {
      e.preventDefault();
    };
    // 禁用右键菜单
    // disable context menu
    document.addEventListener('contextmenu', preventContextMenu);
    return () => {
      document.removeEventListener('contextmenu', preventContextMenu);
    };
  }, []);

  if (stateAgentType === undefined)
    return (
      <Welcome
        onAgentTypeSelected={(type) => {
          setStateAgentType(type);
        }}
      />
    );

  return (
    <>
      {stateAgentType === AIChatAgentType.MessageChat ? (
        <Chat
          rc={runConfig}
          userId={userId}
          userToken={userToken}
          agentId={agentId || runConfig.chatAgentId}
          appServer={appServer}
          templateConfig={
            templateConfig instanceof AIChatTemplateConfig ? templateConfig : runConfig.chatTemplateConfig
          }
          userData={(userData as JSONObject) || runConfig.chatUserData}
          onExit={() => {
            setStateAgentType(undefined);
          }}
        />
      ) : (
        <Call
          rc={runConfig}
          userId={userId}
          userToken={userToken}
          agentType={stateAgentType}
          shareToken={shareToken}
          agentId={agentId || getCallAgentId(runConfig, stateAgentType)}
          appServer={appServer}
          region={region}
          userData={typeof userData === 'object' ? JSON.stringify(userData) : userData || runConfig.callUserData}
          templateConfig={
            templateConfig instanceof AICallTemplateConfig ? templateConfig : runConfig.callTemplateConfig
          }
          onExit={() => {
            setStateAgentType(undefined);
          }}
          onAuthFail={() => {
            onAuthFail?.();
          }}
        />
      )}
    </>
  );
}

export default App;
