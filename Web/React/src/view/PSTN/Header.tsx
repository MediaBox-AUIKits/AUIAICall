import { Button, SafeArea } from 'antd-mobile';
import { backSVG } from '../Call/Icons';

import { useTranslation } from '@/common/i18nContext';
import './header.less';


function Header({
  onExit,
}: {
  instanceId?: string;
  reqId?: string;
  onExit: () => void;
}) {
  const { t } = useTranslation();

  return (
    <>
      <SafeArea position='top' />
      <div className='header pstn-header'>
        <Button className='_back-btn' onClick={onExit}>
          {backSVG}
        </Button>
        <span className='_title'>{t('pstn.title')}</span>
        <div className='_gap'></div>
        <div className='_actions'>
        </div>
      </div>
    </>
  );
}

export default Header;
