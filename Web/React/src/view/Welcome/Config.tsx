import { Button, Dialog, Form, SafeArea, Selector, Switch, Toast } from 'antd-mobile';
import { ToastHandler } from 'antd-mobile/es/components/toast';
import { useEffect, useRef, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import { getRootElement } from '@/common/utils';
import standard from '@/service/standard';
import ResponsiveDialog from 'components/ReponsiveDialog';

import { headerSettingSvg } from '../components/Icons';
import ResponsivePopup from '../components/ResponsivePopup';
import { useResponsiveBreakpoint } from '../hooks/useResponsiveBreakpoint';
import { settingSVG, voiceprintRecordingSVG, voiceprintRecordSVG } from './Icons';
import voicePrintHeroImg from './images/voice_print.png';
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
      title={t('voiceprint.title')}
      className='voice-print-dialog'
      content={
        <>
          <img className='_hero' src={voicePrintHeroImg} alt='voiceprint' />
          <div className='_gap'></div>
          <div className='_info'>
            <div>{t('voiceprint.intro')}</div>
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
          </div>
          <div className='_gap'></div>
          <div className='_action'>
            <Button
              className={`_record-btn ${isRecording ? 'is-recording' : ''}`}
              onTouchStart={startRecord}
              onTouchEnd={stopRecord}
              onMouseDown={startRecord}
              onMouseUp={stopRecord}
            >
              {isRecording ? voiceprintRecordingSVG : voiceprintRecordSVG}
            </Button>
            <div className='_text'>{t('pushToTalk.tip')}</div>
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

  const isMobileUI = useResponsiveBreakpoint();

  return (
    <>
      <Button
        fill='none'
        onClick={() => {
          setConfigVisible(true);
        }}
      >
        {isMobileUI ? settingSVG : headerSettingSvg}
      </Button>

      <ResponsivePopup
        visible={configVisible}
        onClose={() => {
          setConfigVisible(false);
        }}
        className='welcome-config-dialog'
        title={t('welcome.optionsTitle')}
      >
        <Form layout='horizontal' className='ai-form ai-welcome-config-form'>
          <Form.Item label={t('voiceprint.noiseReduction')}>
            <Switch
              onChange={(checked: boolean) => {
                localStorage?.setItem(VOICE_PRINT_CACHE_ENABLE, checked ? 'true' : 'false');
              }}
              defaultChecked={
                !!localStorage?.getItem(`${VOICE_PRINT_CACHE_PREFIX}${userId}`) &&
                localStorage?.getItem(VOICE_PRINT_CACHE_ENABLE) !== 'false'
              }
            />
          </Form.Item>
          <Form.Item className='is-follow' description={t('voiceprint.help')} />
          <Form.Item
            className='_voiceprint'
            label={t('voiceprint.title')}
            onClick={() => setVoicePrintDialogVisible(true)}
          >
            <span className='ai-link-text'>{hasVoicePrint ? t('voiceprint.enrolled') : t('voiceprint.enroll')}</span>
          </Form.Item>
        </Form>
      </ResponsivePopup>
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
