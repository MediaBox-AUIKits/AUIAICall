import { useEffect, useRef } from 'react';
// import { Button, Input } from 'antd';

// import Send from './send.svg?react';
// import Icon from '@ant-design/icons';

import './index.less';
import useCallStore from '../store';
import { Button } from 'antd';
import { CloseOutlined } from '@ant-design/icons';

const AutoScrollGap = 20;

interface MessageProps {
  onHideMessage: () => void;
}

function Message({ onHideMessage }: MessageProps) {
  const subtitleList = useCallStore((state) => state.subtitleList);
  // 最底部的节点，依靠 scrollIntoView 来实现滚动到最底部
  const scrollBottomRef = useRef<HTMLDivElement>(null);
  // 是否自动滚动到最底部
  const autoScrollSwitchRef = useRef<boolean>(true);

  useEffect(() => {
    if (autoScrollSwitchRef.current) {
      scrollBottomRef.current?.scrollIntoView();
    }
  }, [subtitleList]);

  const onScroll = (e: React.UIEvent<HTMLDivElement>) => {
    const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
    if (scrollTop + clientHeight >= scrollHeight - AutoScrollGap) {
      autoScrollSwitchRef.current = true;
    } else {
      autoScrollSwitchRef.current = false;
    }
  };

  return (
    <div className='voice-block voice-message'>
      <div className='voice-block-title'>
        <div className='_text'>小云</div>
        <div className='_extra'>
          <Button className='_close' onClick={onHideMessage}>
            <CloseOutlined />
          </Button>
        </div>
      </div>
      <div className='voice-block-bd voice-message-bd'>
        <div className='voice-message-list' onScroll={onScroll}>
          <ol>
            {subtitleList.map((item) => (
              <li
                key={`${item.source}-${item.data.sentenceId}`}
                className={`voice-message-item ${item.source === 'agent' ? 'isAgent' : ''}`}
              >
                <div className='_content'>{item.data.text}</div>
              </li>
            ))}
          </ol>
          <div ref={scrollBottomRef}></div>
        </div>
        <div className='voice-message-ft'>
          {/* <Input
            suffix={
              <Button>
                <Icon component={Send} />
              </Button>
            }
          /> */}
          <div className='_tip'>内容由 AI 生成，仅供参考</div>
        </div>
      </div>
    </div>
  );
}

export default Message;
