import { useContext, useState, useRef, useEffect, RefObject } from 'react';
import { ButtonRef, Toast, Button } from 'antd-mobile';
import { AIChatMessageState } from 'aliyun-auikit-aicall';

import { getRootElement } from '@/common/utils';
import ChatEngineContext from '../ChatEngineContext';
import { interruptSVG, keyboardSVG } from '../Icons';
import useChatStore from '../store';
import { OnTypeChange } from './type';
import { AIChatAttachmentUploader } from 'aliyun-auikit-aicall';

function smoothData(data: Uint8Array) {
  const smoothingFactor = 0.8;
  let previousValue = data[0];
  return data.map((value) => {
    const smoothedValue = previousValue * smoothingFactor + value * (1 - smoothingFactor);
    previousValue = smoothedValue;
    return smoothedValue;
  });
}

const MAX_TIME_IN_SECONDS = 60 * 3;

function VoiceSender({
  onTypeChange,
  uploaderRef,
  afterSend,
}: {
  onTypeChange: OnTypeChange;
  uploaderRef: RefObject<AIChatAttachmentUploader | undefined>;
  afterSend?: (success: boolean) => void;
}) {
  const engine = useContext(ChatEngineContext);
  const currentMessage = useChatStore((state) => state.currentMessage);
  const attachmentCanSend = useChatStore((state) => state.attachmentCanSend);
  const [pushing, setPushing] = useState(false);
  const [willCancel, setWillCancel] = useState(false);
  const [timeString, setTimeString] = useState('0"');
  const buttonRef = useRef<ButtonRef>(null);
  const startYRef = useRef(0);
  const isPushingRef = useRef(false);
  const willCancelRef = useRef(false);
  const timerRef = useRef(0);
  const startTimeRef = useRef(0);
  const visualizerRef = useRef<HTMLUListElement>(null);

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
      setTimeString('0"');
      isPushingRef.current = true;
      const msg = await engine?.startPushVoiceMessage(uploaderRef.current || undefined);
      if (!msg) return;
      const stream = engine?.currentRecordStream;
      if (stream) {
        startTimeRef.current = Date.now();
        timerRef.current = window.setInterval(() => {
          const seconds = Math.floor((Date.now() - startTimeRef.current) / 1000);
          if (seconds >= MAX_TIME_IN_SECONDS) {
            willCancelRef.current = true;
            onEnd();
          }
          setTimeString(`${seconds}"`);
        }, 1000);

        const audioContext = engine?.audioContext || new (window.AudioContext || window.webkitAudioContext)();
        const source = audioContext.createMediaStreamSource(stream);
        // 代码片段中改变 fftSize 的值
        const analyser = audioContext.createAnalyser();
        analyser.fftSize = 256; // 增加 FFT 尺寸
        const bufferLength = analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);

        source.connect(analyser);

        function draw() {
          requestAnimationFrame(draw);
          analyser.getByteFrequencyData(dataArray);

          const smoothedData = smoothData(dataArray);

          visualizerRef.current?.querySelectorAll('li').forEach((bar, index) => {
            const barHeight = (smoothedData[index] / 255) * 8 + 4;
            bar.style.height = `${barHeight}px`;
          });
        }

        draw();
      }
    };
    const onTouchStart = (e: TouchEvent) => {
      const target = e.currentTarget as HTMLButtonElement;
      if (target.disabled) {
        if (!attachmentCanSend) {
          Toast.show({ content: '部分图片上传中或上传失败', getContainer: getRootElement });
        }
        return;
      }
      const y = e.touches[0].clientY || 0;
      onStart(y);
    };
    const onMouseDown = (e: MouseEvent) => {
      const target = e.currentTarget as HTMLButtonElement;
      if (target.disabled) {
        if (!attachmentCanSend) {
          Toast.show({ content: '部分图片上传中或上传失败', getContainer: getRootElement });
        }
        return;
      }
      const y = e.clientY || 0;
      onStart(y);
    };

    const onEnd = async () => {
      setPushing(false);
      setTimeString('0"');
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
      if (!isPushingRef.current) {
        return;
      }

      isPushingRef.current = false;
      if (!willCancelRef.current) {
        try {
          const message = await engine?.finishPushVoiceMessage();
          afterSend?.(true);
          if (!message?.text) {
            Toast.show({ content: '未识别到文字', getContainer: getRootElement });
            return;
          }
          useChatStore.getState().sendMessage(message);
        } catch (error) {
          afterSend?.(false);
        }
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
        disabled={currentMessage?.message.messageState === AIChatMessageState.Printing || !attachmentCanSend}
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
          <div className={`_recording-status ${willCancel ? 'is-will-cancel' : ''}`}>
            <div className='_time'>{timeString}</div>
            <ul ref={visualizerRef} className='_wave'>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
              <li></li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}

export default VoiceSender;
