import { useContext, useEffect, useRef, useState } from 'react';
import { animated, useSpring } from '@react-spring/web';

import { AICallAgentState } from 'aliyun-auikit-aicall';
import './index.less';
import useCallStore from '@/common/store';
import ControllerContext from '@/common/ControlerContext';
import VoiceListening from './Listening';
import VoiceThinkingAndTalking from './ThinkingAndTalking';

function Voice() {
  const controller = useContext(ControllerContext);
  const [agentState, setAgentState] = useState(AICallAgentState.Listening);
  const storeAgentState = useCallStore((state) => state.agentState);
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const [showSpeaking, setShowSpeaking] = useState(false);
  const speakingTimerRef = useRef(0);

  const avatarUrl = controller?.config.templateConfig?.avatarUrl;

  const listeningStyles = useSpring({
    opacity: agentState === AICallAgentState.Listening ? 1 : 0,
  });
  const TnTStyles = useSpring({
    opacity: agentState === AICallAgentState.Thinking || agentState === AICallAgentState.Speaking ? 1 : 0,
  });

  // 先停止动画，再执行切换状态进行 transition
  useEffect(() => {
    setTimeout(() => {
      setAgentState(storeAgentState);
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

  return (
    <div className='character voice'>
      <div className='_box'>
        {avatarUrl ? (
          <>
            <div className='_agent-status-with-avatar'>
              <div></div>
            </div>
            <div className='_avatar'>
              <img src={avatarUrl} />
            </div>
          </>
        ) : (
          <div className='_agent-status'>
            <animated.div style={listeningStyles}>
              <VoiceListening />
            </animated.div>
            <animated.div style={TnTStyles}>
              <VoiceThinkingAndTalking />
            </animated.div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Voice;
