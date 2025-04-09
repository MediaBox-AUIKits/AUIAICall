import { useContext, useRef, useState, useEffect, RefObject } from 'react';
import { TextAreaRef, Button, TextArea, Toast } from 'antd-mobile';
import { AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';

import ChatEngineContext from '../ChatEngineContext';
import { interruptSVG, sendSVG, micSVG } from '../Icons';
import useChatStore from '../store';
import { OnTypeChange } from './type';
import { AIChatAttachmentUploader } from 'aliyun-auikit-aicall';
import { getRootElement } from '@/common/utils.ts';

const TEXT_CACHE_KEY = 'aicall-chat-input-cache';

function TextSender({
  onTypeChange,
  uploaderRef,
  afterSend,
}: {
  onTypeChange: OnTypeChange;
  uploaderRef: RefObject<AIChatAttachmentUploader | undefined>;
  afterSend?: (success: boolean) => void;
}) {
  const engine = useContext(ChatEngineContext);
  const ref = useRef<TextAreaRef>(null);
  const textHeightRef = useRef(0);
  const currentMessage = useChatStore((state) => state.currentMessage);
  const [focusing, setFocusing] = useState(false);
  const attachmentList = useChatStore((state) => state.attachmentList);
  const attachmentCanSend = useChatStore((state) => state.attachmentCanSend);
  const [hasText, setHasText] = useState(false);

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
        // iOS 16 一下如果传入 false 会导致无法滚动
        ref.current?.nativeElement?.scrollIntoView();
      }
    }, 100);
  }, [focusing]);

  const sendMessage = async (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    const target = e.target as HTMLButtonElement;
    if (target.getAttribute('data-disabled' as any) === 'true') {
      if (!attachmentCanSend) {
        Toast.show({
          content: '部分图片上传中或上传失败',
          getContainer: getRootElement,
        });
      }
      return;
    }
    const text = ref.current?.nativeElement?.value || '';

    // 需要有附件或文本时才发送
    // If there are no attachments and the text is empty, do not send
    if (!uploaderRef.current?.attachmentList?.length && !text.trim()) {
      return;
    }

    localStorage?.removeItem(TEXT_CACHE_KEY);
    const message = AIChatMessage.fromSendText(text.trim(), uploaderRef.current?.attachmentList);
    message.messageState = AIChatMessageState.Transfering;
    useChatStore.getState().sendMessage(message);

    try {
      const sendedMessage = await engine?.sendMessage(message, uploaderRef.current || undefined);
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
      if (ref.current.nativeElement.clientHeight > textHeightRef.current) {
        useChatStore.getState().updateMessageList();
        textHeightRef.current = ref.current.nativeElement.clientHeight;
      }
    }

    setHasText(!!v.trim());
  };
  let actionBtn = (
    <Button
      className={`_action-btn is-send ${!attachmentCanSend || (attachmentList.length === 0 && !hasText) ? 'is-disabled' : ''}`}
      data-disabled={!attachmentCanSend || (attachmentList.length === 0 && !hasText)}
      onClick={sendMessage}
    >
      {sendSVG}
    </Button>
  );
  if (currentMessage?.message.messageState === AIChatMessageState.Printing) {
    actionBtn = (
      <Button className='_action-btn' onClick={interruptMessage}>
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

  return (
    <>
      <div className={`_send-textarea ${focusing ? 'is-focusing' : ''}`}>
        <TextArea
          placeholder='请输入内容'
          style={{ '--font-size': '14px' }}
          rows={1}
          autoSize={{ minRows: 1, maxRows: 5 }}
          defaultValue={localStorage?.getItem(TEXT_CACHE_KEY) || ''}
          ref={ref}
          onChange={onChange}
        />
        {actionBtn}
      </div>
      <Button className='_to-voice-btn' onClick={() => toVoice()}>
        {micSVG}
      </Button>
    </>
  );
}

export default TextSender;
