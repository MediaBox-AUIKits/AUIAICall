import { ReactNode } from 'react';
import { Button } from 'antd';
import Icon, { ExclamationOutlined, LoadingOutlined } from '@ant-design/icons';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import Voice from './svg/voice.svg?react';
import Avatar from './svg/avatar.svg?react';

import useCallStore from '../store';

import './index.less';
import i18n from '../i18n';

interface CallWelcomeProps {
  onStart: (agentType: AICallAgentType) => void;
}

function CallWelcome({ onStart }: CallWelcomeProps) {
  const callState = useCallStore((state) => state.callState);
  const callErrorMessage = useCallStore((state) => state.callErrorMessage);

  let content: ReactNode = null;
  if (callState === AICallState.Connecting) {
    content = (
      <>
        <LoadingOutlined className='_loading' />
        <div className='_tip'>接通中，请稍后</div>
      </>
    );
  } else if (callState === AICallState.Error) {
    content = (
      <>
        <ExclamationOutlined />
        <div className='_tip'>{callErrorMessage || '通话异常'}</div>
        <div className='_backBtn'>
          <Button
            type='primary'
            onClick={() => {
              useCallStore.setState({
                callState: AICallState.None,
              });
            }}
          >
            &nbsp;返回&nbsp;
          </Button>
        </div>
      </>
    );
  } else {
    content = (
      <div className='_start-btns'>
        <div>
          <Button
            className='_start-btn'
            onClick={() => {
              onStart(AICallAgentType.VoiceAgent);
            }}
          >
            <Icon component={Voice} />
          </Button>
          <div className='_tip'>{i18n['agent.voice']}</div>
        </div>
        <div style={{ width: 60 }} />
        <div>
          <Button
            className='_start-btn'
            onClick={() => {
              onStart(AICallAgentType.AvatarAgent);
            }}
          >
            <Icon component={Avatar} />
          </Button>
          <div className='_tip'>{i18n['agent.avatar']}</div>
        </div>
      </div>
    );
  }

  return (
    <div className='welcome'>
      <div className='welcome-hero'>
        <div className='welcome-hero-bd'>
          <div className='welcome-button-box'>{content}</div>
        </div>
      </div>
    </div>
  );
}

export default CallWelcome;
