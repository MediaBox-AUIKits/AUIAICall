import { AICallState } from 'aliyun-auikit-aicall';
import { useEffect, useRef, useState } from 'react';
import { Button, Dialog } from 'antd-mobile';

import { useTranslation } from '@/common/i18nContext';
import logger from '@/common/logger';

import useCallStore from './store';
import './subtitleList.less';
import { DialogCloseSVG, SubtitleListSVG } from './Icons';

const AutoScrollGap = 20;

function SubtitleList({ onVisibleChange }: { onVisibleChange: (visible: boolean) => void }) {
  const { t } = useTranslation();
  const [listVisible, setListVisible] = useState(false);

  const callState = useCallStore((state) => state.callState);
  const subtitleList = useCallStore((state) => state.subtitleList);
  // 最底部的节点，依靠 scrollIntoView 来实现滚动到最底部
  // bottom element for scrollIntoView to scroll to bottom
  const scrollBottomRef = useRef<HTMLDivElement>(null);
  // 是否自动滚动到最底部
  // is auto scroll to bottom needed
  const autoScrollSwitchRef = useRef<boolean>(true);

  useEffect(() => {
    onVisibleChange(listVisible);
  }, [onVisibleChange, listVisible]);

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

  const toggleMessages = () => {
    logger.info('Header', `toggleMessages to: ${!listVisible}`);
    setListVisible((visible) => !visible);
  };

  return (
    <>
      <Button
        className={`_subtitle-btn ${listVisible ? 'is-visible' : ''}`}
        onClick={toggleMessages}
        disabled={callState !== AICallState.Connected}
      >
        <span className='_icon'>{SubtitleListSVG}</span>
        {t('subtitleList.btn')}
      </Button>
      <Dialog
        className='subtitle-list-pop'
        visible={listVisible}
        maskStyle={{ backgroundColor: 'transparent' }}
        closeOnMaskClick={false}
        destroyOnClose
        onClose={() => {
          setListVisible(false);
        }}
        content={
          <div className='subtitle-list' onScroll={onScroll}>
            <Button
              className='_close'
              onClick={() => {
                setListVisible(false);
              }}
            >
              {DialogCloseSVG}
            </Button>
            <ol>
              {subtitleList.map((item) => (
                <li
                  key={`${item.source}-${item.data.sentenceId}`}
                  className={`subtitle-list-item ${item.source === 'agent' ? 'is-agent' : ''}`}
                >
                  <div className='_content'>{item.data.text}</div>
                </li>
              ))}
            </ol>
            <div ref={scrollBottomRef}></div>
          </div>
        }
      />
    </>
  );
}

export default SubtitleList;
