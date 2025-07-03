import { AICallRunConfig } from '@/interface.ts';
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
  AIChatTemplateConfig,
  AIChatUserInfo,
} from 'aliyun-auikit-aicall';
import ChatHeader from './Header';
import ChatMessages from './Messages';
import ChatFooter from './Footer';
import { useEffect, useState } from 'react';
import ChatEngineContext from './ChatEngineContext';
import useChatStore, { ChatMessageItem, messageCachePrefix } from './store';
import standardService from '../../service/standard';

import './index.less';
import ChatState from './State';
import { getRootElement } from '@/common/utils';
import { AIChatEngineState, AIChatMessageState } from 'aliyun-auikit-aicall';
import { JSONObject } from '@/service/interface.ts';
import { useTranslation } from '@/common/i18nContext';

export interface ChatProps {
  rc: AICallRunConfig;
  userId: string;
  userToken: string;
  appServer?: string;
  agentId?: string;
  shareToken?: string;
  region?: string;
  templateConfig?: AIChatTemplateConfig;
  userData?: JSONObject;
  onExit: () => void;
  onAuthFail?: () => void;
}

function Chat({
  rc,
  userId,
  userToken,
  appServer,
  agentId,
  shareToken,
  region,
  templateConfig,
  userData,
  onExit,
  onAuthFail,
}: ChatProps) {
  const { t } = useTranslation();

  const [chatEngine, setChatEngine] = useState<AIChatEngine | null>(null);
  const { e } = useTranslation();

  useEffect(() => {
    const pageUnload = () => {
      useChatStore.getState().updateMessageList();
    };
    window.addEventListener('beforeunload', pageUnload);

    return () => {
      // to cache the message list
      useChatStore.getState().updateMessageList();
      window.removeEventListener('beforeunload', pageUnload);
    };
  }, []);

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
        Toast.show({ content: t('share.tokenInvalid'), getContainer: () => getRootElement() });
        return;
      }
    }

    if (!_agentId) {
      Toast.show({ content: 'no agentId founded', getContainer: () => getRootElement() });
      return;
    }
    if (appServer) {
      standardService.setAppServer(appServer);
    }

    const chatEngine = new AIChatEngine();

    if (templateConfig) {
      chatEngine.templateConfig = templateConfig;
    }
    if (userData) {
      chatEngine.userData = userData;
    }

    chatEngine.on('engineStateChange', (state) => {
      useChatStore.setState({
        chatState: state,
      });
    });
    chatEngine.on('agentResponeStateChange', (state) => {
      useChatStore.setState({
        chatResponseState: state,
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
          const message = e((err as AICallAgentError).code) || (err as AICallAgentError).message;
          Toast.show({ content: `${message || t('error.unknown')}` });
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
      if (message.senderId === chatEngine.agentInfo?.agentId) {
        useChatStore.getState().receiveMessage(message);
      } else {
        useChatStore.getState().sendMessage(message);
      }
    });
    chatEngine.on('voiceListUpdated', (voiceIdList) => {
      useChatStore.setState({
        voiceIdList,
      });
    });
    chatEngine.on('errorOccurs', (error) => {
      if ((error as AIChatError).code === AICallErrorCode.TokenExpired) {
        return;
      }
      Toast.show({
        content: `Error Occurs: (${(error as AIChatError).code}): ${(error as AIChatError).message}`,
        getContainer: getRootElement,
      });
    });
    chatEngine.on('receivedCustomMessage', (message) => {
      Toast.show({
        content: `Received Custom Message: ${message}`,
        getContainer: getRootElement,
      });
    });

    (async () => {
      if (!_agentId) return;
      await chatEngine.startChat(new AIChatUserInfo(userId), new AIChatAgentInfo(_agentId, _region));
      if (chatEngine.sessionId) {
        let messageList;
        try {
          messageList = JSON.parse(localStorage.getItem(`${messageCachePrefix}${chatEngine.sessionId}`) || '[]');
          messageList.forEach((messageItem: ChatMessageItem) => {
            if (messageItem.message.messageState === AIChatMessageState.Transfering) {
              messageItem.message.messageState = AIChatMessageState.Interrupted;
            }
          });
        } catch (error) {
          console.warn(`get local history message list error: ${error}`);
          messageList = [];
        }
        useChatStore.setState({
          sessionId: chatEngine.sessionId,
          messageList,
        });

        // 首次连接成功后，加载历史消息
        // load history message after engine connected
        chatEngine.once('engineStateChange', async (state) => {
          if (state === AIChatEngineState.Connected) {
            const serverLastMessageList = await chatEngine?.queryMessageList({
              startTime: 0,
              endTime: Date.now(),
              pageNumber: 1,
              pageSize: 20,
              isDesc: true,
            });

            if (serverLastMessageList?.length && chatEngine?.userInfo?.userId) {
              useChatStore
                .getState()
                .historyMessages(serverLastMessageList.reverse(), chatEngine.userInfo.userId, true);
            }
          }
        });
      }
    })();

    setChatEngine(chatEngine);

    return () => {
      chatEngine.removeAllListeners();
      chatEngine.endChat(false);
      useChatStore.getState().reset();
    };
  }, [userId, userToken, agentId, region, appServer, onAuthFail, shareToken, templateConfig]);

  return (
    <ChatEngineContext.Provider value={chatEngine}>
      <div className='chat-wrapper'>
        <div className='chat'>
          <SafeArea position='top' />
          <ChatHeader onBack={onExit} />
          <ChatMessages />
          <ChatFooter userId={userId} userToken={userToken} rc={rc} />
          <SafeArea position='bottom' />
          <ChatState onExit={onExit} />
        </div>
      </div>
    </ChatEngineContext.Provider>
  );
}

export default Chat;
