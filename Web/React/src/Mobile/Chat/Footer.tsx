import { useContext, useEffect, useRef, useState } from 'react';
import { Button, ButtonRef, Popup, TextArea, TextAreaRef, Toast } from 'antd-mobile';

import './footer.less';
import { callSVG, cancelRecordSVG, interruptSVG, keyboardSVG, micSVG, recordingSVG, sendSVG } from './Icons';
import ChatEngineContext from './ChatEngineContext';
import useChatStore from './store';
import { AICallAgentType, AICallChatSyncConfig, AIChatMessage, AIChatMessageState } from 'aliyun-auikit-aicall';
import { getRootElement } from '@/common/utils';
import Call from '../Call';

type OnTypeChange = (type: 'text' | 'voice') => void;

const TEXT_CACHE_KEY = 'aicall-chat-input-cache';
function SendText({ onTypeChange }: { onTypeChange: OnTypeChange }) {
  const engine = useContext(ChatEngineContext);
  const ref = useRef<TextAreaRef>(null);
  const textHeightRef = useRef(0);
  const currentMessage = useChatStore((state) => state.currentMessage);
  const [focusing, setFocusing] = useState(false);

  useEffect(() => {
    const text = localStorage?.getItem(TEXT_CACHE_KEY);
    if (text) {
      if (ref.current?.nativeElement) {
        ref.current.nativeElement.value = text;
      }
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

  const sendMessage = async () => {
    const text = ref.current?.nativeElement?.value || '';
    if (!text.trim()) {
      return;
    }
    localStorage?.removeItem(TEXT_CACHE_KEY);
    const message = AIChatMessage.fromSendText(text.trim());
    useChatStore.getState().sendMessage(message);
    try {
      const sendedMessage = await engine?.sendMessage(message);
      ref.current?.clear();
      setFocusing(false);
      if (sendedMessage) {
        useChatStore.getState().updateSendMessage(sendedMessage);
      }
    } catch (error) {
      message.messageState = AIChatMessageState.Failed;
      useChatStore.getState().updateSendMessage(message);
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

  const onChange = () => {
    if (ref.current?.nativeElement) {
      // 仅高度增大时需要更新列表，触发滚动到最下面
      if (ref.current.nativeElement.clientHeight > textHeightRef.current) {
        useChatStore.getState().updateMessageList();
        textHeightRef.current = ref.current.nativeElement.clientHeight;
      }
    }
  };
  let actionBtn = (
    <Button className='_action-btn' onClick={() => toVoice()}>
      {micSVG}
    </Button>
  );
  if (currentMessage?.message.messageState === AIChatMessageState.Printing) {
    actionBtn = (
      <Button className='_action-btn' onClick={interruptMessage}>
        {interruptSVG}
      </Button>
    );
  } else if (focusing) {
    actionBtn = (
      <Button className='_action-btn is-send' onClick={sendMessage}>
        {sendSVG}
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
  );
}

function SendVoice({ onTypeChange }: { onTypeChange: OnTypeChange }) {
  const engine = useContext(ChatEngineContext);
  const currentMessage = useChatStore((state) => state.currentMessage);
  const [pushing, setPushing] = useState(false);
  const [willCancel, setWillCancel] = useState(false);
  const [timeString, setTimeString] = useState('00:00');
  const buttonRef = useRef<ButtonRef>(null);
  const startYRef = useRef(0);
  const isPushingRef = useRef(false);
  const willCancelRef = useRef(false);
  const timerRef = useRef(0);
  const startTimeRef = useRef(0);

  useEffect(() => {
    willCancelRef.current = willCancel;
  }, [willCancel]);

  useEffect(() => {
    const element = buttonRef.current?.nativeElement;

    const isTouchSupported = 'ontouchstart' in window;
    const onStart = async (clientY: number) => {
      startYRef.current = clientY;
      setWillCancel(false);
      setPushing(true);
      setTimeString('00:00');
      isPushingRef.current = true;
      const success = await engine?.startPushVoiceMessage();
      if (success) {
        startTimeRef.current = Date.now();
        timerRef.current = window.setInterval(() => {
          const time = Math.floor((Date.now() - startTimeRef.current) / 1000);
          const minutes = Math.floor(time / 60);
          const seconds = time % 60;
          setTimeString(`${minutes < 10 ? `0${minutes}` : minutes}:${seconds < 10 ? `0${seconds}` : seconds}`);
        }, 1000);
      }
    };
    const onTouchStart = (e: TouchEvent) => {
      const target = e.currentTarget as HTMLButtonElement;
      if (target.disabled) return;
      const y = e.touches[0].clientY || 0;
      onStart(y);
    };
    const onMouseDown = (e: MouseEvent) => {
      const y = e.clientY || 0;
      onStart(y);
    };

    const onEnd = async () => {
      setPushing(false);
      if (!isPushingRef.current) {
        return;
      }

      isPushingRef.current = false;
      if (!willCancelRef.current) {
        setPushing(false);
        const message = await engine?.finishPushVoiceMessage();
        if (!message?.text) {
          Toast.show({ content: '未识别到文字', getContainer: getRootElement });
          return;
        }
        useChatStore.getState().sendMessage(message);
      } else {
        engine?.cancelPushVoiceMessage();
      }
    };

    const onMove = (clientY: number) => {
      if (clientY === -1) {
        setWillCancel(true);
      }
      if (startYRef.current === 0 && clientY) {
        startYRef.current = clientY;
      } else {
        if (!willCancelRef.current && Math.abs(clientY - startYRef.current) > 40) {
          setWillCancel(true);
        }
      }
    };
    const onTouchMove = (e: TouchEvent) => {
      e.preventDefault();
      const y = e.touches[0].clientY || 0;
      onMove(y);
    };
    const onMouseMove = (e: MouseEvent) => {
      e.preventDefault();
      const y = e.clientY || 0;
      onMove(y);
    };
    const onMouseLeave = () => {
      onMove(-1);
    };

    if (isTouchSupported) {
      element?.addEventListener('touchstart', onTouchStart);
      element?.addEventListener('touchend', onEnd);
      element?.addEventListener('touchmove', onTouchMove);
    } else {
      element?.addEventListener('mousedown', onMouseDown);
      document?.addEventListener('mouseup', onEnd);
      element?.addEventListener('mouseleave', onMouseLeave);
      element?.addEventListener('mousemove', onMouseMove);
    }
    return () => {
      clearInterval(timerRef.current);
      if (isTouchSupported) {
        element?.removeEventListener('touchstart', onTouchStart);
        element?.removeEventListener('touchend', onEnd);
        element?.removeEventListener('touchmove', onTouchMove);
      } else {
        element?.removeEventListener('mousedown', onMouseDown);
        document?.removeEventListener('mouseup', onEnd);
        element?.removeEventListener('mouseleave', onMouseLeave);
        element?.removeEventListener('mousemove', onMouseMove);
      }
    };
  }, [engine]);

  const interruptMessage = async () => {
    try {
      await engine?.interruptAgentResponse();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <div className={`_send-voice ${pushing ? 'is-pushing' : ''}`}>
      <Button
        className='_push-btn'
        block
        ref={buttonRef}
        disabled={currentMessage?.message.messageState === AIChatMessageState.Printing}
      >
        按住说话
      </Button>
      {currentMessage?.message.messageState === AIChatMessageState.Printing ? (
        <Button className='_action-btn' onClick={interruptMessage}>
          {interruptSVG}
        </Button>
      ) : (
        <Button className='_action-btn is-text' onClick={() => onTypeChange('text')}>
          {keyboardSVG}
        </Button>
      )}
      <div className='_pushing'>
        <div className='_pushing-content'>
          <div className={`_tip ${willCancel ? 'is-will-cancel' : ''}`}>
            {willCancel ? '松开发送，上滑取消' : '松开结束'}
          </div>
          <div className='_time'>{timeString}</div>
          <div>
            <span className='_recording-status'>
              {willCancel ? (
                cancelRecordSVG
              ) : (
                <>
                  {recordingSVG}
                  <span className='_animation'></span>
                </>
              )}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}

function ChatFooter({ userId, userToken }: { userId: string; userToken: string }) {
  const [mode, setMode] = useState<'text' | 'voice'>('text');
  const engine = useContext(ChatEngineContext);
  const [callVisible, setCallVisible] = useState(false);

  return (
    <>
      <div className='chat-footer'>
        <div className='_send-area'>
          {mode === 'voice' ? (
            <SendVoice onTypeChange={(type) => setMode(type)} />
          ) : (
            <SendText onTypeChange={(type) => setMode(type)} />
          )}
        </div>

        <Button className='_call-btn' disabled={callVisible} onClick={() => setCallVisible(true)}>
          {callSVG}
        </Button>
      </div>
      <Popup
        visible={callVisible}
        onMaskClick={() => setCallVisible(false)}
        destroyOnClose
        getContainer={getRootElement}
        bodyStyle={{ height: '100%' }}
      >
        <Call
          userId={userId}
          userToken={userToken}
          agentType={AICallAgentType.VoiceAgent}
          chatSyncConfig={
            new AICallChatSyncConfig(
              engine?.sessionId || '',
              engine?.agentInfo?.agentId || '',
              engine?.userInfo?.userId || ''
            )
          }
          autoCall
          onExit={() => setCallVisible(false)}
        />
      </Popup>
    </>
  );
}

export default ChatFooter;
