import {
  AIChatAgentResponseState,
  AIChatAttachmentUploader,
  AIChatMessage,
  AIChatMessageState,
} from 'aliyun-auikit-aicall';
import { Button, TextArea, TextAreaRef, Toast } from 'antd-mobile';
import { ReactNode, RefObject, useContext, useEffect, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { getRootElement } from '@/common/utils.ts';

import ChatEngineContext from '../../ChatEngineContext';
import useChatStore from '../../store';
import { interruptSVG, micSVG, sendSVG } from '../Icons';
import { OnTypeChange } from './type';

const TEXT_CACHE_KEY = 'aicall-chat-input-cache';

function TextSender({
  leftBtn,
  onTypeChange,
  uploaderRef,
  afterSend,
}: {
  leftBtn: ReactNode;
  onTypeChange: OnTypeChange;
  uploaderRef: RefObject<AIChatAttachmentUploader | undefined>;
  afterSend?: (success: boolean) => void;
}) {
  const { t } = useTranslation();
  const engine = useContext(ChatEngineContext);
  const ref = useRef<TextAreaRef>(null);
  const textHeightRef = useRef(0);
  const reponseState = useChatStore((state) => state.chatResponseState);
  const [focusing, setFocusing] = useState(false);
  const attachmentList = useChatStore((state) => state.attachmentList);
  const attachmentCanSend = useChatStore((state) => state.attachmentCanSend);
  const [hasText, setHasText] = useState(false);
  const sendingRef = useRef(false);

  useEffect(() => {
    const text = localStorage?.getItem(TEXT_CACHE_KEY);
    if (text) {
      if (ref.current?.nativeElement) {
        ref.current.nativeElement.value = text;
      }
      setHasText(!!text.trim());
    }
    if (ref.current?.nativeElement) {
      textHeightRef.current = ref.current.nativeElement.clientHeight;
    }
  }, []);

  useEffect(() => {
    setTimeout(() => {
      if (focusing) {
        // iOS 16 以下如果传入 false 会导致无法滚动
        // if iOS version < 16 and params with false scrollIntoView will not work
        ref.current?.nativeElement?.scrollIntoView();
      }
    }, 100);
  }, [focusing]);

  const sendMessage = async (e?: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    const target = e?.target as HTMLButtonElement;
    if (target && target.getAttribute('data-disabled') === 'true') {
      if (!attachmentCanSend) {
        Toast.show({
          content: t('chat.uploader.notReady'),
          getContainer: getRootElement,
        });
      }
      return;
    }
    const text = ref.current?.nativeElement?.value || '';

    // 需要有附件或文本时才发送
    // If there are no attachments and the text is empty, do not send
    if (sendingRef.current && !uploaderRef.current?.attachmentList?.length && !text.trim()) {
      return;
    }

    sendingRef.current = true;

    localStorage?.removeItem(TEXT_CACHE_KEY);
    const message = AIChatMessage.fromSendText(text.trim(), uploaderRef.current?.attachmentList);
    message.messageState = AIChatMessageState.Transfering;
    useChatStore.getState().sendMessage(message);

    try {
      const sendedMessage = await engine?.sendMessage(message, uploaderRef.current || undefined);
      useChatStore.getState().updateMessageList();
      afterSend?.(true);
      ref.current?.clear();
      setFocusing(false);
      if (sendedMessage) {
        useChatStore.getState().updateSendMessage(sendedMessage);
      }
    } catch (error) {
      afterSend?.(false);
      message.messageState = AIChatMessageState.Failed;
      useChatStore.getState().updateSendMessage(message);
      useChatStore.setState({ attachmentList: [] });
      console.error(error);
    } finally {
      sendingRef.current = false;
    }
  };

  const interruptMessage = async () => {
    try {
      await engine?.interruptAgentResponse();
      useChatStore.getState().interruptAgent();
    } catch (error) {
      console.error(error);
    }
  };

  const toVoice = () => {
    const text = ref.current?.nativeElement?.value || '';
    if (text) {
      localStorage?.setItem(TEXT_CACHE_KEY, text);
    }
    onTypeChange('voice');
  };

  const onChange = (v: string) => {
    if (ref.current?.nativeElement) {
      // 仅高度增大时需要更新列表，触发滚动到最下面
      // only increase height, need to update list to scroll to bottom
      if (ref.current.nativeElement.clientHeight > textHeightRef.current) {
        useChatStore.getState().updateMessageList();
        textHeightRef.current = ref.current.nativeElement.clientHeight;
      }
    }

    setHasText(!!v.trim());
  };
  let actionBtn = (
    <Button
      fill='none'
      className={`_send-btn ${!attachmentCanSend || (attachmentList.length === 0 && !hasText) ? 'is-disabled' : ''}`}
      data-disabled={!attachmentCanSend || (attachmentList.length === 0 && !hasText)}
      onClick={sendMessage}
    >
      {sendSVG}
    </Button>
  );
  if (reponseState === AIChatAgentResponseState.Replying || reponseState === AIChatAgentResponseState.Thinking) {
    actionBtn = (
      <Button fill='none' className='_interrupt-btn' onClick={interruptMessage}>
        {interruptSVG}
      </Button>
    );
  }

  useEffect(() => {
    const element = ref.current?.nativeElement;
    const onFocus = () => {
      setFocusing(true);
    };
    const onBlur = () => {
      //  延迟，防止状态更新导致点击事件不触发
      // delay 200ms to wait for state update
      setTimeout(() => {
        setFocusing(false);
      }, 200);
    };
    element?.addEventListener('focus', onFocus);
    element?.addEventListener('blur', onBlur);

    return () => {
      element?.removeEventListener('focus', onFocus);
      element?.removeEventListener('blur', onBlur);
    };
  }, [ref]);

  const onKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <>
      <div
        className={`_send-textarea ${focusing ? 'is-focusing' : ''} ${hasText ? 'has-text' : ''} ${attachmentList.length > 0 ? 'has-attachment' : ''}`}
      >
        <div className='_btns'>{leftBtn}</div>
        <TextArea
          placeholder={t('chat.send.textHolder')}
          style={{ '--font-size': '16px' }}
          rows={1}
          autoSize={{ minRows: 1, maxRows: 5 }}
          defaultValue={localStorage?.getItem(TEXT_CACHE_KEY) || ''}
          ref={ref}
          onChange={onChange}
          onKeyDown={onKeyDown}
        />
        <div className='_btns'>
          <Button fill='none' className='_to-voice-btn' onClick={() => toVoice()}>
            {micSVG}
          </Button>
          {actionBtn}
        </div>
      </div>
    </>
  );
}

export default TextSender;
