import useCallStore from '../store';

import './subtitle.less';

function Subtitle() {
  const currentSubtitle = useCallStore((state) => state.currentSubtitle);

  if (!currentSubtitle || !currentSubtitle?.data.text) return null;

  return (
    <div className='call-subtitle'>
      <span className='_box'>
        <span className={`_icon ${currentSubtitle?.source === 'agent' ? 'is-agent' : 'is-user'}`}></span>
        {currentSubtitle?.data.text}
      </span>
    </div>
  );
}
export default Subtitle;
