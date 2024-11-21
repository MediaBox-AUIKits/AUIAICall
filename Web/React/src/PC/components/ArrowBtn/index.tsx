import { Button } from 'antd';
import Icon from '@ant-design/icons';

import rightToRight from './svg/rightToRight.svg?react';
import leftToLeft from './svg/leftToLeft.svg?react';
import rightToLeft from './svg/rightToLeft.svg?react';

import './index.less';

interface ArrowBtnProps {
  type?: 'rightToRight' | 'rightToLeft' | 'leftToLeft';
  onClick: () => void;
}

function ArrowBtn({ type = 'rightToRight', onClick }: ArrowBtnProps) {
  let component = rightToRight;
  if (type === 'rightToLeft') component = rightToLeft;
  else if (type === 'leftToLeft') component = leftToLeft;

  return (
    <Button className='ai-arrow-btn'>
      <Icon component={component} onClick={onClick} />
    </Button>
  );
}

export default ArrowBtn;
