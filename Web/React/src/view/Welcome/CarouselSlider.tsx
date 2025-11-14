import { Button } from 'antd-mobile';
import { useEffect, useRef } from 'react';
import { Navigation, Pagination } from 'swiper/modules';
import type { SwiperClass, SwiperRef } from 'swiper/react';
import { Swiper, SwiperSlide } from 'swiper/react';

// 导入 Swiper 样式
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/pagination';

import { isMobile } from '@/common/utils';

import { paginationLeftSVG, paginationRightSVG } from './Icons';

import './carouselSlider.less';

interface CarouselSliderProps {
  slides: any[];
  activeIndex: number;
  onSlideChange: (index: number) => void;
}

const fanEffectParams = {
  down: 40,
  depth: 100,
  scale: 0.2,
};

const rotateFn = (x: number) => (-2 * Math.pow(x, 3) + 38 * x) / 3;
const translateXFn = (x: number) => (40 * x * (x * x + 2)) / 3;
const translateXFnForMobile = (x: number) => x * 230 - 160;

const CarouselSlider = ({ slides, activeIndex, onSlideChange }: CarouselSliderProps) => {
  const swiperRef = useRef<SwiperRef>(null);

  const handleSlideChange = (swiper: SwiperClass) => {
    // 延迟 300ms 更新 activeIndex
    setTimeout(() => {
      if (activeIndex === swiper.realIndex) return;
      onSlideChange(swiper.realIndex);
    }, 300);
  };

  const handleProgress = (swiper: SwiperClass) => {
    const forMobile = isMobile();
    // 基于滑动进度调整透明度
    swiper.slides.forEach((slide) => {
      // @ts-expect-error progress
      const slideProgress = slide.progress;
      const absProgress = Math.abs(slideProgress);

      // 计算基础变换值
      const rotateZ = forMobile ? 0 : rotateFn(-slideProgress);
      const translateY = forMobile ? 0 : absProgress * fanEffectParams.down;
      const translateZ = -absProgress * fanEffectParams.depth;
      const translateX = forMobile ? translateXFnForMobile(slideProgress) : translateXFn(slideProgress);
      const scale = Math.max(0.3, 1 - absProgress * fanEffectParams.scale);

      let opacity = 1;
      if (!forMobile) {
        if (absProgress > 1) {
          opacity = Math.max(0, 1 - (absProgress - 1) / 2);
        }
      } else {
        if (absProgress >= 3) {
          opacity = 0;
        }
      }

      // 应用变换到卡片容器
      if (slide?.nodeName) {
        slide.style.transform = `
          translate3d(${translateX}px, ${translateY}px, ${translateZ}px)
          rotateZ(${rotateZ}deg)
          scale3d(${scale}, ${scale}, 1)
        `;
        slide.style.setProperty('--opacity', `${opacity}`);

        if (opacity === 0) {
          slide.style.opacity = '0';
        } else {
          slide.style.opacity = '1';
        }
        slide.style.zIndex = String(10 - absProgress);
      }
    });
  };

  useEffect(() => {
    if (activeIndex === swiperRef.current?.swiper.realIndex) return;
    // 修复类型错误，通过 swiperRef.current.swiper 访问 Swiper 实例
    if (swiperRef.current && swiperRef.current.swiper) {
      swiperRef.current.swiper.slideToLoop(activeIndex);
    }
  }, [activeIndex]);

  return (
    <div className='carousel-container ai-flex-1'>
      <div className='_brand-text'>AI AGENT</div>
      <div className='_welcome-text'>WELCOME</div>

      {/* Main Carousel */}
      <div className='carousel-wrapper'>
        <Swiper
          ref={swiperRef}
          grabCursor={true}
          centeredSlides={true}
          loop={true}
          slidesPerView={3}
          slideToClickedSlide
          watchSlidesProgress
          pagination={{
            el: '.swiper-pagination-custom',
            clickable: true,
            renderBullet: function (_, className) {
              return `<span class="${className}"><span class="bullet-inner"></span></span>`;
            },
          }}
          navigation={{
            nextEl: '.swiper-button-next-custom',
            prevEl: '.swiper-button-prev-custom',
          }}
          modules={[Pagination, Navigation]}
          onSlideChange={handleSlideChange}
          onProgress={handleProgress}
          className='main-swiper'
        >
          {slides.map((slide, index) => (
            <SwiperSlide key={slide.key} className='carousel-slide'>
              <div key={slide.key} className={`slide-card ${index === activeIndex ? 'active' : ''}`}>
                {/* 卡片图片 */}
                <div className='card-image'>
                  <img src={slide.image} alt={slide.title} loading='lazy' />
                </div>
              </div>
            </SwiperSlide>
          ))}
        </Swiper>

        <div className='carousel-controls'>
          <Button fill='none' className='swiper-button-prev-custom nav-btn'>
            {paginationLeftSVG}
          </Button>

          <Button fill='none' className='swiper-button-next-custom nav-btn'>
            {paginationRightSVG}
          </Button>
        </div>

        <div className='swiper-pagination-custom'></div>
      </div>

      <div className='_current'>
        <div className='_title'>{slides[activeIndex].title}</div>
        <div className='ai-flex-1'></div>
        <div className='_index'>
          [. 0{activeIndex + 1}_0{slides.length}]
        </div>
      </div>
    </div>
  );
};

export default CarouselSlider;
