import { PullToRefresh, Toast } from 'antd-mobile';
import React, { useContext, useEffect, useRef } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { getRootElement } from '@/common/utils';
import ChatEngineContext from 'chat/ChatEngineContext';
import resizeHandler from 'chat/resizeHandler.ts';
import useChatStore from 'chat/store';

import MessageItem from './MessageItem';

import './messages.less';

const AutoScrollGap = 80;

function ChatMessages() {
  const { t } = useTranslation();

  const engine = useContext(ChatEngineContext);
  const messages = useChatStore((state) => state.messageList);
  const bottomRef = useRef<HTMLDivElement>(null);
  const autoScrollSwitchRef = useRef<boolean>(true);

  const scrollToBottom = () => {
    if (autoScrollSwitchRef.current) {
      bottomRef.current?.scrollIntoView();
    }
  };

  const onScroll = (e: React.UIEvent<HTMLDivElement>) => {
    const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
    if (scrollTop + clientHeight >= scrollHeight - AutoScrollGap) {
      autoScrollSwitchRef.current = true;
    } else {
      autoScrollSwitchRef.current = false;
    }
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const onLayoutUpdate = (forceScroll = false) => {
    if (forceScroll) {
      autoScrollSwitchRef.current = true;
    }
    scrollToBottom();
  };

  useEffect(() => {
    resizeHandler.on('resize', onLayoutUpdate);
    return () => {
      resizeHandler.off('resize', onLayoutUpdate);
    };
  }, []);

  const onLoadHistoryMessage = async () => {
    let endTime = Date.now();
    const list = useChatStore.getState().messageList;
    if (list.length > 0) {
      if (list[0].message.sendTime) {
        endTime = list[0].message.sendTime * 1000 - 1;
      }
    }
    const messageList = await engine?.queryMessageList({
      startTime: 0,
      endTime,
      pageNumber: 1,
      pageSize: 10,
      isDesc: true,
    });

    if (messageList?.length && engine?.userInfo?.userId) {
      useChatStore.getState().historyMessages(messageList.reverse(), engine?.userInfo?.userId);
    }
    if (messageList?.length === 0) {
      Toast.show({ content: t('chat.history.noMore'), getContainer: getRootElement });
    }
  };

  return (
    <div className='chat-messages' onScroll={onScroll}>
      <PullToRefresh
        pullingText={t('chat.history.pullingText')}
        canReleaseText={t('chat.history.canReleaseText')}
        completeText={t('chat.history.completeText')}
        refreshingText={t('chat.history.refreshingText')}
        onRefresh={onLoadHistoryMessage}
      >
        <ul className='chat-messages-list'>
          {messages.map((messageItem) => {
            const key = `${messageItem.isSend ? `send_${messageItem.message.requestId}` : `receive_${messageItem.message.dialogueId}_${messageItem.message.nodeId || ''}`}}`;
            return <MessageItem key={key} messageItem={messageItem} onLayoutUpdate={onLayoutUpdate} />;
          })}
        </ul>
        <div ref={bottomRef}></div>
      </PullToRefresh>
    </div>
  );
}

export default ChatMessages;
