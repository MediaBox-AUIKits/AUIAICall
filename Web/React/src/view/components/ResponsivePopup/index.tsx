import { CenterPopup, Popup, PopupProps } from 'antd-mobile';
import { isMobile } from '@/common/utils';

function ResponsivePopup(props: PopupProps) {
  const defaultProps: PopupProps = isMobile()
    ? {
        position: 'right',
      }
    : {};

  const Component = isMobile() ? Popup : CenterPopup;

  return <Component {...defaultProps} {...props} />;
}

export default ResponsivePopup;
