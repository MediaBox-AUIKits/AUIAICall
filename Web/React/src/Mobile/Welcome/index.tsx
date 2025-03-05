import { useRef, useState } from 'react';
import { Tabs, Swiper, SwiperRef, Button, SafeArea } from 'antd-mobile';
import i18n from '@/common/i18n';

import './index.less';
import { AICallAgentType, AIChatAgentType } from 'aliyun-auikit-aicall';
import { WorkflowType } from '@/service/interface';


const tabItems = [
  {
    key: WorkflowType.VoiceChat,
    value: AICallAgentType.VoiceAgent,
    title: i18n['agent.voice'],
    imgUrl: 'https://img.alicdn.com/imgextra/i2/O1CN01tOWPAl1a4SWHi4fge_!!6000000003276-49-tps-426-852.webp',
  },
  {
    key: WorkflowType.AvatarChat3D,
    value: AICallAgentType.AvatarAgent,
    title: i18n['agent.avatar'],
    imgUrl: 'https://img.alicdn.com/imgextra/i2/O1CN01ItB96W1wZWw83WnTF_!!6000000006322-49-tps-426-852.webp',
  },
  {
    key: WorkflowType.VisionChat,
    value: AICallAgentType.VisionAgent,
    title: i18n['agent.vision'],
    imgUrl: 'https://img.alicdn.com/imgextra/i1/O1CN01KNB3ru1aU6hSxhptR_!!6000000003332-49-tps-426-852.webp',
  },
  {
    key: 'Chatbot',
    value: AIChatAgentType.MessageChat,
    title: i18n['agent.chatbot'],
    imgUrl: 'https://img.alicdn.com/imgextra/i4/O1CN01LMBWgi1zsiOciKzqu_!!6000000006770-2-tps-426-852.png',
  },
];

interface WelcomeProps {
  onAgentTypeSelected: (type: AICallAgentType | AIChatAgentType) => void;
}

const LAST_SELECT_INDEX_CACHE_KEY = 'aicall-welcome-last-select-index';

function Welcome({ onAgentTypeSelected }: WelcomeProps) {
  const swiperRef = useRef<SwiperRef>(null);
  const [activeIndex, setActiveIndex] = useState(Number(localStorage.getItem(LAST_SELECT_INDEX_CACHE_KEY)) || 0);

  const onClick = () => {
    localStorage.setItem(LAST_SELECT_INDEX_CACHE_KEY, activeIndex.toString());
    onAgentTypeSelected(tabItems[activeIndex].value);
  };

  return (
    <div className='welcome'>
      <div className='welcome-header'>AI虚拟人通话</div>
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
          开始体验
        </Button>
        
      </div>
      <SafeArea position='bottom' />
    </div>
  );
}

export default Welcome;
