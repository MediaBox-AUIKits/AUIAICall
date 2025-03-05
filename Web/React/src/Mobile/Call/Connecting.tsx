import { animated, useSpring } from '@react-spring/web';

import './connecting.less';
import useCallStore from '@/Mobile/Call/store';
import { AICallState } from 'aliyun-auikit-aicall';

const Connecting = () => {
  const callState = useCallStore((state) => state.callState);

  const isTipVisible = callState === AICallState.None;
  const styles = useSpring({
    opacity: isTipVisible ? 1 : 0,
    y: isTipVisible ? 0 : -22,
  });

  return (
    <div className='connecting'>
      <animated.div className='_tip' style={styles}>
        点击拨打，开始进行语音交互
      </animated.div>

      {callState === AICallState.Connecting && (
        <ul className='_loading'>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
          <li></li>
        </ul>
      )}
    </div>
  );
};

export default Connecting;
