import { Button, Dialog, DialogProps, SafeArea } from 'antd-mobile';

import './index.less';
import { BackSVG, DialogCloseSVG } from '@/view/Call/Icons';

export default function ResponsiveDialog(props: DialogProps) {
  const { className, bodyClassName, title, onClose, ...rest } = props;
  return (
    <Dialog
      className={`ai-responsive-dialog ${className || ''}`}
      bodyClassName={`ai-responsive-dialog-body ${bodyClassName || ''}`}
      header={
        <>
          <SafeArea position='top' />
          <Button fill='none' className='_back' onClick={onClose}>
            {BackSVG}
          </Button>
          <Button fill='none' className='_close' onClick={onClose}>
            {DialogCloseSVG}
          </Button>
          <div className='_hd'>{title}</div>
        </>
      }
      {...rest}
    />
  );
}
