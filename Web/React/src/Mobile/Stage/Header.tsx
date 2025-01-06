import { useContext, useMemo, useState } from 'react';
import { Button, Popup, Radio, SafeArea, Selector, Space, Switch, Toast } from 'antd-mobile';
import { SettingSVG, VoiceOneSVG, VoiceThreeSVG, VoiceTwoSVG } from './Icons';
import useCallStore from '@/common/store';
import i18n from '@/common/i18n';
import { AICallAgentType, AICallState } from 'aliyun-auikit-aicall';

import './header.less';
import ControllerContext from '@/common/ControlerContext';
import { RadioValue } from 'antd-mobile/es/components/radio';

import logger from '@/common/logger';
import { getRootElement } from '@/common/utils';

function Header() {
  const controller = useContext(ControllerContext);
  const agentType = useCallStore((state) => state.agentType);
  const callState = useCallStore((state) => state.callState);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);

  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const updatingPushToTalk = useCallStore((state) => state.updatingPushToTalk);

  const [settingVisible, setSettingVisible] = useState(false);

  const onVoiceInterruptChange = async (checked: boolean) => {
    const original = useCallStore.getState().enableVoiceInterrupt;
    useCallStore.setState({ enableVoiceInterrupt: checked, updatingVoiceInterrupt: true });
    const updated = await controller?.enableVoiceInterrupt(checked);

    if (updated) {
      Toast.show({
        content: `智能打断成功已${checked ? '开启' : '关闭'}`,
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
        content: '音色切换成功',
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
        content: `对讲机模式已${checked ? '开启' : '关闭'}`,
        getContainer: () => getRootElement(),
      });
    } else {
      Toast.show({
        content: '对讲机模式切换失败',
        getContainer: () => getRootElement(),
      });
    }
    // 退出对讲机模式，恢复音频静音状态
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
      return i18n['agent.avatar'];
    } else if (agentType === AICallAgentType.VisionAgent) {
      return i18n['agent.vision'];
    }
    return i18n['agent.voice'];
  }, [agentType]);

  return (
    <>
      <SafeArea position='top' />
      <div className='header'>
        {agentName}
        
        <Button
          onClick={() => {
            logger.info('Header', 'OpenSetting');
            setSettingVisible(true);
          }}
          disabled={callState !== AICallState.Connected}
        >
          {SettingSVG}
        </Button>
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
          <div className='_title'>设置</div>
          <ul>
            <li className='_mode'>
              <Selector
                options={[
                  {
                    label: '自然对话模式',
                    value: 'normal',
                  },
                  {
                    label: '对讲机模式',
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
                    <div className='_itemTitle'>智能打断</div>
                    <div className='_itemDesc'>根据声音和环境智能打断AI机器人</div>
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
              !controller?.config.fromShare &&
              (controller?.config.agentVoiceIdList.length || 0) > 0 && (
                <li className='_voiceId'>
                  <div className='_itemBox'>
                    <div className='_itemInfo'>
                      <div className='_itemTitle'>选择音色</div>
                      <div className='_itemDesc'>切换音色后，AI将在下一次回答中使用新的角色</div>
                    </div>
                  </div>
                  <Radio.Group value={voiceId} disabled={updatingVoiceId} onChange={onVoiceChange}>
                    <Space direction='vertical' block>
                      {controller?.config.agentVoiceIdList.map((voiceId, index) => {
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
