import { useContext, useEffect, useMemo, useRef } from 'react';
import './thinkingAndTalking.less';
import ControllerContext from '@/common/ControlerContext';
import useCallStore from '@/common/store';
import { AICallAgentState } from 'aliyun-auikit-aicall';

// 音量数组平均后转化为 0-32 范围
function format(data: Uint8Array) {
  let sum = 0;
  for (let i = 0; i < data.length; i++) {
    sum += data[i];
  }
  let value = sum / data.length;
  if (value < 0) value = 0;
  if (value > 256) value = 256;

  // 使用对数压缩
  // 首先将输入标准化到 0 到 1 的范围
  const normalizedValue = value / 256;

  // 使用 Math.pow 进行指数缩放
  const exponent = 1.2;
  const compressed = Math.pow(normalizedValue, 1 / exponent);

  // 缩放到 0 到 32 的输出范围
  const output = compressed * 32;

  return Math.floor(output);
}

const FFTSize = 256;
// 人声频率范围，从 1kHz 到 12kHz
const VoiceStartRate = 1000;
const VoiceEndRate = 12000;

function VoiceThinkingAndTalking() {
  const controller = useContext(ControllerContext);
  const listRef = useRef<HTMLUListElement>(null);
  const agentState = useCallStore((state) => state.agentState);
  const sourceNodeRef = useRef<MediaStreamAudioSourceNode | undefined>(undefined);

  const audioContext = useMemo(() => new (window.AudioContext || window.webkitAudioContext)(), []);
  useEffect(() => {
    const createSourceNode = (audioElement: HTMLAudioElement) => {
      const stream = audioElement.srcObject;
      if (!stream) return;
      sourceNodeRef.current = audioContext.createMediaStreamSource(stream as MediaStream);
    };

    if (controller?.agentAudioElement) {
      createSourceNode(controller.agentAudioElement);
      return;
    }

    const onAudioElement = (audioElement?: HTMLAudioElement) => {
      if (audioElement) {
        createSourceNode(audioElement);
      }
    };
    controller?.on('AICallAgentAudioSubscribed', onAudioElement);
    return () => {
      controller?.off('AICallAgentAudioSubscribed', onAudioElement);
    };
  }, [controller, audioContext]);

  useEffect(() => {
    let middleIndex = 5;
    let intervalId: number;
    let analyser: AnalyserNode | undefined;
    if (agentState === AICallAgentState.Thinking) {
      intervalId = window.setInterval(() => {
        for (let i = 0; i < 16; i++) {
          const li = listRef.current?.children[i] as HTMLLIElement;
          let height = 4;
          const delta = Math.abs(middleIndex - i);
          if (delta === 0) {
            height = 32;
          } else if (delta === 1) {
            height = 16;
          } else if (delta === 2) {
            height = 8;
          }
          if (li) {
            li.style.height = `${height}px`;
          }
        }
        middleIndex++;
        if (middleIndex > 12) {
          middleIndex = 5;
        }
      }, 200);
    } else {
      if (!sourceNodeRef.current) return;

      audioContext.resume();
      const analyser = audioContext.createAnalyser();
      analyser.fftSize = FFTSize;
      const pcmData = new Uint8Array(analyser.frequencyBinCount);
      sourceNodeRef.current.connect(analyser);
      analyser.connect(audioContext.createMediaStreamDestination());

      const startIndex = Math.floor((analyser.frequencyBinCount * VoiceStartRate) / audioContext.sampleRate);
      const count = Math.ceil(
        (analyser.frequencyBinCount * (VoiceEndRate - VoiceStartRate)) / audioContext.sampleRate / 16
      );

      intervalId = window.setInterval(() => {
        analyser?.getByteFrequencyData(pcmData);
        for (let i = 0; i < 16; i++) {
          const data = pcmData.slice(startIndex + i * count, startIndex + (i + 1) * count);
          const li = listRef.current?.children[i] as HTMLLIElement;
          if (li) {
            li.style.height = `${4 + format(data)}px`;
          }
        }
      }, 100);
    }

    return () => {
      middleIndex = 5;
      for (let i = 0; i < 16; i++) {
        const li = listRef.current?.children[i] as HTMLLIElement;
        if (li) {
          li.style.height = `4px`;
        }
      }
      window.clearInterval(intervalId);
      sourceNodeRef.current?.disconnect();
      analyser?.disconnect();
      analyser = undefined;
    };
  }, [agentState, audioContext]);

  return (
    <div className='voice-tnt'>
      <ul ref={listRef}>
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
  );
}
export default VoiceThinkingAndTalking;
