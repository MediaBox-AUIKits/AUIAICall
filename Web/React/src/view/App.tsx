import { AICallAgentConfig, AICallAgentType, AIChatAgentType, AIChatTemplateConfig } from 'aliyun-auikit-aicall';
import { Toast } from 'antd-mobile';
import { useEffect, useState } from 'react';

import { getCallAgentId, getRuntimeConfig } from '@/interface.ts';
import runUserConfig from '@/runConfig.ts';
import { JSONObject } from '@/service/interface.ts';
import service from '@/service/standard';

import Call from './Call';
import Chat from './Chat';
import PSTN, { AIPSTNType } from './PSTN';
import Welcome, { WelcomeTypeValue } from './Welcome';
import { VOICE_PRINT_CACHE_ENABLE, VOICE_PRINT_CACHE_PREFIX } from './Welcome/Config';

import './App.less';

Toast.config({
  position: 'bottom',
});

interface AppProps {
  mode?: 'standard' | 'proxy';
  userId?: string;
  userToken?: string;

  shareToken?: string;
  appServer?: string;
  region?: string;

  agentType?: AICallAgentType | AIChatAgentType;
  agentId?: string;

  userData?: string | JSONObject;
  agentConfig?: AICallAgentConfig;
  chatTemplateConfig?: AIChatTemplateConfig;

  onAuthFail?: () => void;
}

function App(props: AppProps) {
  const runConfig = getRuntimeConfig(runUserConfig);
  const {
    mode,
    userId = 'YourUserId',
    userToken = 'YourToken',
    shareToken,
    appServer = runConfig.appServer,
    region = runConfig.region,
    onAuthFail,
    agentType = runConfig.agentType,
    agentId,
    userData,
    agentConfig = runConfig.callAgentConfig,
    chatTemplateConfig,
  } = props;
  const [stateAgentType, setStateAgentType] = useState<WelcomeTypeValue | undefined>(agentType);

  useEffect(() => {
    if (appServer) {
      service.setAppServer(appServer);
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
  }, [appServer]);

  // 未选择智能体类型
  if (stateAgentType === undefined) {
    return (
      <Welcome
        userId={userId}
        region={region}
        showPstn={!!runConfig.pstnAgentId}
        onSelected={(type) => {
          setStateAgentType(type);
        }}
        onAuthFail={() => {
          onAuthFail?.();
        }}
      />
    );
  }

  // PSTN
  if (stateAgentType >= AIPSTNType.Outbound && stateAgentType <= AIPSTNType.Inbound) {
    return (
      <PSTN
        type={stateAgentType === AIPSTNType.Outbound ? 'Outbound' : 'Inbound'}
        userId={userId}
        agentId={agentId!}
        region={region!}
        onExit={() => {
          setStateAgentType(undefined);
        }}
        onAuthFail={() => {
          onAuthFail?.();
        }}
      />
    );
  }

  // ChatBot
  if (stateAgentType === AIChatAgentType.MessageChat) {
    return (
      <Chat
        rc={runConfig}
        userId={userId}
        userToken={userToken}
        shareToken={shareToken}
        agentId={agentId || runConfig.chatAgentId}
        appServer={appServer}
        region={region}
        templateConfig={chatTemplateConfig}
        userData={(userData as JSONObject) || runConfig.chatUserData}
        onExit={() => {
          setStateAgentType(undefined);
        }}
      />
    );
  }

  const voiceprintId = localStorage?.getItem(`${VOICE_PRINT_CACHE_PREFIX}${props.userId}`);
  if (voiceprintId && agentConfig) {
    if (localStorage?.getItem(VOICE_PRINT_CACHE_ENABLE) !== 'false') {
      agentConfig.voiceprintConfig.useVoiceprint = true;
    }
    agentConfig.voiceprintConfig.voiceprintId = voiceprintId;
  }

  return (
    <Call
      mode={mode}
      rc={runConfig}
      autoCall
      userId={userId}
      userToken={userToken}
      agentType={stateAgentType as AICallAgentType}
      shareToken={shareToken}
      agentId={agentId || getCallAgentId(runConfig, stateAgentType as AICallAgentType)}
      appServer={appServer}
      region={region}
      userData={typeof userData === 'object' ? JSON.stringify(userData) : userData || runConfig.callUserData}
      agentConfig={agentConfig}
      onExit={() => {
        if (!shareToken) {
          setStateAgentType(undefined);
        }
      }}
      onAuthFail={() => {
        onAuthFail?.();
      }}
    />
  );
}

export default App;
