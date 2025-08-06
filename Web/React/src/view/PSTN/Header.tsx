import { Button, SafeArea } from 'antd-mobile';
import { BackWithLineSVG } from '../Call/Icons';

import './header.less';


function Header({
  title,
  onExit,
}: {
  title: string;
  instanceId?: string;
  reqId?: string;
  onExit: () => void;
}) {
  return (
    <>
      <SafeArea position='top' />
      <div className='header pstn-header'>
        <Button className='_back-btn' onClick={onExit}>
          {BackWithLineSVG}
        </Button>
        <span className='_title'>{title}</span>
        <div className='_gap'></div>
        <div className='_actions'>
        </div>
      </div>
    </>
  );
}

export default Header;
