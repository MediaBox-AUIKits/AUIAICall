import { AICallAgentState, AICallState } from 'aliyun-auikit-aicall';
import { useContext, useEffect, useMemo, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { isMobile } from '@/common/utils';
import useCallStore from 'call/store';

import ControllerContext from '../ControlerContext';

import './tip.less';

class AudioVisualizer {
  audioContext?: AudioContext;
  analyser?: AnalyserNode;
  waveOffset = 0;
  lastVolume = 0;
  animationId?: number;
  dots: HTMLLIElement[] = [];

  constructor(container: HTMLDivElement, audioTrack: MediaStreamTrack) {
    this.initializeDots(container);
    this.start(audioTrack);
  }
  initializeDots(container: HTMLDivElement) {
    this.dots = Array.prototype.slice.call(container.querySelectorAll('li'));
  }

  start(audioTrack: MediaStreamTrack) {
    this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    this.analyser = this.audioContext.createAnalyser();

    const source = this.audioContext.createMediaStreamSource(new MediaStream([audioTrack]));
    source.connect(this.analyser);

    // 设置分析器参数
    this.analyser.fftSize = 256;
    this.analyser.smoothingTimeConstant = 0.8;

    const bufferLength = this.analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    const visualizeFrame = () => {
      if (!this.analyser) return;

      // 获取频域数据
      this.analyser.getByteFrequencyData(dataArray);

      // 计算平均音量
      let sum = 0;
      for (let i = 0; i < bufferLength; i++) {
        sum += dataArray[i];
      }
      const average = sum / bufferLength;

      // 将平均音量映射到 0-1 范围
      const normalizedVolume = average / 255;

      // 更新可视化效果
      this.updateVisualization(normalizedVolume);

      this.animationId = requestAnimationFrame(visualizeFrame);
    };

    visualizeFrame();
  }

  updateVisualization(volume: number) {
    // 波浪模式：波浪形的视觉效果
    const intensity = volume;

    // 波浪偏移随时间变化
    this.waveOffset += 0.1;

    this.dots.forEach((dot, index) => {
      // 计算波浪值 (0-1)
      const waveValue = (Math.sin(this.waveOffset + Math.abs(Math.floor(this.dots.length / 2) - index) * 0.4) + 1) / 2;

      const finalIntensity = intensity * waveValue;
      const smoothIntensity = Math.pow(finalIntensity, 0.8);
      dot.style.opacity = `${Math.max(0.1, smoothIntensity) * 5}`;
    });
    this.lastVolume = volume;
  }

  stop() {
    this.audioContext?.close();
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
      this.animationId = undefined;
    }
  }
}

function CallTip() {
  const { t } = useTranslation();
  const controller = useContext(ControllerContext);

  const [hasSpeaked, setHasSpeaked] = useState(false);
  const agentState = useCallStore((state) => state.agentState);
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);

  const indicatorRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isSpeaking) {
      setHasSpeaked(true);
    }
  }, [isSpeaking]);

  useEffect(() => {
    let visualizer: AudioVisualizer;
    const handleLocalVolume = async () => {
      const audioTrack = await controller?.engine?.getRTCInstance?.getAudioTrack();
      if (!audioTrack || !indicatorRef.current) return;
      visualizer = new AudioVisualizer(indicatorRef.current, audioTrack);
    };
    controller?.addListener('AICallBegin', handleLocalVolume);
    if (controller?.state === AICallState.Connected) {
      handleLocalVolume();
    }

    return () => {
      controller?.removeListener('AICallBegin', handleLocalVolume);
      visualizer?.stop();
    };
  }, [controller]);

  const tipText = useMemo(() => {
    if (agentState === AICallAgentState.Listening) {
      if (!hasSpeaked) {
        return t('status.listeningToStart');
      }
      return t('status.listening');
    }

    if (agentState === AICallAgentState.Thinking) {
      return t('status.thinking');
    }

    if (agentState === AICallAgentState.Speaking) {
      if (enableVoiceInterrupt) {
        if (isMobile()) {
          return t('status.mobile.speaking');
        }
        return t('status.speaking');
      } else {
        if (isMobile()) {
          return t('status.mobile.speakingNoInterrupt');
        }
        return t('status.speakingNoInterrupt');
      }
    }

    return '';
  }, [hasSpeaked, agentState, enableVoiceInterrupt, t]);

  return (
    <div className='tip'>
      <div className='_indicator' ref={indicatorRef}>
        <ol>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
        </ol>
      </div>
      <div className='_text'>{tipText}</div>
    </div>
  );
}

export default CallTip;
