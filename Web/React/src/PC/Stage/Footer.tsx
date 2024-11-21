import { useContext, useEffect, useMemo, useRef, useState } from 'react';
import { Button, Dropdown, message } from 'antd';
import Icon, { DownOutlined } from '@ant-design/icons';

import useCallStore from '@/common/store';
import ARTCAICallEngine, { AICallAgentState, AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import Phone from './svg/phone.svg?react';
import Microphone from './svg/microphone.svg?react';
import MicrophoneClosed from './svg/microphone_closed.svg?react';
import PushMicrophone from './svg/push_microphone.svg?react';
import Camera from './svg/camera.svg?react';
import CameraClosed from './svg/camera_closed.svg?react';

import './footer.less';
import i18n from '@/common/i18n';
import ControllerContext from '@/common/ControlerContext';

interface CallActionsProps {
  onStop: () => void;
}

function CallTip() {
  const [seconds, setSeconds] = useState(0);
  const durationTimerRef = useRef(0);
  const startTimeRef = useRef(0);

  const [hasSpeaked, setHasSpeaked] = useState(false);
  const callState = useCallStore((state) => state.callState);
  const agentState = useCallStore((state) => state.agentState);
  const isSpeaking = useCallStore((state) => state.isSpeaking);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);

  useEffect(() => {
    if (isSpeaking) {
      setHasSpeaked(true);
    }
  }, [isSpeaking]);

  useEffect(() => {
    if (callState === AICallState.Connected) {
      setSeconds(0);
      startTimeRef.current = Date.now();
      durationTimerRef.current = window.setInterval(() => {
        setSeconds(Math.floor((Date.now() - startTimeRef.current) / 1000));
      }, 1000);
    } else {
      clearInterval(durationTimerRef.current);
    }
  }, [callState]);

  const tipText = useMemo(() => {
    if (agentState === AICallAgentState.Listening) {
      if (!hasSpeaked) {
        return i18n['status.listeningToStart'];
      }
      return i18n['status.listening'];
    }

    if (agentState === AICallAgentState.Thinking) {
      return i18n['status.thinking'];
    }

    if (agentState === AICallAgentState.Speaking) {
      if (enableVoiceInterrupt) {
        return i18n['status.speaking'];
      } else {
        return i18n['status.speakingNoInterrupt'];
      }
    }

    return '';
  }, [hasSpeaked, agentState, enableVoiceInterrupt]);

  const durationText = useMemo(() => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    return `${hours > 0 ? (hours < 10 ? '0' : '') + hours + ':' : ''}${minutes < 10 ? '0' : ''}${minutes}:${
      remainingSeconds < 10 ? '0' : ''
    }${remainingSeconds}`;
  }, [seconds]);

  return (
    <div className='call-tip'>
      {tipText}
      {callState === AICallState.Connected && <div className='_time'>{durationText}</div>}
    </div>
  );
}

interface MicrophoneListProps {
  type: 'microphone' | 'camera';
}

function DeviceList({ type }: MicrophoneListProps) {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [items, setItems] = useState<any[]>([]);
  const [current, setCurrent] = useState('');
  const controller = useContext(ControllerContext);

  useEffect(() => {
    const onDeviceChange = () => {
      const getPromise = type === 'microphone' ? ARTCAICallEngine.getMicrophoneList : ARTCAICallEngine.getCameraList;
      getPromise().then((list) => {
        setItems(
          list
            .filter((item) => item.deviceId !== 'default')
            .map((item) => ({
              key: item.deviceId,
              label: item.label,
            }))
        );
      });
    };

    onDeviceChange();
    navigator.mediaDevices.addEventListener('devicechange', onDeviceChange);
    return () => {
      return navigator.mediaDevices.removeEventListener('devicechange', onDeviceChange);
    };
  }, [type]);

  const menuItems = useMemo(() => {
    items.forEach((item) => {
      if (item.key === current) {
        item.disabled = true;
      } else {
        item.disabled = false;
      }
    });
    return [...items];
  }, [items, current]);

  const onChange = (key: string) => {
    setCurrent(key);
    if (type === 'microphone') {
      controller?.switchMicrophone(key);
    } else {
      controller?.switchCamera(key);
    }
  };

  // 当前麦克风不在列表中，重置为第一个
  if (current && menuItems.length > 0 && !menuItems.find((item) => item.key === current)) {
    onChange(menuItems[0].key);
  }

  return (
    <Dropdown
      trigger={['click']}
      overlayClassName='_dropdown-overlay'
      menu={{ items: menuItems, onClick: (item) => onChange(item.key) }}
    >
      <Button className='_dropdown'>
        <DownOutlined />
      </Button>
    </Dropdown>
  );
}

function CallFooter({ onStop }: CallActionsProps) {
  const agentType = useCallStore((state) => state.agentType);
  const microphoneMuted = useCallStore((state) => state.microphoneMuted);
  const cameraMuted = useCallStore((state) => state.cameraMuted);
  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const pushingToTalk = useCallStore((state) => state.pushingToTalk);
  const [messageApi, contextHolder] = message.useMessage();

  const controller = useContext(ControllerContext);

  const toggleMicrophoneMuted = () => {
    if (enablePushToTalk) return;
    const to = !useCallStore.getState().microphoneMuted;
    controller?.muteMicrophone(to);
    messageApi.success(to ? '麦克风已关闭' : '麦克风已开启');
    useCallStore.setState({
      microphoneMuted: to,
    });
  };

  const toggleCameraMuted = () => {
    const to = !useCallStore.getState().cameraMuted;
    controller?.muteCamera(to);
    messageApi.success(to ? '摄像头已关闭' : '摄像头已开启');
    useCallStore.setState({
      cameraMuted: to,
    });
  };

  const microphoneBtn = (
    <li className='call-btn'>
      <DeviceList type='microphone' />
      <Button onClick={toggleMicrophoneMuted} className='_mic-btn'>
        {enablePushToTalk ? (
          <Icon component={PushMicrophone} />
        ) : (
          <Icon component={microphoneMuted ? MicrophoneClosed : Microphone} />
        )}
      </Button>
      <div className='_label'>
        {enablePushToTalk ? (
          <span className='_text'>{pushingToTalk ? '松开空格发送' : '长按空格，开始讲话'}</span>
        ) : (
          <span className='_text'>{microphoneMuted ? '开' : '关'}麦克风</span>
        )}
      </div>
    </li>
  );

  return (
    <div className='call-footer'>
      {contextHolder}
      <CallTip />
      <div className='call-actions'>
        <ul>
          {agentType === AICallAgentType.VisionAgent && microphoneBtn}
          <li className='call-btn'>
            <Button onClick={onStop}>
              <Icon component={Phone} />
            </Button>
            <div className='_label'>
              <span className='_text'>挂断</span>
            </div>
          </li>
          {agentType === AICallAgentType.VisionAgent ? (
            <li className='call-btn'>
              <DeviceList type='camera' />
              <Button onClick={toggleCameraMuted}>
                <Icon component={cameraMuted ? CameraClosed : Camera} />
              </Button>
              <div className='_label'>
                <span className='_text'>开摄像头</span>
              </div>
            </li>
          ) : (
            microphoneBtn
          )}
        </ul>
      </div>
    </div>
  );
}

export default CallFooter;
