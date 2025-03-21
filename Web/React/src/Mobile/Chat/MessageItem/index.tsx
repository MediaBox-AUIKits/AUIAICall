import { useContext, useEffect, useRef, useState } from 'react';
import { AICallErrorCode, AIChatError, AIChatMessageState } from 'aliyun-auikit-aicall';

import useChatStore, { ChatMessageItem } from '../store';
import ChatEngineContext from '../ChatEngineContext';
import { checkTouchSupport, copyText, getRootElement, longPressEvents } from '@/common/utils';
import { Button, Dialog, DotLoading, Popover, Toast } from 'antd-mobile';
import { deleteSVG, copySVG, volumeSVG } from '../Icons';
import MessageItemSendStatus from './SendStatus';
import MessageItemTextLineRender from './TextLineRender';
import MessageItemReasoning from './Reasoning';

import './index.less';

function StaticMessageItem({ messageItem }: { messageItem: ChatMessageItem }) {
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
  if (message.messageState !== AIChatMessageState.Transfering && !message.text && !message.reasoningText) {
    return null;
  }

  const onCopy = async () => {
    try {
      if (!message.text) return;
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
    if (!message.text) {
      return;
    }

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
          <MessageItemReasoning message={message} />
          <MessageItemTextLineRender text={message.text} />
          {!messageItem.isSend && message.messageState === AIChatMessageState.Transfering && (
            <DotLoading color='currentColor' />
          )}
          {!messageItem.isSend && message.messageState === AIChatMessageState.Interrupted && (
            <div className='_interrupted'>用户停止本次回答</div>
          )}
          {(message.messageState === AIChatMessageState.Finished ||
            message.messageState === AIChatMessageState.Interrupted) && (
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
  }, [
    currentMessage?.message.text,
    currentMessage?.message.reasoningText,
    currentMessage?.message.messageState,
    onLayoutUpdate,
  ]);

  if (
    !!messageItem.isSend === !!currentMessage?.isSend &&
    messageItem.message.requestId === currentMessage?.message.requestId
  ) {
    return <StaticMessageItem messageItem={currentMessage} />;
  }
  return <StaticMessageItem messageItem={messageItem} />;
}

function MessageItem({
  message,
  onLayoutUpdate,
}: {
  message: ChatMessageItem;
  onLayoutUpdate: (forceScroll?: boolean) => void;
}) {
  if (message.isProcessing) {
    return <ProcessingMessageItem messageItem={message} onLayoutUpdate={onLayoutUpdate} />;
  }
  return <StaticMessageItem messageItem={message} />;
}

export default MessageItem;
