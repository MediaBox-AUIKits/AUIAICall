import { Button } from 'antd';
import Icon from '@ant-design/icons';

// import Pause from './svg/pause.svg?react';
import Phone from './svg/phone.svg?react';
import Microphone from './svg/microphone.svg?react';
import MicrophoneClosed from './svg/microphone_closed.svg?react';

import './actions.less';
import useCallStore from '../store';

interface CallActionsProps {
  onStop: () => void;
  toggleMicrophoneMuted: () => void;
}

function CallActions({ onStop, toggleMicrophoneMuted }: CallActionsProps) {
  const microphoneMuted = useCallStore((state) => state.microphoneMuted);

  return (
    <div className='voice-call-actions'>
      <ul>
        {/* <li className='voice-call-btn'>
          <Button>
            <Icon component={Pause} />
          </Button>
          <div className='_label'>
            <span className='_text'>暂停通话</span>
          </div>
        </li> */}
        <li className='voice-call-btn'>
          <Button onClick={onStop}>
            <Icon component={Phone} />
          </Button>
          <div className='_label'>
            <span className='_text'>挂断</span>
          </div>
        </li>
        <li className='voice-call-btn'>
          <Button onClick={toggleMicrophoneMuted}>
            <Icon component={microphoneMuted ? MicrophoneClosed : Microphone} />
          </Button>
          <div className='_label'>
            <span className='_text'>{microphoneMuted ? '开' : '关'}麦克风</span>
          </div>
        </li>
      </ul>
    </div>
  );
}

export default CallActions;
