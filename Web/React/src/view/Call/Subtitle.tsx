import useCallStore from '@/view/Call/store';

import { UserSVG } from './Icons';
import './subtitle.less';

function Subtitle() {
  const currentSubtitle = useCallStore((state) => state.currentSubtitle);

  if (!currentSubtitle || !currentSubtitle?.data.text) return null;

  let text = currentSubtitle.data.text;

  return (
    <div className='subtitle' onClick={(e) => e.stopPropagation()}>
      <div className='_inner'>
        <div className='_source'>
          {currentSubtitle.source === 'agent' ? <div className='_agent-icon'></div> : UserSVG}
        </div>
        <div className='_text'>{text}</div>
      </div>
    </div>
  );
}

export default Subtitle;
