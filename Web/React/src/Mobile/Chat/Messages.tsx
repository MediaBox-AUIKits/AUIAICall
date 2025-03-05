import { Button, Dialog, DotLoading, Popover, PullToRefresh, SpinLoading, Toast } from 'antd-mobile';
import './messages.less';
import { copySVG, deleteSVG, resendSVG, volumeSVG } from './Icons';
import useChatStore, { ChatMessageItem } from './store';
import { checkTouchSupport, copyText, getRootElement, longPressEvents } from '@/common/utils';
import { AICallErrorCode, AIChatError, AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';
import { useContext, useEffect, useRef, useState } from 'react';
import ChatEngineContext from './ChatEngineContext';
import React from 'react';

function MessageItemSendStatus({ message }: { message: AIChatMessage }) {
  const engine = useContext(ChatEngineContext);
  const resend = () => {
    engine?.sendMessage(message);
  };

  if (message.messageState !== AIChatMessageState.Transfering && message.messageState !== AIChatMessageState.Failed)
    return null;

  return (
    <div className='_status'>
      {message.messageState === AIChatMessageState.Transfering && (
        <SpinLoading style={{ '--size': '16px' }} color='#624AFF' />
      )}
      {message.messageState === AIChatMessageState.Failed && <Button onClick={resend}>{resendSVG}</Button>}
    </div>
  );
}

function TextWithLineBreaks({ text }: { text: string }) {
  // 将文本中的换行符替换为 JSX 可识别的 <br /> 标签
  const formattedText = text.split('\n').map((line, index) => (
    <React.Fragment key={index}>
      {line}
      <br />
    </React.Fragment>
  ));

  return <>{formattedText}</>;
}

function MessageItem({ messageItem }: { messageItem: ChatMessageItem }) {
  const engine = useContext(ChatEngineContext);
  const message = messageItem.message;
  const voiceId = useChatStore((state) => state.voiceId);
  const playingMessageId = useChatStore((state) => state.playingMessageId);
  const [showDelete, setShowDelete] = useState(false);
  const [copying, setCopying] = useState(false);
  const deleteRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const isTouchSupported = checkTouchSupport();
    const onClearDelete = (e: MouseEvent | TouchEvent) => {
      if (deleteRef.current?.contains(e.target as Node)) {
        return;
      }
      setShowDelete(false);
    };

    if (isTouchSupported) {
      document.addEventListener('touchstart', onClearDelete);
      return () => {
        document.removeEventListener('touchend', onClearDelete);
      };
    }

    document.addEventListener('mousedown', onClearDelete);
    return () => {
      document.removeEventListener('click', onClearDelete);
    };
  }, []);

  if (!message) return null;
  if (message.messageState !== AIChatMessageState.Transfering && !message.text) {
    return null;
  }

  const onCopy = async () => {
    try {
      setCopying(true);
      await copyText(message.text);
      Toast.show({ content: '信息已复制', getContainer: getRootElement });
      setTimeout(() => {
        setCopying(false);
      }, 2000);
    } catch (error) {
      setCopying(false);
      console.warn(error);
      Toast.show({ content: '信息复制失败', getContainer: getRootElement });
    }
  };

  const togglePlay = async () => {
    if (playingMessageId === message.dialogueId) {
      await engine?.stopPlayMessage();
      useChatStore.setState({
        playingMessageId: undefined,
      });
      return;
    }

    try {
      await engine?.startPlayMessage(message, voiceId ? voiceId : undefined);
    } catch (err) {
      Toast.show({ content: `播放失败: ${(err as AIChatError).code}`, getContainer: getRootElement });
    }
  };

  const onLongPress = () => {
    if (
      message.messageState !== AIChatMessageState.Finished &&
      message.messageState !== AIChatMessageState.Interrupted
    ) {
      return;
    }
    setShowDelete(true);
  };
  const onDelete = async () => {
    Dialog.confirm({
      className: 'chat-item-delete-confirm',
      title: '确认删除此条信息？',
      content: '信息删除后，不可恢复',
      confirmText: '删除',
      cancelText: '取消',
      getContainer: getRootElement,
      onConfirm: async () => {
        try {
          await engine?.deleteMessage(message.dialogueId);
        } catch (error) {
          if ((error as AIChatError).code !== AICallErrorCode.ChatLogNotFound) {
            Toast.show({ content: `删除失败: ${(error as AIChatError).code}`, getContainer: getRootElement });
            throw error;
          }
        }
        useChatStore.getState().deleteMessage(message);
      },
    });
  };

  return (
    <li className={`chat-item ${messageItem.isSend ? 'is-self' : 'is-agent'}`}>
      <Popover
        placement='top'
        mode='dark'
        content={
          <div className='chat-item-delete' ref={deleteRef}>
            <Button onClick={onDelete}>
              {deleteSVG}
              <div className='_text'>删除</div>
            </Button>
          </div>
        }
        onVisibleChange={(visible) => {
          setShowDelete(visible);
        }}
        destroyOnHide
        getContainer={getRootElement}
        visible={showDelete}
      >
        <div
          className='_box'
          {...longPressEvents({
            onStartCallback: onLongPress,
            ms: 500,
          })}
        >
          {message.text && <TextWithLineBreaks text={message.text} />}
          {!messageItem.isSend && message.messageState === AIChatMessageState.Transfering && (
            <DotLoading color='currentColor' />
          )}
          {!messageItem.isSend && message.messageState === AIChatMessageState.Interrupted && (
            <div className='_interrupted'>用户停止本次回答</div>
          )}
          {(message.messageState === AIChatMessageState.Finished ||
            message.messageState === AIChatMessageState.Interrupted) &&
            message.text && (
              <div className='_actions'>
                <Button className={copying ? 'is-copying' : ''} onClick={onCopy}>
                  {copySVG}
                </Button>
                <Button className={playingMessageId === message.dialogueId ? 'is-playing' : ''} onClick={togglePlay}>
                  {volumeSVG}
                </Button>
              </div>
            )}{' '}
          {messageItem.isSend && <MessageItemSendStatus message={message} />}
        </div>
      </Popover>
    </li>
  );
}

// 性能优化考虑，仅当前正在处理的 Message 需要持续渲染
function ProcessingMessageItem({
  messageItem,
  onLayoutUpdate,
}: {
  messageItem: ChatMessageItem;
  onLayoutUpdate: (forceScroll?: boolean) => void;
}) {
  const currentMessage = useChatStore((state) => state.currentMessage);

  // 发送消息，强制滚动到最底部
  useEffect(() => {
    if (currentMessage?.isSend) {
      onLayoutUpdate(true);
    }
  }, [currentMessage?.isSend, onLayoutUpdate]);

  useEffect(() => {
    onLayoutUpdate();
  }, [currentMessage?.message.text, currentMessage?.message.messageState, onLayoutUpdate]);

  if (
    !!messageItem.isSend === !!currentMessage?.isSend &&
    messageItem.message.requestId === currentMessage?.message.requestId
  ) {
    return <MessageItem messageItem={currentMessage} />;
  }
  return <MessageItem messageItem={messageItem} />;
}

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
            const id = messageItem.message.requestId || 'current';
            const key = `${messageItem.isSend ? 'send' : 'receive'}_${id}`;
            if (messageItem.isProcessing) {
              return <ProcessingMessageItem key={key} messageItem={messageItem} onLayoutUpdate={onLayoutUpdate} />;
            }
            return <MessageItem key={key} messageItem={messageItem} />;
          })}
        </ul>
        <div ref={bottomRef}></div>
      </PullToRefresh>
    </div>
  );
}

export default ChatMessages;
