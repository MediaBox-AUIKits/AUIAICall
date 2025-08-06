import { AICallAgentType } from 'aliyun-auikit-aicall';
import { Button, SafeArea } from 'antd-mobile';
import { useContext, useMemo, useState } from 'react';

import useCallStore from '@/view/Call/store';

import { useTranslation } from '@/common/i18nContext';
import ControllerContext from '@/view/Call/ControlerContext';
import './header.less';
import { BackWithLineSVG } from './Icons';
import Setting from './Setting';
import SubtitleList from './SubtitleList';


function Header({ onExit }: { onExit: () => void }) {
  const { t } = useTranslation();
  const agentType = useCallStore((state) => state.agentType);

  const [subtitleListVisible, setSubtitleListVisible] = useState(false);

  const agentName = useMemo(() => {
    if (agentType === AICallAgentType.AvatarAgent) {
      return t('agent.avatar');
    } else if (agentType === AICallAgentType.VisionAgent) {
      return t('agent.vision');
    } else if (agentType === AICallAgentType.VideoAgent) {
      return t('agent.video');
    }
    return t('agent.voice');
  }, [agentType, t]);

  return (
    <>
      <SafeArea position='top' />
      <div className='header'>
        <Button className='_back-btn' onClick={onExit}>
          {BackWithLineSVG}
        </Button>
        <span className='_title'>{agentName}</span>
        <div className='_gap'></div>
        <div className='_actions'>
          <SubtitleList onVisibleChange={setSubtitleListVisible} />

          {!subtitleListVisible && <Setting />}
        </div>
      </div>
    </>
  );
}

export default Header;
