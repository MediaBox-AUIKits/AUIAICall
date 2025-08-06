import logger from '@/common/logger';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';
import { Button, CenterPopup, Dialog, Popup, Radio, Selector, Space, Switch, Toast } from 'antd-mobile';
import { BackSVG, DialogCloseSVG, goSVG, SettingSVG, VoiceOneSVG, VoiceThreeSVG, VoiceTwoSVG } from './Icons';
import { useTranslation } from '@/common/i18nContext';
import { getRootElement, isMobile } from '@/common/utils';
import { useContext, useEffect, useState } from 'react';
import ControllerContext from './ControlerContext';
import useCallStore from './store';
import { RadioValue } from 'antd-mobile/es/components/radio';

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

  const PopupComponent = isMobile() ? Popup : CenterPopup;

  return (
    <>
      <Button
        className='_no-border-btn _setting-btn'
        onClick={() => {
          logger.info('Header', 'OpenSetting');
          setSettingVisible(true);
        }}
        disabled={callState !== AICallState.Connected}
      >
        <span className='_icon'>{SettingSVG}</span>
        <span className='_text'>{t('settings.title')}</span>
      </Button>
      <Dialog
        className='header-pop setting-pop'
        visible={settingVisible}
        getContainer={() => getRootElement()}
        closeOnMaskClick
        onClose={() => {
          setSettingVisible(false);
        }}
        title={t('settings.title')}
        content={
          <ul>
            <li className='_mode'>
              <Selector
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
            </li>
            <li className='_delay'>
              <div className='_itemBox'>
                <div className='_itemInfo'>
                  <div className='_itemTitle'>{t('settings.latency.title')}</div>
                </div>
                <div className='_itemSwitch'>
                  <Button
                    fill='none'
                    onClick={() => {
                      setLatencyVisible(true);
                    }}
                  >
                    {t('settings.latency.toDetail')}
                    {goSVG}
                  </Button>
                </div>
              </div>
            </li>
            {!enablePushToTalk && !updatingPushToTalk && (
              <li>
                <div className='_itemBox'>
                  <div className='_itemInfo'>
                    <div className='_itemTitle'>{t('settings.interrupt.title')}</div>
                    <div className='_itemDesc'>{t('settings.interrupt.help')}</div>
                  </div>
                  <div className='_itemSwitch'>
                    <Switch
                      checked={enableVoiceInterrupt}
                      loading={updatingVoiceInterrupt}
                      onChange={onVoiceInterruptChange}
                    />
                  </div>
                </div>
              </li>
            )}

            {/* <li>
            <div className='_itemBox'>
              <div className='_itemInfo'>
                <div className='_itemTitle'>{t('settings.voiceprint.title')}</div>
                <div className='_itemDesc'>{t('settings.voiceprint.help')}</div>
              </div>
              <div className='_itemSwitch'>
                <Switch checked={enableVoiceprint} loading={updatingVoiceprint} onChange={onVoiceprintChange} />
              </div>
            </div>
          </li> */}

            {agentType !== AICallAgentType.AvatarAgent &&
              agentType !== AICallAgentType.VideoAgent &&
              (agentVoiceIdList.length || 0) > 0 && (
                <li
                  className='_voiceId'
                  style={{
                    // @ts-expect-error custom style
                    '--btn-text': JSON.stringify(t('common.use')),
                  }}
                >
                  <div className='_itemBox'>
                    <div className='_itemInfo'>
                      <div className='_itemTitle'>{t('settings.voiceId.title')}</div>
                      <div className='_itemDesc'>{t('settings.voiceId.help')}</div>
                    </div>
                  </div>
                  <Radio.Group value={voiceId} disabled={updatingVoiceId} onChange={onVoiceChange}>
                    <Space direction='vertical' block>
                      {agentVoiceIdList.map((voiceId, index) => {
                        const iconIndex = index % 3;
                        const VoiceSVG = [VoiceOneSVG, VoiceTwoSVG, VoiceThreeSVG][iconIndex];
                        return (
                          <Radio key={voiceId} value={voiceId}>
                            <span className='_voiceIcon'>{VoiceSVG}</span>
                            <span className='_voiceName'>{voiceId}</span>
                          </Radio>
                        );
                      })}
                    </Space>
                  </Radio.Group>
                </li>
              )}
          </ul>
        }
      />

      <PopupComponent
        className='setting-latency-pop'
        visible={latencyVisible}
        onMaskClick={() => setLatencyVisible(false)}
        getContainer={() => getRootElement()}
        position='right'
      >
        <div className='_box'>
          <div className='_hd'>
            <Button className='_back' fill='none' onClick={() => setLatencyVisible(false)}>
              {BackSVG}
            </Button>
            <Button className='_close' fill='none' onClick={() => setLatencyVisible(false)}>
              {DialogCloseSVG}
            </Button>
            <div className='_title'>{t('settings.latency.title')}</div>
          </div>
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
      </PopupComponent>
    </>
  );
}

export default Setting;
