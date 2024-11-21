import { useContext, useEffect, useMemo, useRef } from 'react';
import './thinkingAndTalking.less';
import ControllerContext from '@/common/ControlerContext';
import useCallStore from '@/common/store';
import { AICallAgentState } from 'aliyun-auikit-aicall';

function average(data: Uint8Array) {
  let sum = 0;
  for (let i = 0; i < data.length; i++) {
    sum += data[i];
  }
  return data.length > 0 ? sum / data.length : 0;
}

function VoiceThinkingAndTalking() {
  const controller = useContext(ControllerContext);
  const listRef = useRef<HTMLUListElement>(null);
  const agentState = useCallStore((state) => state.agentState);
  const sourceNodeRef = useRef<MediaStreamAudioSourceNode | undefined>(undefined);

  const audioContext = useMemo(() => new (window.AudioContext || window.webkitAudioContext)(), []);
  useEffect(() => {
    const createSourceNode = (audioElement: HTMLAudioElement) => {
      const stream = audioElement.srcObject;
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
      analyser.fftSize = 256;
      const pcmData = new Uint8Array(analyser.frequencyBinCount);
      sourceNodeRef.current.connect(analyser);
      analyser.connect(audioContext.createMediaStreamDestination());

      intervalId = window.setInterval(() => {
        analyser?.getByteFrequencyData(pcmData);
        for (let i = 0; i < 16; i++) {
          const data = pcmData.slice(i * 16, (i + 1) * 16);
          const li = listRef.current?.children[i] as HTMLLIElement;
          if (li) {
            li.style.height = `${4 + Math.floor(average(data) / 8)}px`;
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
