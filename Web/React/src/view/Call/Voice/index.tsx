import useCallStore from 'call/store';

import VoiceAvatarImage from './AvatarImage';
import VoiceHero from './Hero';

import './index.less';

function Voice() {
  const voiceAvatarUrl = useCallStore((state) => state.voiceAvatarUrl);

  return (
    <div className='actor voice'>{voiceAvatarUrl ? <VoiceAvatarImage url={voiceAvatarUrl} /> : <VoiceHero />}</div>
  );
}

export default Voice;
