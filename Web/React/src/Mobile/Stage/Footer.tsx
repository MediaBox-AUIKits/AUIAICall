import { useContext } from 'react';
import { Button } from 'antd-mobile';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import ControllerContext from '@/common/ControlerContext';
import useCallStore from '@/common/store';
import { CallPhoneSVG, CameraClosedSVG, CameraSVG, CameraSwitchSVG, MicrophoneClosedSVG, MicrophoneSVG } from './Icons';

import './footer.less';

interface CallFooterProps {
  onCall: () => void;
  onStop: () => void;
}

function Footer({ onStop, onCall }: CallFooterProps) {
  const controller = useContext(ControllerContext);
  const agentType = useCallStore((state) => state.agentType);
  const callState = useCallStore((state) => state.callState);
  const microphoneMuted = useCallStore((state) => state.microphoneMuted);
  const cameraMuted = useCallStore((state) => state.cameraMuted);
  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);

  const toggleMicrophoneMuted = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    if (enablePushToTalk) return;
    const to = !useCallStore.getState().microphoneMuted;
    controller?.muteMicrophone(to);
    // messageApi.success(to ? '麦克风已关闭' : '麦克风已开启');
    useCallStore.setState({
      microphoneMuted: to,
    });
  };

  const toggleCameraMuted = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    const to = !useCallStore.getState().cameraMuted;
    controller?.muteCamera(to);
    // messageApi.success(to ? '摄像头已关闭' : '摄像头已开启');
    useCallStore.setState({
      cameraMuted: to,
    });
  };
  const switchCamera = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    controller?.switchCamera();
  };

  const onCallClick = (e: React.MouseEvent<HTMLButtonElement, MouseEvent>) => {
    e.stopPropagation();
    if (callState === AICallState.Connected) {
      onStop();
    } else {
      onCall();
    }
  };

  return (
    <div className='footer'>
      <ul className='_action-list'>
        {callState === AICallState.Connected && agentType === AICallAgentType.VisionAgent && (
          <li className='_camera'>
            {!cameraMuted && (
              <div className='_camera-switch'>
                <Button onClick={switchCamera}>{CameraSwitchSVG}</Button>
                <div className='_label'>镜头翻转</div>
              </div>
            )}
            <Button onClick={toggleCameraMuted}>{cameraMuted ? CameraClosedSVG : CameraSVG}</Button>
            <div className='_label'>{cameraMuted ? '摄像头已关' : '关摄像头'}</div>
          </li>
        )}
        <li
          className={`_call ${
            callState === AICallState.Connected || callState === AICallState.Connecting ? 'is-connected' : ''
          }`}
        >
          <Button onClick={onCallClick} disabled={callState === AICallState.Connecting}>
            {CallPhoneSVG}
          </Button>
          <div className='_label'>
            {callState === AICallState.Connected || callState === AICallState.Connecting ? '挂断' : '拨打'}
          </div>
        </li>
        {callState === AICallState.Connected && (
          <li className='_microphone'>
            <Button onClick={toggleMicrophoneMuted}>{microphoneMuted ? MicrophoneClosedSVG : MicrophoneSVG}</Button>
            <div className='_label'>{microphoneMuted ? '麦克风已关' : '关麦克风'}</div>
          </li>
        )}
      </ul>
    </div>
  );
}
export default Footer;
