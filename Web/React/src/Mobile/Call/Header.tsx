import { useContext, useMemo, useState } from 'react';
import { Button, Popup, Radio, SafeArea, Selector, Space, Switch, Toast } from 'antd-mobile';
import { SettingSVG, VoiceOneSVG, VoiceThreeSVG, VoiceTwoSVG } from './Icons';
import useCallStore from '@/Mobile/Call/store';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import ControllerContext from '@/Mobile/Call/ControlerContext';
import { RadioValue } from 'antd-mobile/es/components/radio';
import logger from '@/common/logger';
import { getRootElement } from '@/common/utils';
import { useTranslation } from '@/common/i18nContext';
import SubtitleList from './SubtitleList';
import './header.less';


function Header() {
  const controller = useContext(ControllerContext);
  const { t } = useTranslation();
  const agentType = useCallStore((state) => state.agentType);
  const callState = useCallStore((state) => state.callState);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);

  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const updatingPushToTalk = useCallStore((state) => state.updatingPushToTalk);

  const agentVoiceIdList = useCallStore((state) => state.agentVoiceIdList);

  const [settingVisible, setSettingVisible] = useState(false);
  const [subtitleListVisible, setSubtitleListVisible] = useState(false);
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

  const agentName = useMemo(() => {
    if (agentType === AICallAgentType.AvatarAgent) {
      return t('agent.avatar');
    } else if (agentType === AICallAgentType.VisionAgent) {
      return t('agent.vision');
    } else if (agentType === AICallAgentType.VideoAgent) {
      return t('agent.video');
    }
    return t('agent.voice');
  }, [agentType, t]);

  return (
    <>
      <SafeArea position='top' />
      <div className='header'>
        {agentName}

        <SubtitleList onVisibleChange={setSubtitleListVisible} />
        {!subtitleListVisible && (
          <Button
            className='_no-border-btn'
            onClick={() => {
              logger.info('Header', 'OpenSetting');
              setSettingVisible(true);
            }}
            disabled={callState !== AICallState.Connected}
          >
            {SettingSVG}
          </Button>
        )}
        <Popup
          className='header-pop setting-pop'
          visible={settingVisible}
          getContainer={() => getRootElement()}
          onMaskClick={() => {
            setSettingVisible(false);
          }}
          onClose={() => {
            setSettingVisible(false);
          }}
        >
          <div className='_title'>{t('settings.title')}</div>
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
            {agentType !== AICallAgentType.AvatarAgent &&
              agentType !== AICallAgentType.VideoAgent &&
              (agentVoiceIdList.length || 0) > 0 && (
                <li
                  className='_voiceId'
                  style={{
                    // @ts-expect-error custom style
                    '--btn-text': JSON.stringify(t('common.use')),
                  }}
                  dataText={t('common.use')}
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
          <SafeArea position='bottom' />
        </Popup>
      </div>
    </>
  );
}

export default Header;
