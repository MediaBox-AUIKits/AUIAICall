import { animated, useSpring } from '@react-spring/web';
import { AICallState } from 'aliyun-auikit-aicall';

import { useTranslation } from '@/common/i18nContext';
import useCallStore from 'call/store';

import './connecting.less';

const Connecting = () => {
  const { t } = useTranslation();

  const callState = useCallStore((state) => state.callState);

  const isTipVisible = callState === AICallState.None || callState === AICallState.Over;
  const styles = useSpring({
    opacity: isTipVisible ? 1 : 0,
    y: isTipVisible ? 0 : -22,
  });

  return (
    <div className='connecting'>
      <animated.div className='_tip' style={styles}>
        {t('actions.clickToCall')}
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
