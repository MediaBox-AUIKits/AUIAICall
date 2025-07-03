import { useRef, useState } from 'react';
import { Tabs, Swiper, SwiperRef, Button, SafeArea } from 'antd-mobile';

import './index.less';
import { AICallAgentType, AIChatAgentType } from 'aliyun-auikit-aicall';
import { WorkflowType } from '@/service/interface';
import { useTranslation } from '@/common/i18nContext';
import { WelcomeArrowLeftSVG, WelcomeArrowRightSVG } from '../Call/Icons';


interface WelcomeProps {
  initialType: string;
  showPstn: boolean;
  onTypeSelected: (type: string) => void;
  onAgentTypeSelected: (type: AICallAgentType | AIChatAgentType) => void;
}

const LAST_SELECT_INDEX_CACHE_KEY = 'aicall-welcome-last-select-index';

function Welcome({ initialType, showPstn, onTypeSelected, onAgentTypeSelected }: WelcomeProps) {
  const { t } = useTranslation();
  const typeTabItems = [
    {
      key: 'call',
      title: t('welcome.call'),
    },
    {
      key: 'pstn',
      title: t('welcome.pstn'),
    },
  ];

  const [activeTypeIndex, setActiveTypeIndex] = useState(
    typeTabItems.findIndex((item) => item.key === initialType) || 0
  );
  const [activeCallIndex, setActiveCallIndex] = useState(
    Number(localStorage.getItem(LAST_SELECT_INDEX_CACHE_KEY)) || 0
  );
  const swiperRef = useRef<SwiperRef>(null);

  const onClick = () => {
    localStorage.setItem(LAST_SELECT_INDEX_CACHE_KEY, activeCallIndex.toString());
    onTypeSelected(typeTabItems[activeTypeIndex].key);
    if (activeTypeIndex === 0) {
      onAgentTypeSelected(callTabItems[activeCallIndex].value);
    } else {
      onAgentTypeSelected(callTabItems[0].value);
    }
  };

  const callTabItems = [
    {
      key: WorkflowType.VoiceChat,
      value: AICallAgentType.VoiceAgent,
      title: t('agent.voice'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i2/O1CN01ZLoopi1t0JfazWfy8_!!6000000005839-2-tps-426-852.png',
      desktopImgUrl: 'https://gw.alicdn.com/imgextra/i4/O1CN01rXBEYm1oKOyekwSs3_!!6000000005206-2-tps-560-104.png',
      width: 280,
      height: 52,
    },
    {
      key: WorkflowType.AvatarChat3D,
      value: AICallAgentType.AvatarAgent,
      title: t('agent.avatar'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i4/O1CN01SfZ6SI1eo2QpmMjMt_!!6000000003917-2-tps-426-852.png',
      desktopImgUrl: 'https://gw.alicdn.com/imgextra/i3/O1CN01styzUV1INXzcDbMSl_!!6000000000881-2-tps-296-349.png',
      width: 148,
      height: 175,
    },
    {
      key: WorkflowType.VisionChat,
      value: AICallAgentType.VisionAgent,
      title: t('agent.vision'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i1/O1CN01BZPzdO1pnXmFPq3WN_!!6000000005405-2-tps-426-852.png',
      desktopImgUrl: 'https://gw.alicdn.com/imgextra/i4/O1CN01zUUZCf1VALaBVqAVe_!!6000000002612-2-tps-604-604.png',
      width: 302,
      height: 302,
    },
    {
      key: 'Chatbot',
      value: AIChatAgentType.MessageChat,
      title: t('agent.chatbot'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i3/O1CN01e6vxYV1pJm28uCaRD_!!6000000005340-2-tps-426-852.png',
      desktopImgUrl: 'https://gw.alicdn.com/imgextra/i3/O1CN01WcQcZK1s9Bk9aaeu0_!!6000000005723-2-tps-604-604.png',
      width: 302,
      height: 302,
    },
    {
      key: WorkflowType.VideoChat,
      value: AICallAgentType.VideoAgent,
      title: t('agent.video'),
      imgUrl: 'https://gw.alicdn.com/imgextra/i3/O1CN01Skv0lc20EF2WOjkS9_!!6000000006817-2-tps-426-852.png',
      desktopImgUrl: 'https://gw.alicdn.com/imgextra/i3/O1CN01mo1mdZ1jpwAZlMhYO_!!6000000004598-2-tps-604-604.png',
      width: 302,
      height: 302,
    },
  ];

  const pstnTabItems = [
    {
      key: 'Outbound',
      value: 'Outbound',
      title: '',
      imgUrl: 'https://img.alicdn.com/imgextra/i3/O1CN01ELAkfg1QErPqPaQxV_!!6000000001945-2-tps-426-852.png',
      desktopImgUrl: 'https://img.alicdn.com/imgextra/i2/O1CN01RnDzyV1ZDn1wnziwW_!!6000000003161-2-tps-604-604.png',
      width: 302,
      height: 302,
    },
  ];

  return (
    <div className='welcome'>
      <div className='welcome-header'>{t('welcome.title')}</div>
      <div className='welcome-body'>
        {showPstn && (
          <Tabs
            activeKey={typeTabItems[activeTypeIndex].key}
            activeLineMode='full'
            onChange={(key) => {
              const index = typeTabItems.findIndex((item) => item.key === key);
              setActiveTypeIndex(index);
            }}
            className='welcome-type-tab'
          >
            {typeTabItems.map((item) => (
              <Tabs.Tab title={item.title} key={item.key} />
            ))}
          </Tabs>
        )}
        {activeTypeIndex === 0 && (
          <Tabs
            className='welcome-call-tab'
            activeKey={callTabItems[activeCallIndex].key}
            onChange={(key) => {
              const index = callTabItems.findIndex((item) => item.key === key);
              setActiveCallIndex(index);
              swiperRef.current?.swipeTo(index);
            }}
          >
            {callTabItems.map((item) => (
              <Tabs.Tab title={item.title} key={item.key} />
            ))}
          </Tabs>
        )}
        <div className='welcome-swiper'>
          {activeTypeIndex === 0 && (
            <>
              <Button className='_left' disabled={activeCallIndex === 0} onClick={() => swiperRef.current?.swipePrev()}>
                {WelcomeArrowLeftSVG}
              </Button>
              <Button
                className='_right'
                disabled={activeCallIndex === callTabItems.length - 1}
                onClick={() => swiperRef.current?.swipeNext()}
              >
                {WelcomeArrowRightSVG}
              </Button>
            </>
          )}
          <Swiper
            direction='horizontal'
            indicator={() => null}
            ref={swiperRef}
            defaultIndex={activeCallIndex}
            onIndexChange={(index) => {
              setActiveCallIndex(index);
            }}
          >
            {(activeTypeIndex === 0 ? callTabItems : pstnTabItems).map((item) => (
              <Swiper.Item key={item.key}>
                <div className='welcome-img-box'>
                  <img className='_for-mobile' src={item.imgUrl} alt={item.title} />
                  <img
                    className='_for-desktop'
                    src={item.desktopImgUrl}
                    alt={item.title}
                    width={item.width || 260}
                    height={item.height || 260}
                  />
                </div>
              </Swiper.Item>
            ))}
          </Swiper>
        </div>
        <div className='welcome-btn'>
          <Button color='primary' block onClick={onClick}>
            {t('welcome.btn')}
          </Button>
        </div>
      </div>
      <SafeArea position='bottom' />
    </div>
  );
}

export default Welcome;
