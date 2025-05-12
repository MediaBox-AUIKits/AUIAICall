import AUIAICallController from '@/controller/call/AUIAICallController';
import { AICallAgentState, AICallSpeakingInterruptedReason, AICallState } from 'aliyun-auikit-aicall';
import Lottie, { AnimationItem } from 'lottie-web';

const BASE_PATH = `${import.meta.env.BASE_URL}hero/`;

type StaticAnimation = 'Enter' | 'Head' | 'Hand';
type EyeAnimation = 'Happy' | 'Sad' | 'Interrupting' | 'Listening' | 'Speaking' | 'Thinking';
type AllAnimation = StaticAnimation | EyeAnimation | 'CoveringEyes';

type AnimationStatus = EyeAnimation | 'Error';

class HeroLottie {
  container: HTMLElement;
  controller: AUIAICallController;
  animationsMap: {
    [key in AllAnimation]?: Promise<AnimationItem>;
  } = {};
  destroyed = false;

  currentStatus?: AnimationStatus;
  nextStatus?: AnimationStatus;
  waitingStatus?: AnimationStatus;

  constructor(container: HTMLElement, controller: AUIAICallController) {
    this.container = container;
    this.controller = controller;
    this.destroyed = false;
    this.init();
  }

  public destroy() {
    this.destroyed = true;
    Object.entries(this.animationsMap).forEach(async ([key, animation]) => {
      (await animation)?.destroy();
      delete this.animationsMap[key as AllAnimation];
    });
    this.container.innerHTML = '';
    this.controller.off('AICallAgentStateChanged', this.onAgentStateChange);
    this.controller.off('AICallAgentEmotionNotify', this.onEmotionChange);
    this.controller.off('AICallSpeakingInterrupted', this.onInterrupted);
    this.controller.off('AICallStateChanged', this.onCallStateChange);
  }

  private getAnimiationFromStatus(status?: AnimationStatus) {
    let animation: AllAnimation | undefined;
    if (status === 'Error') {
      animation = 'Interrupting';
    } else {
      animation = status;
    }

    return animation;
  }

  private async loadLottie(
    container: HTMLDivElement,
    name: AllAnimation,
    pathPrefix = '',
    loop = true
  ): Promise<AnimationItem> {
    const lottieItem = Lottie.loadAnimation({
      path: `${BASE_PATH}${pathPrefix}${name}/${name}.json`,
      container,
      loop: false,
      autoplay: false,
    });

    // hide first
    lottieItem.hide();

    // reverse and play
    lottieItem.addEventListener('complete', () => {
      if (lottieItem.playDirection === 1) {
        lottieItem.setDirection(-1);
      } else {
        // no loop needed
        if (!loop) return;
        lottieItem.setDirection(1);
      }

      lottieItem.play();
    });

    return new Promise((resolve, reject) => {
      lottieItem.addEventListener('data_failed', () => {
        reject('load lottie failed');
      });
      lottieItem.addEventListener('loaded_images', () => {
        resolve(lottieItem);
      });
    });
  }

  private scheduleNextAnimation = async () => {
    const headLottieItem = await this.animationsMap.Head;

    if (headLottieItem?.playDirection === 1) {
      // Error, Stop
      if (this.currentStatus === 'Error') {
        const coveringLottieItem = await this.animationsMap['CoveringEyes'];
        coveringLottieItem?.pause();
        return;
      }

      if (this.currentStatus === 'Interrupting') {
        this.nextStatus = this.waitingStatus || 'Listening';
        this.waitingStatus = undefined;
      }
      this.toNextStatus(true);
    }
  };

  private toNextStatus = async (fromEnd = false) => {
    const nextStatus = this.nextStatus;
    if (!nextStatus) return;

    if (this.nextStatus === nextStatus) {
      const nextAnimation = this.getAnimiationFromStatus(nextStatus);
      const currentAnimation = this.getAnimiationFromStatus(this.currentStatus);
      if (!currentAnimation || !nextAnimation) return;

      const nextEyeItem = await this.animationsMap[nextAnimation];

      // 不是 Interrupting 或 Error 直接执行
      if ((currentAnimation !== 'Interrupting' && nextAnimation !== 'Interrupting') || fromEnd) {
        const currentEyeItem = await this.animationsMap[currentAnimation];

        if (currentEyeItem) {
          currentEyeItem.stop();
          currentEyeItem.hide();
        }

        nextEyeItem?.show();
        nextEyeItem?.play();

        if (
          (currentAnimation === 'Interrupting' || nextAnimation === 'Interrupting') &&
          currentAnimation !== nextAnimation
        ) {
          const coveringLottieItem = await this.animationsMap['CoveringEyes'];
          const handLottieItem = await this.animationsMap['Hand'];

          if (currentAnimation === 'Interrupting') {
            coveringLottieItem?.stop();
            coveringLottieItem?.hide();
            handLottieItem?.show();
            handLottieItem?.play();
          } else {
            coveringLottieItem?.show();
            coveringLottieItem?.play();
            handLottieItem?.stop();
            handLottieItem?.hide();
          }
        }

        this.currentStatus = nextStatus;
        this.nextStatus = undefined;
        this.waitingStatus = undefined;
      }
    }
  };
  private setNextStatus = (nextStatus?: AnimationStatus) => {
    if (!nextStatus || this.currentStatus === nextStatus) return;
    if (this.nextStatus !== 'Interrupting' && this.nextStatus !== 'Error') {
      this.nextStatus = nextStatus;
    } else if (this.nextStatus === 'Interrupting' && nextStatus === 'Error') {
      this.waitingStatus = nextStatus;
    }
    this.toNextStatus();
  };

  onAgentStateChange = (state: AICallAgentState) => {
    let nextStatus: AnimationStatus | undefined;
    if (state === AICallAgentState.Listening) {
      nextStatus = 'Listening';
    } else if (state === AICallAgentState.Thinking) {
      nextStatus = 'Thinking';
    } else if (state === AICallAgentState.Speaking) {
      if (this.currentStatus !== 'Happy' && this.currentStatus !== 'Sad') {
        nextStatus = 'Speaking';
      }
    }

    // delay to handle interrupt first
    setTimeout(() => {
      this.setNextStatus(nextStatus);
    }, 100);
  };
  onCallStateChange = (state: AICallState) => {
    if (state === AICallState.Error) {
      this.setNextStatus('Error');
    }
  };
  onEmotionChange = (emotion: string) => {
    let nextStatus: AnimationStatus | undefined;
    if (emotion === 'sad') {
      nextStatus = 'Sad';
    } else if (emotion === 'happy') {
      nextStatus = 'Happy';
    }

    this.setNextStatus(nextStatus);
  };
  onInterrupted = (reason: AICallSpeakingInterruptedReason) => {
    if (reason === AICallSpeakingInterruptedReason.byInterruptSpeaking) {
      this.setNextStatus('Interrupting');
    }
  };

  private init() {
    if (!this.container) return;
    const enterContainer = document.createElement('div');
    this.container.appendChild(enterContainer);
    const enterLottie = Lottie.loadAnimation({
      path: `${BASE_PATH}Enter/Enter.json`,
      container: enterContainer,
      loop: false,
    });

    const headContainer = document.createElement('div');
    this.container.appendChild(headContainer);
    const handContainer = document.createElement('div');
    this.container.appendChild(handContainer);
    const eyeContainer = document.createElement('div');
    this.container.appendChild(eyeContainer);
    const eyeCoveringContainer = document.createElement('div');
    this.container.appendChild(eyeCoveringContainer);

    let initPromise: Promise<AnimationItem>[] = [];
    enterLottie.addEventListener('loaded_images', () => {
      initPromise = [
        this.loadLottie(headContainer, 'Head'),
        this.loadLottie(handContainer, 'Hand'),
        this.loadLottie(eyeContainer, 'Listening', 'EyeEmotions/'),
      ];
      this.animationsMap.Head = initPromise[0];
      this.animationsMap.Hand = initPromise[1];
      this.animationsMap.Listening = initPromise[2];

      // delay to load all animations
      setTimeout(() => {
        this.animationsMap.Happy = this.loadLottie(eyeContainer, 'Happy', 'EyeEmotions/');
        this.animationsMap.Interrupting = this.loadLottie(eyeContainer, 'Interrupting', 'EyeEmotions/');
        this.animationsMap.Sad = this.loadLottie(eyeContainer, 'Sad', 'EyeEmotions/');
        this.animationsMap.Speaking = this.loadLottie(eyeContainer, 'Speaking', 'EyeEmotions/');
        this.animationsMap.Thinking = this.loadLottie(eyeContainer, 'Thinking', 'EyeEmotions/');
        this.animationsMap.CoveringEyes = this.loadLottie(eyeCoveringContainer, 'CoveringEyes');
      }, 1000);
    });

    enterLottie.addEventListener('complete', async () => {
      const items = await Promise.all(initPromise);
      enterLottie.destroy();
      if (this.destroyed) return;

      items.forEach((item) => {
        item.show();
        item.play();
      });
      this.currentStatus = 'Listening';
      this.toNextStatus();

      const [headItem] = items;
      // sync position of eys with head
      headItem.addEventListener('drawnFrame', () => {
        const currentFrame = headItem.currentFrame;

        if (eyeContainer) {
          eyeContainer.style.top = `${((currentFrame / 20) * 12 * 540) / 720}px`;
        }
      });

      headItem.addEventListener('complete', this.scheduleNextAnimation);
    });

    this.controller.on('AICallAgentStateChanged', this.onAgentStateChange);
    this.controller.on('AICallAgentEmotionNotify', this.onEmotionChange);
    this.controller.on('AICallSpeakingInterrupted', this.onInterrupted);
    this.controller.on('AICallStateChanged', this.onCallStateChange);
  }
}

export default HeroLottie;
