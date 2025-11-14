import { AICallAgentType, AIChatAgentType } from 'aliyun-auikit-aicall';
import { Button, SafeArea, SwiperRef, Tabs } from 'antd-mobile';
import { useEffect, useMemo, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';

import ImageWithTheme from '../components/ImageWithTheme';
import Layout from '../components/Layout';
import { useResponsiveBreakpoint } from '../hooks/useResponsiveBreakpoint';
import { AIPSTNType } from '../PSTN';
import CarouselSlider from './CarouselSlider';
import WelcomeConfig from './Config';
import { getDeviceStream } from './deviceHelper.ts';
import avatarImg from './images/avatar_agent.png';
import chatbotImg from './images/chatbot_agent.png';
import pstnInImg from './images/pstn_in.png';
import pstnOutImg from './images/pstn_out.png';
import videoImg from './images/video_agent.png';
import visionImg from './images/vision_agent.png';
import voiceImg from './images/voice_agent.png';
import { SlideData, WelcomeProps, WelcomeTypeValue } from './type';

import './index.less';

const LAST_CALL_SELECT_INDEX_CACHE_KEY = 'aicall-welcome-last-select-index';

function hasAudio(agentType: WelcomeTypeValue) {
  return agentType >= AICallAgentType.VoiceAgent && agentType <= AICallAgentType.VideoAgent;
}

function hasVideo(agentType: WelcomeTypeValue) {
  return agentType === AICallAgentType.VisionAgent || agentType === AICallAgentType.VideoAgent;
}

function Welcome({ userId, region, onAuthFail, showPstn, onSelected }: WelcomeProps) {
  const { t, lang } = useTranslation();
  // const { enableDarkMode, toggleTheme } = useTheme();
  const isMobileUI = useResponsiveBreakpoint();

  const [activeIndex, setActiveIndex] = useState(Number(localStorage.getItem(LAST_CALL_SELECT_INDEX_CACHE_KEY)) || 0);

  const swiperRef = useRef<SwiperRef>(null);

  const AISlides: SlideData[] = [
    {
      key: 'voice_agent',
      title: t('agent.voice'),
      description: t('agent.descriptions.voice'),
      image: voiceImg,
      value: AICallAgentType.VoiceAgent,
    },
    {
      key: 'avatar_agent',
      title: t('agent.avatar'),
      description: t('agent.descriptions.avatar'),
      image: avatarImg,
      value: AICallAgentType.AvatarAgent,
    },
    {
      key: 'vision_agent',
      title: t('agent.vision'),
      description: t('agent.descriptions.vision'),
      image: visionImg,
      value: AICallAgentType.VisionAgent,
    },
    {
      key: 'video_agent',
      title: t('agent.video'),
      description: t('agent.descriptions.video'),
      image: videoImg,
      value: AICallAgentType.VideoAgent,
    },
    {
      key: 'chatbot_agent',
      title: t('agent.chatbot'),
      description: t('agent.descriptions.chatbot'),
      image: chatbotImg,
      value: AIChatAgentType.MessageChat,
    },
    {
      key: 'pstn_out',
      title: t('agent.pstnOut'),
      description: t('agent.descriptions.pstnOut'),
      image: pstnOutImg,
      value: AIPSTNType.Outbound,
    },
    {
      key: 'pstn_in',
      title: t('agent.pstnIn'),
      description: t('agent.descriptions.pstnIn'),
      image: pstnInImg,
      value: AIPSTNType.Inbound,
    },
  ];

  const onClick = () => {
    localStorage.setItem(LAST_CALL_SELECT_INDEX_CACHE_KEY, activeIndex.toString());
    onSelected(AISlides[activeIndex].value);
  };

  const activeValue = AISlides[activeIndex].value;
  const needAudio = hasAudio(activeValue);
  const needVideo = hasVideo(activeValue);

  useEffect(() => {
    getDeviceStream(needAudio, needVideo);
  }, [needAudio, needVideo]);

  const slides = useMemo(() => {
    return showPstn ? AISlides : AISlides.filter((item) => item.value < AIPSTNType.Outbound);
  }, [showPstn]);

  return (
    <Layout
      themeBtn={false}
      settingBtn={
        activeIndex >= 0 &&
        activeIndex <= 3 && <WelcomeConfig userId={userId} region={region} onAuthFail={onAuthFail} />
      }
    >
      <div className='ai-content ai-bg'>
        <div className='welcome-wrapper'>
          <div className='welcome-header'>
            {/* <Button fill='none' className='_theme-btn' onClick={toggleTheme}>
              {enableDarkMode ? themeDarkSVG : themeLightSVG}
            </Button> */}
            <div className='ai-flex-1'></div>
            {activeIndex >= 0 && activeIndex <= 3 && (
              <div className='welcome-header-btns'>
                <WelcomeConfig userId={userId} region={region} onAuthFail={onAuthFail} />
              </div>
            )}
          </div>
          <div className='welcome-img'>
            {lang === 'en' ? (
              <ImageWithTheme
                src='https://gw.alicdn.com/imgextra/i3/O1CN01cJANzi1GB40bqBAcL_!!6000000000583-2-tps-332-40.png'
                dark-src='https://gw.alicdn.com/imgextra/i2/O1CN01UeYlKx1JJFwNimSW6_!!6000000001007-2-tps-332-40.png'
                alt='logo'
                width={166}
                height={20}
              />
            ) : (
              <ImageWithTheme
                src='https://gw.alicdn.com/imgextra/i3/O1CN01rmMKVm1J6tEeIqPq6_!!6000000000980-2-tps-272-44.png'
                dark-src='https://gw.alicdn.com/imgextra/i1/O1CN010ikCyQ1qr2SomxqAk_!!6000000005548-2-tps-272-44.png'
                alt='logo'
                width={136}
                height={22}
              />
            )}
          </div>
          <div className='welcome-tabs'>
            <Tabs
              key='call-tab'
              className='welcome-call-tab'
              activeKey={slides[activeIndex].key}
              activeLineMode={isMobileUI ? 'fixed' : 'auto'}
              style={{
                '--fixed-active-line-width': '30px',
              }}
              onChange={(key) => {
                const index = slides.findIndex((item) => item.key === key);
                setActiveIndex(index);
                swiperRef.current?.swipeTo(index);
              }}
            >
              {slides.map((item) => (
                <Tabs.Tab title={item.title} key={item.key} />
              ))}
            </Tabs>
          </div>

          <CarouselSlider
            slides={slides}
            activeIndex={activeIndex}
            onSlideChange={(index: number) => {
              setActiveIndex(index);
            }}
          />
          <div className='welcome-description'>
            <div className='_inner'>{slides[activeIndex].description}</div>
          </div>
          <div className='welcome-footer'>
            <Button className='_btn' block onClick={onClick}>
              {t('welcome.btn')}
            </Button>
          </div>
          <SafeArea position='bottom' />
        </div>
      </div>
    </Layout>
  );
}

export * from './type';
export default Welcome;
