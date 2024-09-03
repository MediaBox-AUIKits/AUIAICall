import useCallStore from '../store';

import './subtitle.less';

function CallSubtitle() {
  const currentSubtitle = useCallStore((state) => state.currentSubtitle);

  if (!currentSubtitle || !currentSubtitle?.data.text) return null;

  return (
    <div className='voice-call-subtitle'>
      <span className={`_icon ${currentSubtitle?.source === 'agent' ? 'isAgent' : 'isUser'}`}></span>
      {currentSubtitle?.data.text}
    </div>
  );
}
export default CallSubtitle;
