import { useContext, useEffect, useRef } from 'react';

import ControllerContext from '../../ControlerContext';
import HeroLottie from './HeroLottie';
import './index.less';

function VoiceHero() {
  const controller = useContext(ControllerContext);
  const lottieContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!controller) return;
    const hero = new HeroLottie(lottieContainerRef.current!, controller);
    const onCallEnd = () => {
      hero?.destroy();
    };
    controller.on('AICallEnd', onCallEnd);
    return () => {
      controller.off('AICallEnd', onCallEnd);
      hero?.destroy();
    };
  }, [controller]);

  return (
    <div className='voice-hero'>
      <div className='_inner'>
        <div className='_back'></div>
        <div className='_containers' ref={lottieContainerRef}></div>
      </div>
    </div>
  );
}

export default VoiceHero;
