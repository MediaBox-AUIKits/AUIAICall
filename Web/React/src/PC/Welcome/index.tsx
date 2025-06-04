import { ReactNode } from 'react';
import { Button } from 'antd';
import Icon, { ExclamationOutlined, LoadingOutlined } from '@ant-design/icons';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import Voice from './svg/voice.svg?react';
import Avatar from './svg/avatar.svg?react';
import Vision from './svg/vision.svg?react';

import useCallStore from '@/Mobile/Call/store';

import './index.less';
import { useTranslation } from '@/common/i18nContext';

interface CallWelcomeProps {
  onAgentTypeSelected: (agentType: AICallAgentType) => void;
}

function CallWelcome({ onAgentTypeSelected }: CallWelcomeProps) {
  const { t } = useTranslation();

  const callState = useCallStore((state) => state.callState);
  const callErrorMessage = useCallStore((state) => state.callErrorMessage);

  let content: ReactNode = null;
  if (callState === AICallState.Connecting) {
    content = (
      <>
        <LoadingOutlined className='_loading' />
        <div className='_tip'>{t('system.connecting')}</div>
      </>
    );
  } else if (callState === AICallState.Error) {
    content = (
      <>
        <ExclamationOutlined className='_error' />
        <div className='_tip'>{callErrorMessage || t('error.unknown')}</div>
        <div className='_backBtn'>
          <Button
            type='primary'
            onClick={() => {
              useCallStore.setState({
                callState: AICallState.None,
              });
            }}
          >
            &nbsp;{t('common.back')}&nbsp;
          </Button>
        </div>
      </>
    );
  } else {
    content = (
      <>
        <div className='_start-btns'>
          <div>
            <Button
              className='_start-btn'
              onClick={() => {
                onAgentTypeSelected(AICallAgentType.VoiceAgent);
              }}
            >
              <Icon component={Voice} />
            </Button>
            <div className='_tip'>{t('agent.voice')}</div>
          </div>
          <div style={{ width: 28 }} />
          <div>
            <Button
              className='_start-btn'
              onClick={() => {
                onAgentTypeSelected(AICallAgentType.AvatarAgent);
              }}
            >
              <Icon component={Avatar} />
            </Button>
            <div className='_tip'>{t('agent.avatar')}</div>
          </div>
          <div style={{ width: 28 }} />
          <div>
            <Button
              className='_start-btn'
              onClick={() => {
                onAgentTypeSelected(AICallAgentType.VisionAgent);
              }}
            >
              <Icon component={Vision} />
            </Button>
            <div className='_tip'>{t('agent.vision')}</div>
          </div>
        </div>
      </>
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
