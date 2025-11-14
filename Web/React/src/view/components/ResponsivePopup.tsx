import { Popup, PopupProps } from 'antd-mobile';

import { getRootElement } from '@/common/utils';

import { settingCloseSVG } from '../Call/components/Icons';
import { useResponsiveBreakpoint } from '../hooks/useResponsiveBreakpoint';

import './responsivePopup.less';

export default function ResponsivePopup({
  className,
  ...props
}: PopupProps & {
  title?: string;
}) {
  const isMobileUI = useResponsiveBreakpoint();

  return (
    <Popup
      className={`ai-responsive-pop ${className || ''}`}
      getContainer={() => getRootElement()}
      closeOnMaskClick
      position={isMobileUI ? 'bottom' : 'right'}
      showCloseButton
      closeIcon={settingCloseSVG}
      {...props}
    >
      <div className='ai-responsive-pop-title'>
        <span className='_text'>{props.title || ' '}</span>
        <div className='ai-flex-1'></div>
      </div>
      <div className='ai-responsive-pop-bd'>{props.children}</div>
    </Popup>
  );
}
