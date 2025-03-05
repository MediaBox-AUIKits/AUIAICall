import { useEffect, useState } from 'react';
import Welcome from './Welcome';
import { AICallAgentType, AICallTemplateConfig, AIChatAgentType } from 'aliyun-auikit-aicall';

import './App.css';
import { Toast } from 'antd-mobile';
import Call from './Call';
import Chat from './Chat';

Toast.config({
  position: 'bottom',
});

const defaultCallAgentIdMap = {
  [AICallAgentType.VoiceAgent]: '',
  [AICallAgentType.AvatarAgent]: '',
  [AICallAgentType.VisionAgent]: '',
};

const defaultChatAgentId = '你的消息通话智能体的Id';

interface AppProps {
  userId?: string;
  userToken?: string;

  shareToken?: string;
  appServer?: string;
  region?: string;

  agentType?: AICallAgentType | AIChatAgentType;
  agentId?: string;

  userData?: string;
  templateConfig?: AICallTemplateConfig;

  onAuthFail?: () => void;
}

function App({
  userId = 'YourUserId',
  userToken = 'YourToken',
  shareToken,
  appServer,
  region,
  onAuthFail,
  agentType,
  agentId,
  userData,
  templateConfig,
}: AppProps) {
  const [stateAgentType, setStateAgentType] = useState<AICallAgentType | AIChatAgentType | undefined>(agentType);

  useEffect(() => {
    const preventContextMenu = function (e: Event) {
      e.preventDefault();
    };
    // 禁用右键菜单
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
          userId={userId}
          userToken={userToken}
          agentId={agentId || defaultChatAgentId}
          onExit={() => {
            setStateAgentType(undefined);
          }}
        />
      ) : (
        <Call
          userId={userId}
          userToken={userToken}
          agentType={stateAgentType}
          shareToken={shareToken}
          agentId={agentId || defaultCallAgentIdMap[stateAgentType]}
          appServer={appServer}
          region={region}
          userData={userData}
          templateConfig={templateConfig}
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
