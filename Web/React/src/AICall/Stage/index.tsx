import { Button, Popover } from 'antd';
import Icon from '@ant-design/icons';

import CallFooter from './Footer';
import SettingSvg from './svg/setting.svg?react';
import CallSettings from './Settings';
import CallSubtitle from './Subtitle';

import { AICallAgentType } from 'aliyun-auikit-aicall';
import Voice from './Voice';
import Video from './Video';

import './index.less';
import useCallStore from '../store';
import ArrowBtn from '../../components/ArrowBtn';
import { useEffect, useState } from 'react';

interface StageProps {
  showMessage: boolean;
  onStop: () => void;
  toggleMicrophoneMuted: () => void;
  onShowMessage: () => void;
}

function Stage({ onStop, toggleMicrophoneMuted, showMessage: propsShowMessage, onShowMessage }: StageProps) {
  const agentType = useCallStore((state) => state.agentType);
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

  return (
    <div className='call-block stage-block'>
      {!showMessage && (
        <ArrowBtn
          type={agentType === AICallAgentType.VoiceAgent ? 'leftToLeft' : 'rightToRight'}
          onClick={onShowMessage}
        />
      )}
      <div className='call-block-container'>
        <div className='call-block-title'>
          <div className='_text'>小云</div>
          <div className='_extra'>
            <Popover
              overlayClassName='stage-settings-content'
              placement='bottomRight'
              arrow={false}
              title='设置'
              content={<CallSettings />}
              trigger='click'
            >
              <Button>
                <Icon component={SettingSvg} />
                设置
              </Button>
            </Popover>
          </div>
        </div>
        <div className='call-block-bd stage-bd'>
          {agentType === AICallAgentType.AvatarAgent ? <Video /> : <Voice />}
          <CallSubtitle />
          <CallFooter onStop={onStop} toggleMicrophoneMuted={toggleMicrophoneMuted} />
        </div>
      </div>
    </div>
  );
}

export default Stage;
