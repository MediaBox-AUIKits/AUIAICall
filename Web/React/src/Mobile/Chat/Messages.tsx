import React, { useContext, useEffect, useRef } from 'react';
import { PullToRefresh, Toast } from 'antd-mobile';

import { getRootElement } from '@/common/utils';
import useChatStore from './store';
import ChatEngineContext from './ChatEngineContext';
import MessageItem from './MessageItem';
import './messages.less';
import resizeHandler from '@/Mobile/Chat/resizeHandler.ts';

const AutoScrollGap = 80;

function ChatMessages() {
  const engine = useContext(ChatEngineContext);
  const messages = useChatStore((state) => state.messageList);
  const bottomRef = useRef<HTMLDivElement>(null);
  // 是否自动滚动到最底部
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
      // 加载的历史消息列表是新的在前的，在这里进行了反向
      useChatStore.getState().historyMessages(messageList.reverse(), engine?.userInfo?.userId);
    }
    if (messageList?.length === 0) {
      Toast.show({ content: '没有更多了', getContainer: getRootElement });
    }
  };

  return (
    <div className='chat-messages' onScroll={onScroll}>
      <PullToRefresh
        pullingText='下拉加载历史消息'
        canReleaseText='松手加载'
        completeText='加载完成'
        refreshingText='加载中...'
        onRefresh={onLoadHistoryMessage}
      >
        <ul>
          {messages.map((messageItem) => {
            const key = `${messageItem.isSend ? 'send' : 'receive'}_${messageItem.message.requestId || 'current'}`;
            return <MessageItem key={key} message={messageItem} onLayoutUpdate={onLayoutUpdate} />;
          })}
        </ul>
        <div ref={bottomRef}></div>
      </PullToRefresh>
    </div>
  );
}

export default ChatMessages;
