import { AICallAgentConfig, AICallAgentType, AIChatAgentType, AIChatTemplateConfig } from 'aliyun-auikit-aicall';
import { useEffect, useState } from 'react';
import Welcome from './Welcome';

import { useTranslation } from '@/common/i18nContext';
import { getCallAgentId, getRuntimeConfig } from '@/interface.ts';
import runUserConfig from '@/runConfig.ts';
import { JSONObject } from '@/service/interface.ts';
import service from '@/service/standard';
import { Toast } from 'antd-mobile';
import './App.css';
import Call from './Call';
import Chat from './Chat';
import PSTN from './PSTN';
import { VOICE_PRINT_CACHE_ENABLE, VOICE_PRINT_CACHE_PREFIX } from './Welcome/Config';

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
  const [callType, setCallType] = useState('call');
  const [stateAgentType, setStateAgentType] = useState<AICallAgentType | AIChatAgentType | undefined>(agentType);
  const [pstnType, setPstnType] = useState<string>('Outbound');

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

  if (callType === 'pstn' && pstnType) {
    return (
      <PSTN
        type={pstnType}
        userId={userId}
        agentId={agentId!}
        region={region!}
        onExit={() => {
          setPstnType('');
          setStateAgentType(undefined);
        }}
        onAuthFail={() => {
          onAuthFail?.();
        }}
      />
    );
  }

  if (stateAgentType === undefined)
    return (
      <Welcome
        userId={userId}
        region={region}
        initialType={callType}
        showPstn={!!runConfig.pstnAgentId}
        onTypeSelected={(type) => {
          setCallType(type);
        }}
        onAgentTypeSelected={(type) => {
          setStateAgentType(type);
        }}
        onPSTNTypeSelected={(type) => {
          setPstnType(type);
        }}
        onAuthFail={() => {
          onAuthFail?.();
        }}
      />
    );

  const voiceprintId = localStorage?.getItem(`${VOICE_PRINT_CACHE_PREFIX}${props.userId}`);
  if (voiceprintId && agentConfig) {
    if (localStorage?.getItem(VOICE_PRINT_CACHE_ENABLE) !== 'false') {
      agentConfig.voiceprintConfig.useVoiceprint = true;
    }
    agentConfig.voiceprintConfig.voiceprintId = voiceprintId;
  }

  return (
    <>
      {stateAgentType === AIChatAgentType.MessageChat ? (
        <Chat
          rc={runConfig}
          userId={userId}
          userToken={userToken}
          agentId={agentId || runConfig.chatAgentId}
          appServer={appServer}
          region={region}
          templateConfig={chatTemplateConfig}
          userData={(userData as JSONObject) || runConfig.chatUserData}
          onExit={() => {
            setStateAgentType(undefined);
          }}
        />
      ) : (
        <Call
          mode={mode}
          rc={runConfig}
          autoCall
          userId={userId}
          userToken={userToken}
          agentType={stateAgentType}
          shareToken={shareToken}
          agentId={agentId || getCallAgentId(runConfig, stateAgentType)}
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
      )}
    </>
  );
}

function AppWithHeader(props: AppProps) {
  const { t } = useTranslation();

  return (
    <>
      <div className='layout-header'>{t('welcome.title')}</div>
      <App {...props} />
    </>
  );
}

export default AppWithHeader;
