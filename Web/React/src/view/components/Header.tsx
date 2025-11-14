import { Button, SafeArea } from 'antd-mobile';

import { headerBackSVG } from './Icons';

import './header.less';

function Header({ title, onExit, actions }: { title: string; onExit: () => void; actions: React.ReactNode }) {
  return (
    <>
      <SafeArea position='top' />
      <div className='header'>
        <Button fill='none' className='_back-btn' onClick={onExit}>
          {headerBackSVG}
        </Button>
        <span className='_title'>{title}</span>
        <div className='ai-flex-1'></div>
        <div className='_actions'>{actions}</div>
      </div>
    </>
  );
}

export default Header;
