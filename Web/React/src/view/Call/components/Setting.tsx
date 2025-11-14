import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';
import { Button, Form, Selector, Switch, Toast } from 'antd-mobile';
import { RadioValue } from 'antd-mobile/es/components/radio';
import { useContext, useEffect, useState } from 'react';

import { useTranslation } from '@/common/i18nContext';
import logger from '@/common/logger';
import { getRootElement } from '@/common/utils';
import { getWorkflowType } from '@/service/interface';
import settingVoiceImg1 from '@/view/images/setting_voice_1.png';
import settingVoiceImg2 from '@/view/images/setting_voice_2.png';
import ResponsiveDialog from 'components/ReponsiveDialog';
import ResponsivePopup from 'components/ResponsivePopup';

import ControllerContext from '../ControlerContext';
import useCallStore from '../store';
import { headerSettingSVG, settingSelectedSVG } from './Icons';


import './setting.less';

function Setting() {
  const { t } = useTranslation();
  const controller = useContext(ControllerContext);

  const callState = useCallStore((state) => state.callState);
  const agentType = useCallStore((state) => state.agentType);

  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  // const enableVoiceprint = useCallStore((state) => state.enableVoiceprint);
  // const updatingVoiceprint = useCallStore((state) => state.updatingVoiceInterrupt);

  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);

  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const updatingPushToTalk = useCallStore((state) => state.updatingPushToTalk);

  const agentVoiceIdList = useCallStore((state) => state.agentVoiceIdList);

  const latencyStats = useCallStore((state) => state.latencyStats);

  const [settingVisible, setSettingVisible] = useState(false);

  const [latencyVisible, setLatencyVisible] = useState(false);


  useEffect(() => {
    if (!settingVisible) {
      setLatencyVisible(false);
    }
  }, [settingVisible]);

  const onVoiceInterruptChange = async (checked: boolean) => {
    const original = useCallStore.getState().enableVoiceInterrupt;
    useCallStore.setState({ enableVoiceInterrupt: checked, updatingVoiceInterrupt: true });
    const updated = await controller?.enableVoiceInterrupt(checked);

    if (updated) {
      Toast.show({
        content: checked ? t('settings.interrupt.enabled') : t('settings.interrupt.disabled'),
        getContainer: () => getRootElement(),
      });
    }
    useCallStore.setState({ enableVoiceInterrupt: updated ? checked : original, updatingVoiceInterrupt: false });
  };

  // const onVoiceprintChange = async (checked: boolean) => {
  //   if (!useCallStore.getState().voiceprintId) {
  //     Toast.show({
  //       content: '声纹特征未录入，声纹识别功能暂不可用',
  //       getContainer: () => getRootElement(),
  //     });

  //     return;
  //   }
  //   const original = useCallStore.getState().enableVoiceprint;
  //   useCallStore.setState({ enableVoiceprint: checked, updatingVoiceprint: true });
  //   const updated = await controller?.enableVoiceprint(checked);
  //   if (updated) {
  //     Toast.show({
  //       content: checked ? t('settings.voiceprint.enabled') : t('settings.voiceprint.disabled'),
  //       getContainer: () => getRootElement(),
  //     });
  //   }
  //   useCallStore.setState({ enableVoiceprint: updated ? checked : original, updatingVoiceprint: false });
  // };

  const onVoiceChange = async (_voiceId: RadioValue) => {
    const voiceId = _voiceId as string;
    const original = useCallStore.getState().voiceId;
    useCallStore.setState({ voiceId: voiceId, updatingVoiceId: true });

    const updated = await controller?.switchVoiceId(voiceId);
    if (updated) {
      Toast.show({
        content: t('settings.voiceId.success'),
        getContainer: () => getRootElement(),
      });
    }
    useCallStore.setState({ voiceId: updated ? voiceId : original, updatingVoiceId: false });
  };

  const onPushToTalkChange = async (value: string) => {
    const checked = value === 'pushToTalk';
    const original = useCallStore.getState().enablePushToTalk;
    useCallStore.setState({ enablePushToTalk: checked, updatingPushToTalk: true });
    const updated = await controller?.enablePushToTalk(checked);
    if (updated) {
      Toast.show({
        content: checked ? t('settings.pushToTalk.enabled') : t('settings.pushToTalk.disabled'),
        getContainer: () => getRootElement(),
      });
    } else {
      Toast.show({
        content: t('settings.pushToTalk.failed'),
        getContainer: () => getRootElement(),
      });
    }
    // 退出对讲机模式，恢复音频静音状态
    // exit push to talk mode, restore mute status
    if (!checked) {
      if (useCallStore.getState().microphoneMuted) {
        controller?.muteMicrophone(true);
      } else {
        controller?.muteMicrophone(false);
      }
    }
    useCallStore.setState({ enablePushToTalk: updated ? checked : original, updatingPushToTalk: false });
  };

  return (
    <>
      <Button
        className='_setting-btn'
        fill='none'
        onClick={() => {
          logger.info('Header', 'OpenSetting');
          setSettingVisible(true);
        }}
        disabled={callState !== AICallState.Connected}
      >
        {headerSettingSVG}
        <span className='_text'>{t('settings.title')}</span>
      </Button>
      <ResponsivePopup
        visible={settingVisible}
        onClose={() => {
          setSettingVisible(false);
        }}
        title={t('settings.title')}
      >
        <Form layout='horizontal' className='ai-form ai-setting-form'>
          <Form.Item label={t('settings.mode.title')} className='_mode'>
            <Selector
              columns={2}
              options={[
                {
                  label: t('settings.mode.natural'),
                  value: 'normal',
                },
                {
                  label: t('settings.mode.pushToTalk'),
                  value: 'pushToTalk',
                },
              ]}
              value={[enablePushToTalk ? 'pushToTalk' : 'normal']}
              onChange={(v) => {
                if (v.length) {
                  onPushToTalkChange(v[0]);
                }
              }}
            />
          </Form.Item>

          {(agentType === AICallAgentType.VoiceAgent || agentType === AICallAgentType.VisionAgent) && (
            <Form.Item
              label={t('settings.latency.title')}
              onClick={() => {
                setLatencyVisible(true);
              }}
            >
              <span className='ai-link-text'>{t('settings.latency.toDetail')}</span>
            </Form.Item>
          )}


          {!enablePushToTalk && !updatingPushToTalk && (
            <>
              <Form.Item label={t('settings.interrupt.title')}>
                <Switch
                  checked={enableVoiceInterrupt}
                  loading={updatingVoiceInterrupt}
                  onChange={onVoiceInterruptChange}
                />
              </Form.Item>
              <Form.Item className='is-follow' description={t('settings.interrupt.help')} />
            </>
          )}

          {(agentVoiceIdList.length || 0) > 0 && (
            <>
              <Form.Item
                layout='vertical'
                label={t('settings.voiceId.title')}
                description={t('settings.voiceId.help')}
              />

              <Form.Item className='_voice-id is-follow'>
                <Selector
                  columns={1}
                  options={agentVoiceIdList.map((voiceId, index) => {
                    const [id, value] = voiceId.split(':');
                    return {
                      label: (
                        <div className='_voice-id-item'>
                          <img src={index % 2 === 0 ? settingVoiceImg1 : settingVoiceImg2} alt='' />
                          <span className='_title'>{value || id}</span>
                          <div className='ai-flex-1'></div>
                          <div className='_tip'>
                            <span className='_tip-text'>{t('common.use')}</span>
                            {settingSelectedSVG}
                          </div>
                        </div>
                      ),
                      value: id,
                    };
                  })}
                  value={[voiceId]}
                  disabled={updatingVoiceId}
                  onChange={(v) => {
                    if (v.length) {
                      onVoiceChange(v[0]);
                    }
                  }}
                />
              </Form.Item>
            </>
          )}
        </Form>
      </ResponsivePopup>

      <ResponsiveDialog
        title={t('settings.latency.title')}
        className='setting-latency-pop'
        visible={latencyVisible}
        closeOnMaskClick
        onClose={() => {
          setLatencyVisible(false);
        }}
        content={
          <div className='_box'>
            <div className='_type'>
              <div className='_type-title'>{t('settings.latency.type')}</div>
              <div className='_type-tip'>{t('settings.latency.tip')}</div>
            </div>
            <ol className='_list'>
              {latencyStats.map((item) => {
                return (
                  <li key={item.AIPub?.aAIClientScentenceId}>
                    <div className='_id'>
                      <div className='_id-name'>sentenceId</div>
                      <div className='_id-num'>{item.AIPub?.aAIClientScentenceId || ''}</div>
                    </div>
                    <div className='_value'>
                      <div className='value'>{item.AIAgent.aiagenttotalcost || 0}ms</div>
                    </div>
                  </li>
                );
              })}
            </ol>
          </div>
        }
      />
    </>
  );
}

export default Setting;
