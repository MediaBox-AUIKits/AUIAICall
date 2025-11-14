import { AICallState } from 'aliyun-auikit-aicall';
import { Button } from 'antd-mobile';
import { useEffect, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import logger from '@/common/logger';
import { getRootElement } from '@/common/utils';
import ResponsiveDialog from 'components/ReponsiveDialog';

import useCallStore from '../store';
import { headerSubtitleSVG } from './Icons';

import './subtitleList.less';

const AutoScrollGap = 20;

function SubtitleList() {
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
        fill='none'
        className={`_subtitle-btn ${listVisible ? 'is-visible' : ''}`}
        onClick={toggleMessages}
        disabled={callState !== AICallState.Connected}
      >
        {headerSubtitleSVG}
        <span className='_text'>{t('subtitleList.btnText')}</span>
      </Button>
      <ResponsiveDialog
        className='subtitle-list-pop'
        visible={listVisible}
        maskStyle={{ backgroundColor: 'transparent' }}
        closeOnMaskClick={false}
        destroyOnClose
        title={<span className='_text'>{t('subtitleList.title')}</span>}
        getContainer={getRootElement}
        onClose={() => {
          setListVisible(false);
        }}
        headerChildren={
          <Button
            fill='none'
            className='_custom-close'
            onClick={() => {
              setListVisible(false);
            }}
          >
            字幕
          </Button>
        }
        content={
          <>
            <div className='subtitle-list' onScroll={onScroll}>
              <div className='_inner'>
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
            </div>
          </>
        }
      />
    </>
  );
}

export default SubtitleList;
