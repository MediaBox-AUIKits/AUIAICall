import { Button, Dialog, DialogProps, SafeArea } from 'antd-mobile';
import { ReactNode } from 'react';

import { getRootElement } from '@/common/utils';
import { dialogCloseSVG } from 'call/components/Icons';

import './reponsiveDialog.less';

export default function ResponsiveDialog(props: DialogProps & { headerChildren?: ReactNode }) {
  const { headerChildren, className, bodyClassName, title, onClose, ...rest } = props;
  return (
    <Dialog
      getContainer={getRootElement}
      className={`ai-responsive-dialog ${className || ''}`}
      bodyClassName={`ai-responsive-dialog-body ${bodyClassName || ''}`}
      header={
        <>
          <SafeArea position='top' />
          <Button fill='none' className='_close' onClick={onClose}>
            {dialogCloseSVG}
          </Button>
          <div className='_hd'>{title}</div>
          {headerChildren}
        </>
      }
      {...rest}
    />
  );
}
