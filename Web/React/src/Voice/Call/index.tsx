import { Button, Popover } from 'antd';
import Icon from '@ant-design/icons';

import Setting from './svg/setting.svg?react';

import CallStatus from './Status';
import CallActions from './Actions';

import './index.less';
import CallSettings from './Settings';
import CallSubtitle from './Subtitle';
import CallTip from './Tip';

interface CallProps {
  onStop: () => void;
  toggleMicrophoneMuted: () => void;
}

function Call({ onStop, toggleMicrophoneMuted }: CallProps) {
  return (
    <div className='voice-block voice-call'>
      <div className='voice-block-title'>
        <div className='_text'>小云</div>
        <div className='_extra'>
          <Popover
            overlayClassName='voice-call-settings-content'
            placement='bottomRight'
            arrow={false}
            title='设置'
            content={<CallSettings />}
            trigger='click'
          >
            <Button>
              <Icon component={Setting} />
              设置
            </Button>
          </Popover>
        </div>
      </div>
      <div className='voice-block-bd voice-call-bd'>
        <div className='voice-call-info'>
          <CallSubtitle />
          <CallStatus />
          <CallTip />
        </div>
        <CallActions onStop={onStop} toggleMicrophoneMuted={toggleMicrophoneMuted} />
      </div>
    </div>
  );
}

export default Call;
