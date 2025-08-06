import { useTranslation } from '@/common/i18nContext';
import { WorkflowType } from '@/service/interface';
import { getDeviceStream } from '@/view/Welcome/deviceHelper.ts';
import { AICallAgentType, AIChatAgentType } from 'aliyun-auikit-aicall';
import { Button, SafeArea, Swiper, SwiperRef, Tabs } from 'antd-mobile';
import { useEffect, useRef, useState } from 'react';
import { WelcomeArrowLeftSVG, WelcomeArrowRightSVG } from '../Call/Icons';
import WelcomeConfig from './Config';

import './index.less';

interface WelcomeProps {
  userId: string;
  region?: string;
  onAuthFail?: () => void;
  initialType: string;
  showPstn: boolean;
  onTypeSelected: (type: string) => void;
  onAgentTypeSelected: (type: AICallAgentType | AIChatAgentType) => void;
  onPSTNTypeSelected: (type: string) => void;
}

const LAST_CALL_SELECT_INDEX_CACHE_KEY = 'aicall-welcome-last-select-index';
const LAST_PSTN_SELECT_INDEX_CACHE_KEY = 'aicall-welcome-last-pstn-select-index';

function hasAudio(typeIndex: number, agentType: AICallAgentType | AIChatAgentType) {
  return typeIndex === 0 && agentType !== AIChatAgentType.MessageChat;
}

function hasVideo(typeIndex: number, agentType: AICallAgentType | AIChatAgentType) {
  return typeIndex === 0 && (agentType === AICallAgentType.VisionAgent || agentType === AICallAgentType.VideoAgent);
}

function Welcome({
  userId,
  region,
  onAuthFail,
  initialType,
  showPstn,
  onTypeSelected,
  onAgentTypeSelected,
  onPSTNTypeSelected,
}: WelcomeProps) {
  const { t } = useTranslation();
  const typeTabItems = [
    {
      key: 'call',
      title: t('welcome.call'),
    },
    {
      key: 'pstn',
      title: t('welcome.pstn.title'),
    },
  ];

  const [activeTypeIndex, setActiveTypeIndex] = useState(
    typeTabItems.findIndex((item) => item.key === initialType) || 0
  );
  const [activeCallIndex, setActiveCallIndex] = useState(
    Number(localStorage.getItem(LAST_CALL_SELECT_INDEX_CACHE_KEY)) || 0
  );
  const [activePSTNIndex, setActivePSTNIndex] = useState(
    Number(localStorage.getItem(LAST_PSTN_SELECT_INDEX_CACHE_KEY)) || 0
  );

  const swiperRef = useRef<SwiperRef>(null);

  const onClick = () => {
    localStorage.setItem(LAST_CALL_SELECT_INDEX_CACHE_KEY, activeCallIndex.toString());
    onTypeSelected(typeTabItems[activeTypeIndex].key);
    if (activeTypeIndex === 0) {
      onAgentTypeSelected(callTabItems[activeCallIndex].value);
    } else {
      onPSTNTypeSelected(pstnTabItems[activePSTNIndex].value);
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

  const currentAgentType = callTabItems[activeCallIndex].value;
  const needAudio = hasAudio(activeTypeIndex, currentAgentType);
  const needVideo = hasVideo(activeTypeIndex, currentAgentType);
  useEffect(() => {
    getDeviceStream(needAudio, needVideo);
  }, [needAudio, needVideo]);

  const pstnTabItems = [
    {
      key: 'Outbound',
      value: 'Outbound',
      title: t('welcome.pstn.outbound'),
      imgUrl: 'https://img.alicdn.com/imgextra/i3/O1CN01ELAkfg1QErPqPaQxV_!!6000000001945-2-tps-426-852.png',
      desktopImgUrl: 'https://img.alicdn.com/imgextra/i2/O1CN01RnDzyV1ZDn1wnziwW_!!6000000003161-2-tps-604-604.png',
      width: 302,
      height: 302,
    },
    {
      key: 'Inbound',
      value: 'Inbound',
      title: t('welcome.pstn.inbound'),
      imgUrl: 'https://img.alicdn.com/imgextra/i2/O1CN01DMhFSN1J4bEzB1cV3_!!6000000000975-2-tps-426-852.png',
      desktopImgUrl: 'https://img.alicdn.com/imgextra/i2/O1CN01S2fG6J20m8Ml5uRzV_!!6000000006891-2-tps-604-604.png',
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

        {activeTypeIndex === 0 ? (
          <Tabs
            key='call-tab'
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
        ) : (
          <Tabs
            key='pstn-tab'
            className='welcome-call-tab'
            stretch={false}
            activeKey={pstnTabItems[activePSTNIndex].key}
            onChange={(key) => {
              const index = pstnTabItems.findIndex((item) => item.key === key);
              setActivePSTNIndex(index);
              swiperRef.current?.swipeTo(index);
            }}
          >
            {pstnTabItems.map((item) => (
              <Tabs.Tab title={item.title} key={item.key} />
            ))}
          </Tabs>
        )}

        <div className='welcome-swiper'>
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
          <Swiper
            direction='horizontal'
            key={`${activeTypeIndex}`}
            indicator={() => null}
            ref={swiperRef}
            defaultIndex={activeTypeIndex === 0 ? activeCallIndex : activePSTNIndex}
            onIndexChange={(index) => {
              if (activeTypeIndex === 0) {
                setActiveCallIndex(index);
              } else {
                setActivePSTNIndex(index);
              }
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
          {activeTypeIndex === 0 && activeCallIndex !== 3 && (
            <WelcomeConfig userId={userId} region={region} onAuthFail={onAuthFail} />
          )}
        </div>
      </div>
      <SafeArea position='bottom' />
    </div>
  );
}

export default Welcome;
