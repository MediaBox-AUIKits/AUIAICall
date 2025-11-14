import { Button } from 'antd-mobile';
import { ReactNode } from 'react';

import { useTranslation } from '@/common/i18nContext';

import useTheme from '../hooks/useTheme';
import { headerSettingSvg, logoutSVG, themeDarkSVG, themeLightSVG } from './Icons';
import ImageWithTheme from './ImageWithTheme';


import './layout.less';

export function StageWrapper({ className, children }: { className?: string; children: ReactNode }) {
  return (
    <div className='ai-content'>
      <div className='ai-stage-wrapper'>
        <div className={`ai-stage ai-bg ${className || ''}`}>{children}</div>
      </div>
    </div>
  );
}

function Layout({
  children,
  showText = false,
  themeBtn = true,
  settingBtn = true,
  onSetting,
  onExit,
}: {
  children: React.ReactNode;
  showText?: boolean;
  themeBtn?: boolean | ReactNode;
  settingBtn?: boolean | ReactNode;
  logoutBtn?: boolean | ReactNode;
  onSetting?: () => void;
  onExit?: () => void;
}) {
  const { lang } = useTranslation();

  const renderBtn = (btn: boolean | ReactNode, defaultNode: ReactNode) => {
    if (btn === false) {
      return null;
    }
    if (btn === true) {
      return defaultNode;
    }
    return btn;
  };

  // 使用自定义hook处理主题
  const { enableDarkMode, toggleTheme } = useTheme();


  return (
    <div className='ai-layout'>
      <div className='ai-layout-header'>
        {lang === 'en' ? (
          <ImageWithTheme
            src='https://gw.alicdn.com/imgextra/i4/O1CN01awSVFi1a9UyFDXLHF_!!6000000003287-2-tps-214-26.png'
            dark-src='https://gw.alicdn.com/imgextra/i3/O1CN01MybhXY1TMazD0kPln_!!6000000002368-2-tps-214-26.png'
            alt='logo'
            width={107}
            height={13}
            onClick={() => {
              onExit?.();
            }}
          />
        ) : (
          <ImageWithTheme
            src='https://gw.alicdn.com/imgextra/i3/O1CN01rmMKVm1J6tEeIqPq6_!!6000000000980-2-tps-272-44.png'
            dark-src='https://gw.alicdn.com/imgextra/i1/O1CN010ikCyQ1qr2SomxqAk_!!6000000005548-2-tps-272-44.png'
            alt='logo'
            width={86}
            height={14}
            onClick={() => {
              onExit?.();
            }}
          />
        )}

        <div className='ai-flex-1'></div>
        <div className='ai-layout-actions'>
          {renderBtn(
            themeBtn,
            <Button fill='none' onClick={toggleTheme}>
              {enableDarkMode ? themeDarkSVG : themeLightSVG} {showText && <span className='_text'>模式切换</span>}
            </Button>
          )}
          {renderBtn(
            settingBtn,
            <Button fill='none' onClick={onSetting}>
              {headerSettingSvg} {showText && <span className='_text'>配置项</span>}
            </Button>
          )}
        </div>
      </div>
      {children}
    </div>
  );
}

export default Layout;
