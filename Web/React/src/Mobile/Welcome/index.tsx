import { useRef, useState } from 'react';
import { Tabs, Swiper, SwiperRef, Button, SafeArea } from 'antd-mobile';

import './index.less';
import { AICallAgentType, AIChatAgentType } from 'aliyun-auikit-aicall';
import { WorkflowType } from '@/service/interface';

import { useTranslation } from '@/common/i18nContext';

interface WelcomeProps {
  onAgentTypeSelected: (type: AICallAgentType | AIChatAgentType) => void;
}

const LAST_SELECT_INDEX_CACHE_KEY = 'aicall-welcome-last-select-index';

function Welcome({ onAgentTypeSelected }: WelcomeProps) {
  const swiperRef = useRef<SwiperRef>(null);
  const [activeIndex, setActiveIndex] = useState(Number(localStorage.getItem(LAST_SELECT_INDEX_CACHE_KEY)) || 0);
  const { t } = useTranslation();

  const onClick = () => {
    localStorage.setItem(LAST_SELECT_INDEX_CACHE_KEY, activeIndex.toString());
    onAgentTypeSelected(tabItems[activeIndex].value);
  };

  const tabItems = [
    {
      key: WorkflowType.VoiceChat,
      value: AICallAgentType.VoiceAgent,
      title: t('agent.voice'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i2/O1CN01ZLoopi1t0JfazWfy8_!!6000000005839-2-tps-426-852.png',
    },
    {
      key: WorkflowType.AvatarChat3D,
      value: AICallAgentType.AvatarAgent,
      title: t('agent.avatar'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i4/O1CN01SfZ6SI1eo2QpmMjMt_!!6000000003917-2-tps-426-852.png',
    },
    {
      key: WorkflowType.VisionChat,
      value: AICallAgentType.VisionAgent,
      title: t('agent.vision'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i1/O1CN01BZPzdO1pnXmFPq3WN_!!6000000005405-2-tps-426-852.png',
    },
    {
      key: 'Chatbot',
      value: AIChatAgentType.MessageChat,
      title: t('agent.chatbot'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i3/O1CN01e6vxYV1pJm28uCaRD_!!6000000005340-2-tps-426-852.png',
    },
  ];

  return (
    <div className='welcome'>
      <div className='welcome-header'>{t('welcome.title')}</div>
      <Tabs
        activeKey={tabItems[activeIndex].key}
        onChange={(key) => {
          const index = tabItems.findIndex((item) => item.key === key);
          setActiveIndex(index);
          swiperRef.current?.swipeTo(index);
        }}
      >
        {tabItems.map((item) => (
          <Tabs.Tab title={item.title} key={item.key} />
        ))}
      </Tabs>
      <Swiper
        direction='horizontal'
        indicator={() => null}
        ref={swiperRef}
        defaultIndex={activeIndex}
        onIndexChange={(index) => {
          setActiveIndex(index);
        }}
      >
        {tabItems.map((item) => (
          <Swiper.Item key={item.key}>
            <img className='welcome-img' src={item.imgUrl} alt={item.title} />
          </Swiper.Item>
        ))}
      </Swiper>
      <div className='welcome-btn'>
        <Button color='primary' block onClick={onClick}>
          {t('welcome.btn')}
        </Button>
        
      </div>
      <SafeArea position='bottom' />
    </div>
  );
}

export default Welcome;
