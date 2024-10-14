import useCallStore from '../../store';
import { AICallAgentState } from 'aliyun-auikit-aicall';
import { useEffect, useRef, useState } from 'react';

import './index.less';

const AgentStateClassMap = {
  [AICallAgentState.Listening]: '_is-listening',
  [AICallAgentState.Thinking]: '_is-thinking',
  [AICallAgentState.Speaking]: '_is-talking',
};

function Voice() {
  const watcherElementRef = useRef<HTMLDivElement>(null);
  const [animating, setAnimating] = useState(false);
  const [agentState, setAgentState] = useState(AICallAgentState.Listening);
  const storeAgentState = useCallStore((state) => state.agentState);
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const [showSpeaking, setShowSpeaking] = useState(false);
  const speakingTimerRef = useRef(0);
  const animationTimerRef = useRef(0);

  // 先停止动画，再执行切换状态进行 transition
  useEffect(() => {
    setAnimating(false);
    if (animationTimerRef.current) {
      clearTimeout(animationTimerRef.current);
    }
    setTimeout(() => {
      setAgentState(storeAgentState);
      // 兜底 350ms 开始动画
      animationTimerRef.current = window.setTimeout(() => {
        setAnimating(true);
      }, 350);
    }, 0);
  }, [storeAgentState]);

  useEffect(() => {
    if (isSpeaking === showSpeaking) return;
    // 未显示切换为显示
    if (isSpeaking) {
      // 如果准备停止显示，则取消
      if (speakingTimerRef.current) {
        clearTimeout(speakingTimerRef.current);
      }
      setShowSpeaking(true);
    } else {
      speakingTimerRef.current = window.setTimeout(() => {
        setShowSpeaking(false);
      }, 200);
    }
  }, [isSpeaking, showSpeaking]);

  useEffect(() => {
    const transitionEnd = () => {
      if (animationTimerRef.current) {
        clearTimeout(animationTimerRef.current);
      }
      setAnimating(true);
    };
    // 默认 transition 结束开始动画
    watcherElementRef.current?.addEventListener('transitionend', transitionEnd);
    return () => {
      watcherElementRef.current?.removeEventListener('transitionend', transitionEnd);
    };
  }, []);

  return (
    <div className='voice-show'>
      <div className='_box'>
        <div
          className={`voice-agent-status ${AgentStateClassMap[agentState || AICallAgentState.Listening]} ${
            animating ? 'animating' : ''
          }`}
        >
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div ref={watcherElementRef}></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
        </div>

        <div className={`voice-user-status ${isSpeaking ? '_is-talking' : ''}`}>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
          <div></div>
        </div>
      </div>
    </div>
  );
}

export default Voice;
