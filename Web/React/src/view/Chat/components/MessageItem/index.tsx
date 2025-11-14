import { AICallErrorCode, AIChatAgentResponseState, AIChatError, AIChatMessageState } from 'aliyun-auikit-aicall';
import { Button, Dialog, DotLoading, Popover, Toast } from 'antd-mobile';
import { memo, useContext, useEffect, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { checkTouchSupport, copyText, getRootElement, longPressEvents } from '@/common/utils';
import ChatEngineContext from 'chat/ChatEngineContext';
import useChatStore, { ChatMessageItem } from 'chat/store';

import { copySVG, deleteSVG, volumeSVG } from '../Icons';
import MessageItemMarkdownRender from './MarkdownRender';
import MessageItemReasoning from './Reasoning';
import SendAttachment from './SendAttachment.tsx';
import MessageItemSendStatus from './SendStatus';
import MessageItemTextLineRender from './TextLineRender';

import './index.less';

function StaticMessageItem({
  messageItem,
  onLayoutUpdate,
}: {
  messageItem: ChatMessageItem;
  onLayoutUpdate: (forceScroll?: boolean) => void;
}) {
  const { t } = useTranslation();

  const engine = useContext(ChatEngineContext);
  const message = messageItem.message;
  const voiceId = useChatStore((state) => state.voiceId);
  const playingMessageId = useChatStore((state) => state.playingMessageId);
  const [showDelete, setShowDelete] = useState(false);
  const [copying, setCopying] = useState(false);
  const deleteRef = useRef<HTMLDivElement>(null);
  const responseState = useChatStore((state) => state.chatResponseState);

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

  useEffect(() => {
    onLayoutUpdate();
  }, [message.text, message.reasoningText, message.messageState]);

  if (!message) return null;
  if (
    message.messageState !== AIChatMessageState.Transfering &&
    !message.text &&
    !message.reasoningText &&
    !message.attachmentList
  ) {
    return null;
  }

  const onCopy = async () => {
    try {
      if (!message.text) return;
      setCopying(true);
      await copyText(message.text);
      Toast.show({ content: t('chat.message.copied'), getContainer: getRootElement });
      setTimeout(() => {
        setCopying(false);
      }, 2000);
    } catch (error) {
      setCopying(false);
      console.warn(error);
      Toast.show({ content: t('chat.message.copyFailed'), getContainer: getRootElement });
    }
  };

  const togglePlay = async () => {
    if (!message.text) {
      return;
    }

    if (playingMessageId === message.dialogueId) {
      engine?.stopPlayMessage();
      useChatStore.setState({
        playingMessageId: undefined,
      });
      return;
    }

    try {
      await engine?.startPlayMessage(message, voiceId ? voiceId : undefined);
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (err) {
      Toast.show({ content: t('chat.playback.failed'), getContainer: getRootElement });
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
      title: t('chat.message.deleteConfirm'),
      content: t('chat.message.deleteHelp'),
      confirmText: t('common.delete'),
      cancelText: t('common.cancel'),
      getContainer: getRootElement,
      onConfirm: async () => {
        try {
          await engine?.deleteMessage(message.dialogueId);
        } catch (error) {
          if ((error as AIChatError).code !== AICallErrorCode.ChatLogNotFound) {
            Toast.show({ content: t('chat.message.deleteFailed'), getContainer: getRootElement });
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
        className='ai-popover'
        content={
          <div className='chat-item-delete' ref={deleteRef}>
            <Button onClick={onDelete}>
              {deleteSVG}
              <div className='_text'>{t('common.delete')}</div>
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
          className='_bd'
          {...longPressEvents({
            onStartCallback: onLongPress,
            ms: 500,
          })}
        >
          {messageItem.isSend && <SendAttachment message={message} />}
          {(message.text ||
            message.reasoningText ||
            (!messageItem.isSend && message.messageState === AIChatMessageState.Transfering)) && (
            <div className='_box'>
              {messageItem.isSend ? (
                <MessageItemTextLineRender text={message.text} />
              ) : (
                <>
                  <MessageItemReasoning message={message} />
                  <MessageItemMarkdownRender text={message.text} />
                  {message.messageState === AIChatMessageState.Transfering && <DotLoading color='currentColor' />}
                  {message.messageState === AIChatMessageState.Interrupted && (
                    <div className='_interrupted'>{t('chat.response.interrupted')}</div>
                  )}
                </>
              )}
            </div>
          )}
          {!messageItem.isSend &&
            (message.messageState === AIChatMessageState.Finished ||
              message.messageState === AIChatMessageState.Interrupted) && (
              <div className='_actions'>
                <Button fill='none' className={copying ? 'is-copying' : ''} onClick={onCopy}>
                  {copySVG}
                </Button>
                {responseState !== AIChatAgentResponseState.Replying && (
                  <Button
                    fill='none'
                    className={playingMessageId === message.dialogueId ? 'is-playing' : ''}
                    onClick={togglePlay}
                  >
                    {volumeSVG}
                  </Button>
                )}
              </div>
            )}
          {messageItem.isSend && <MessageItemSendStatus message={message} />}
        </div>
      </Popover>
    </li>
  );
}

function MessageItem({
  messageItem,
  onLayoutUpdate,
}: {
  messageItem: ChatMessageItem;
  onLayoutUpdate: (forceScroll?: boolean) => void;
}) {
  return <StaticMessageItem messageItem={messageItem} onLayoutUpdate={onLayoutUpdate} />;
}

export default memo(MessageItem);
