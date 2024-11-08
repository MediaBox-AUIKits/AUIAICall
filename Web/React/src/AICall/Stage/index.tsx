import { Alert } from 'antd';

import CallFooter from './Footer';
import CallSettings from './Settings';
import CallSubtitle from './Subtitle';

import { AICallAgentType } from 'aliyun-auikit-aicall';
import Voice from './Voice';
import Video from './Video';

import './index.less';
import useCallStore from '../store';
import ArrowBtn from '../../components/ArrowBtn';
import { useEffect, useState } from 'react';
import Vision from './Vision';


interface StageProps {
  showMessage: boolean;
  onStop: () => void;
  onShowMessage: () => void;
}

function Stage({ onStop, showMessage: propsShowMessage, onShowMessage }: StageProps) {
  const agentType = useCallStore((state) => state.agentType);
  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const cameraMuted = useCallStore((state) => state.cameraMuted);
  const [showMessage, setShowMessage] = useState(propsShowMessage);

  useEffect(() => {
    let timer = 0;
    if (!propsShowMessage) {
      timer = window.setTimeout(() => {
        setShowMessage(false);
        timer = 0;
      }, 300);
    } else {
      setShowMessage(true);
    }

    return () => {
      if (timer) {
        clearTimeout(timer);
      }
    };
  }, [propsShowMessage]);

  let CharacterComponent = Voice;
  if (agentType === AICallAgentType.AvatarAgent) {
    CharacterComponent = Video;
  } else if (agentType === AICallAgentType.VisionAgent) {
    CharacterComponent = Vision;
  }

  return (
    <div
      className={`call-block stage-block ${
        agentType === AICallAgentType.AvatarAgent || (agentType === AICallAgentType.VisionAgent && !cameraMuted)
          ? 'has-video'
          : ''
      }`}
    >
      {!showMessage && (
        <ArrowBtn
          type={agentType === AICallAgentType.AvatarAgent ? 'rightToRight' : 'leftToLeft'}
          onClick={onShowMessage}
        />
      )}
      <div className='call-block-container'>
        <div className='call-block-title'>
          <div className='_text'>小云</div>
          <div className='_extra'>
            
            <CallSettings />
          </div>
        </div>
        <div className='call-block-bd stage-bd'>
          {enablePushToTalk && (
            <Alert
              className='stage-push-to-talk-tip'
              message='已开启对讲机模式，长按空格开始讲话，对讲机状态下，麦克风默认开启。'
              closable
            />
          )}
          <CharacterComponent />
          <CallSubtitle />
          <CallFooter onStop={onStop} />
        </div>
      </div>
    </div>
  );
}

export default Stage;
