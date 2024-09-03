import { Button } from 'antd';
import Icon, { ExclamationOutlined, LoadingOutlined } from '@ant-design/icons';

import Start from './svg/start.svg?react';

import useCallStore from '../store';
import { AICallState } from '../../aiCall/type';

import './index.less';
import { ReactNode } from 'react';

interface CallWelcomeProps {
  onStart: () => void;
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
      </>
    );
  } else {
    content = (
      <>
        <Button className='_start' onClick={onStart}>
          <Icon component={Start} />
        </Button>
        <div className='_tip'>开始体验</div>
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
