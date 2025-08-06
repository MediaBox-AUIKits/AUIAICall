import { useTranslation } from '@/common/i18nContext';
import { getRootElement } from '@/common/utils';
import {
  Button,
  Dialog,
  SafeArea,
  Switch,
  Toast,
} from 'antd-mobile';
import { useEffect, useRef, useState } from 'react';

import standard from '@/service/standard';
import { ConfigSVG } from '@/view/Call/Icons';
import ResponsiveDialog from '@/view/components/ReponsiveDialog';
import { ToastHandler } from 'antd-mobile/es/components/toast';
import { moreSVG, recordSVG } from './Icons';
import AudioRecorder, { encodeWAV, RecordingController, uploadBlobToOSSDirect } from './recorder';

import './config.less';

export const VOICE_PRINT_CACHE_PREFIX = 'ai_call_voiceprint_';
export const VOICE_PRINT_CACHE_ENABLE = 'ai_call_voiceprint_enable';

function VoicePrintDialog({
  visible,
  onClose,
  userId,
  region = 'cn-shanghai',
  onSetted,
  onAuthFail,
}: {
  visible: boolean;
  onClose: () => void;
  userId: string;
  region?: string;
  onSetted?: () => void;
  onAuthFail?: () => void;
}) {
  const { t } = useTranslation();
  const [isIntro, setIsIntro] = useState(true);
  const [isRecording, setIsRecording] = useState(false);

  const recorderControllerRef = useRef<RecordingController>();
  const waitingStartRef = useRef<ToastHandler>();
  const submittingRef = useRef<ToastHandler>();
  const startTimeRef = useRef<number>(0);
  const countdownRef = useRef<HTMLSpanElement>(null);
  const countdownTimerRef = useRef<number>();

  const stopRecord = async () => {
    waitingStartRef.current?.close();
    setIsRecording(false);
    window.clearInterval(countdownTimerRef.current);
    if (!recorderControllerRef.current) return;

    submittingRef.current = Toast.show({
      icon: 'loading',
      content: t('voiceprint.uploading'),
      getContainer: getRootElement,
      duration: 0,
      position: 'center',
      maskClickable: false,
      maskClassName: 'voice-print-submitting',
    });

    try {
      const audioData = await recorderControllerRef.current.stop();
      const wavBuffer = encodeWAV(
        audioData,
        recorderControllerRef.current.sampleRate || 48000
      ) as unknown as ArrayBuffer;
      const blob = new Blob([wavBuffer], { type: 'audio/wav' });
      const ossConfig = await standard.getOssConfig(userId || '');
      const fileUrl = await uploadBlobToOSSDirect(blob, `webrecord_${userId}_${Date.now()}.wav`, ossConfig);

      const vid = `voiceprint_${userId}_${Date.now()}`;
      await standard.setAIAgentVoiceprint(
        userId!,
        region,
        vid,
        JSON.stringify({
          Type: 'oss',
          Data: fileUrl,
          Format: 'wav',
        })
      );

      localStorage?.setItem(`${VOICE_PRINT_CACHE_PREFIX}${userId}`, vid);
      onSetted?.();
    } catch (error) {
      if ((error as Error)?.name === 'ServiceAuthError') {
        onAuthFail?.();
        return;
      }

      Dialog.show({
        content:
          (error as Error)?.name === 'InvalidAudioDuration' ? (
            t('voiceprint.tooShort')
          ) : (
            <>
              {t('voiceprint.failed')}
              {(error as Error).message ? <div>{(error as Error).message}</div> : null}
            </>
          ),
        closeOnAction: true,
        actions: [
          {
            key: 'confirm',
            text: t('common.confirm'),
          },
        ],
      });
    } finally {
      recorderControllerRef.current = undefined;
      submittingRef.current?.close();
    }
  };

  const startRecord = async () => {
    const recorder = new AudioRecorder();
    waitingStartRef.current = Toast.show({
      icon: 'loading',
      content: t('common.confirm'),
      getContainer: getRootElement,
      duration: 0,
      position: 'center',
    });
    const recordingController = await recorder.startRecording();
    waitingStartRef.current?.close();
    recorderControllerRef.current = recordingController;
    startTimeRef.current = Date.now();

    countdownTimerRef.current = window.setInterval(() => {
      const duration = Date.now() - startTimeRef.current;
      if (countdownRef.current) {
        countdownRef.current.innerText = `${Math.round(duration / 1000)}`;
      }
      if (duration >= 59 * 1000) {
        stopRecord();
      }
    }, 1000);

    setIsRecording(true);
  };

  useEffect(() => {
    const handleClick = () => {
      recorderControllerRef.current?.stop();
      recorderControllerRef.current = undefined;
    };
    document.addEventListener('click', handleClick);
    return () => {
      document.removeEventListener('click', handleClick);
    };
  }, []);

  return (
    <ResponsiveDialog
      visible={visible}
      onClose={onClose}
      closeOnMaskClick
      title={t('voiceprint.title')}
      className='voice-print-dialog'
      content={
        <>
          <img
            className='_hero'
            src='https://img.alicdn.com/imgextra/i2/O1CN01H1olll1c8hUDELAcD_!!6000000003556-2-tps-339-338.png'
            alt='voiceprint'
          />
          <div className='_gap'></div>
          <div className='_info'>
            {isIntro ? (
              <div>{t('voiceprint.intro')}</div>
            ) : (
              <>
                <div>{t('voiceprint.instruction')}</div>
                <div className='_duration'>
                  {isRecording ? (
                    <span>
                      {t('voiceprint.recording')} <span ref={countdownRef}>0</span> {t('voiceprint.recordingSecond')}
                    </span>
                  ) : (
                    <span>{t('voiceprint.duration')}</span>
                  )}
                </div>
                <div className='_text'>{t('voiceprint.instructionText')}</div>
              </>
            )}
          </div>
          <div className='_gap'></div>
          <div className='_action'>
            {isIntro ? (
              <Button className='_btn' color='primary' onClick={() => setIsIntro(false)}>
                {t('voiceprint.enroll')}
              </Button>
            ) : (
              <>
                <Button
                  className={`_record-btn ${isRecording ? 'is-recording' : ''}`}
                  onTouchStart={startRecord}
                  onTouchEnd={stopRecord}
                  onMouseDown={startRecord}
                  onMouseUp={stopRecord}
                >
                  {recordSVG}
                </Button>
                <div className='_text'>{t('pushToTalk.tip')}</div>
              </>
            )}
          </div>
          <SafeArea position='bottom' />
        </>
      }
    ></ResponsiveDialog>
  );
}


function WelcomeConfig({ userId, region, onAuthFail }: { userId: string; region?: string; onAuthFail?: () => void }) {
  const { t } = useTranslation();

  const [configVisible, setConfigVisible] = useState(false);


  const [voicePrintDialogVisible, setVoicePrintDialogVisible] = useState(false);
  const [hasVoicePrint, setHasVoicePrint] = useState(!!localStorage?.getItem(`${VOICE_PRINT_CACHE_PREFIX}${userId}`));

  return (
    <>
        <Button
          className='welcome-config'
          onClick={() => {
            setConfigVisible(true);
          }}
        >
          {ConfigSVG}
          <div>{t('welcome.optionsTitle')}</div>
        </Button>
      <Dialog
        className='welcome-config-dialog'
        visible={configVisible}
        getContainer={() => getRootElement()}
        closeOnMaskClick
        title={t('welcome.optionsTitle')}
        onClose={() => {
          setConfigVisible(false);
        }}
        content={
          <div>
            <ul>
              <li className='_mode'>
                <div className='_itemBox'>
                  <div className='_itemInfo'>
                    <div className='_itemTitle'>{t('voiceprint.noiseReduction')}</div>
                    <div className='_itemDesc'>{t('voiceprint.help')}</div>
                  </div>
                  <Switch
                    onChange={(checked: boolean) => {
                      localStorage?.setItem(VOICE_PRINT_CACHE_ENABLE, checked ? 'true' : 'false');
                    }}
                    defaultChecked={
                      !!localStorage?.getItem(`${VOICE_PRINT_CACHE_PREFIX}${userId}`) &&
                      localStorage?.getItem(VOICE_PRINT_CACHE_ENABLE) !== 'false'
                    }
                    style={{
                      '--height': '18px',
                      '--width': '36px',
                    }}
                  />
                </div>
                <div className='welcome-voice-print-config'>
                  {t('voiceprint.title')}
                  {hasVoicePrint ? t('voiceprint.enrolled') : ''}
                  <span className='_holder'></span>
                  <Button fill='none' onClick={() => setVoicePrintDialogVisible(true)}>
                    {t('voiceprint.enroll')}
                    {moreSVG}
                  </Button>
                </div>
              </li>
            </ul>
          </div>
        }
      />
      <VoicePrintDialog
        visible={voicePrintDialogVisible}
        onClose={() => setVoicePrintDialogVisible(false)}
        userId={userId}
        region={region}
        onSetted={() => {
          setHasVoicePrint(true);
          setVoicePrintDialogVisible(false);
        }}
        onAuthFail={onAuthFail}
      />
    </>
  );
}
export default WelcomeConfig;
