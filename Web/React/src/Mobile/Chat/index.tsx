import { SafeArea, Toast } from 'antd-mobile';
import {
  AICallAgentError,
  AICallErrorCode,
  AIChatAgentInfo,
  AIChatAgentShareConfig,
  AIChatAuthToken,
  AIChatEngine,
  AIChatError,
  AIChatMessagePlayState,
  AIChatUserInfo,
} from 'aliyun-auikit-aicall';
import ChatHeader from './Header';
import ChatMessages from './Messages';
import ChatFooter from './Footer';
import { useEffect, useState } from 'react';
import ChatEngineContext from './ChatEngineContext';
import useChatStore, { messageCachePrefix } from './store';
import standardService from '../../service/standard';

import './index.less';
import ChatState from './State';
import { getRootElement } from '@/common/utils';
import { getErrorMessage } from '@/common/i18n';

interface ChatProps {
  userId: string;
  userToken: string;
  agentId?: string;
  shareToken?: string;
  region?: string;
  onExit: () => void;
  onAuthFail?: () => void;
}

function Chat({ userId, userToken, agentId, shareToken, region, onExit, onAuthFail }: ChatProps) {
  const [chatEngine, setChatEngine] = useState<AIChatEngine | null>(null);

  useEffect(() => {
    let _agentId = agentId;
    let _region = region;
    let shareConfig: AIChatAgentShareConfig | undefined;
    if (shareToken) {
      shareConfig = AIChatEngine.parseShareAgentChat(shareToken);
      if (shareConfig) {
        _agentId = shareConfig.shareId;
        if (shareConfig.region) {
          _region = shareConfig.region;
        }
      } else {
        Toast.show({ content: '分享信息解析失败', getContainer: () => getRootElement() });
        return;
      }
    }

    if (!_agentId) {
      Toast.show({ content: '智能体Id不能为空', getContainer: () => getRootElement() });
      return;
    }

    const chatEngine = new AIChatEngine();
    chatEngine.on('engineStateChange', (state) => {
      useChatStore.setState({
        chatState: state,
      });
    });
    chatEngine.on('messagePlayStateChange', (message, state) => {
      if (state === AIChatMessagePlayState.Playing) {
        useChatStore.setState({
          playingMessageId: message.dialogueId,
        });
      } else if (state !== AIChatMessagePlayState.Init) {
        useChatStore.setState({
          playingMessageId: undefined,
        });
      }
    });
    chatEngine.on('requestAuthToken', async (userId, callback) => {
      if (shareConfig) {
        try {
          // eslint-disable-next-line @typescript-eslint/no-unused-vars
          const [_, authToken] = await chatEngine.generateShareAgentChat(shareConfig, userId);
          callback(authToken as AIChatAuthToken);
        } catch (err) {
          callback(undefined, err as AIChatError);
          const message = getErrorMessage((err as AICallAgentError).code) || (err as AICallAgentError).message;
          Toast.show({ content: `${message || '出错了'}` });
        }
        return;
      }

      try {
        const token = await standardService.generateMessageChatToken(`${userId}`, userToken, agentId, region);
        callback(token as AIChatAuthToken);
      } catch (err) {
        callback(undefined, err as AIChatError);
        if ((err as AICallAgentError).name === 'ServiceAuthError') {
          onAuthFail?.();
        }
      }
    });

    chatEngine.on('receivedMessage', (message) => {
      useChatStore.getState().receiveMessage(message);
    });
    chatEngine.on('voiceListUpdated', (voiceIdList) => {
      useChatStore.setState({
        voiceIdList,
      });
    });
    chatEngine.on('errorOccurs', (error) => {
      // TokenExpired 场景交给 requestAuthToken 处理
      if ((error as AIChatError).code === AICallErrorCode.TokenExpired) {
        return;
      }
      Toast.show({ content: `出错了(${(error as AIChatError).code}): ${(error as AIChatError).message}` });
    });

    (async () => {
      if (!_agentId) return;
      await chatEngine.startChat(new AIChatUserInfo(userId), new AIChatAgentInfo(_agentId, _region));
      if (chatEngine.sessionId) {
        let messageList;
        try {
          messageList = JSON.parse(localStorage.getItem(`${messageCachePrefix}${chatEngine.sessionId}`) || '[]');
        } catch (error) {
          console.warn(`get local history message list error: ${error}`);
          messageList = [];
        }
        useChatStore.setState({
          sessionId: chatEngine.sessionId,
          messageList,
        });
      }
    })();

    setChatEngine(chatEngine);

    return () => {
      chatEngine.removeAllListeners();
      chatEngine.endChat(false);
      useChatStore.getState().reset();
    };
  }, [userId, userToken, agentId, region, onAuthFail, shareToken]);

  return (
    <ChatEngineContext.Provider value={chatEngine}>
      <div className='chat'>
        <SafeArea position='top' />
        <ChatHeader onBack={onExit} />
        <ChatMessages />
        <ChatFooter />
        <SafeArea position='bottom' />
        <ChatState onExit={onExit} />
      </div>
    </ChatEngineContext.Provider>
  );
}

export default Chat;
