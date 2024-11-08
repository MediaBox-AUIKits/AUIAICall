import { useEffect, useRef } from 'react';
import { AICallAgentType } from 'aliyun-auikit-aicall';
// import { Button, Input } from 'antd';

// import Send from './send.svg?react';
// import Icon from '@ant-design/icons';

import './index.less';
import useCallStore from '../store';
import ArrowBtn from '../../components/ArrowBtn';

const AutoScrollGap = 20;

interface MessageProps {
  showMessage: boolean;
  onHideMessage: () => void;
}

function Message({ showMessage, onHideMessage }: MessageProps) {
  const agentType = useCallStore((state) => state.agentType);
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
    <div className={`call-block call-message ${showMessage ? 'is-show' : 'is-hide'}`}>
      <ArrowBtn
        type={agentType === AICallAgentType.AvatarAgent ? 'rightToLeft' : 'rightToRight'}
        onClick={onHideMessage}
      />
      <div className='call-block-container'>
        <div className='call-block-title'>
          <div className='_text'>小云</div>
        </div>
        <div className='call-block-bd call-message-bd'>
          <div className='call-message-list' onScroll={onScroll}>
            <ol>
              {subtitleList.map((item) => (
                <li
                  key={`${item.source}-${item.data.sentenceId}`}
                  className={`call-message-item ${item.source === 'agent' ? 'is-agent' : ''}`}
                >
                  <div className='_content'>{item.data.text}</div>
                </li>
              ))}
            </ol>
            <div ref={scrollBottomRef}></div>
          </div>
          <div className='call-message-ft'>
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
    </div>
  );
}

export default Message;
