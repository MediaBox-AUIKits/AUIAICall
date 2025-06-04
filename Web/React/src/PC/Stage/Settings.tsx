import { Button, Form, Popover, Radio, RadioChangeEvent, Space, Switch, message } from 'antd';

import './settings.less';
import useCallStore from '@/Mobile/Call/store';
import { useContext } from 'react';
import ControllerContext from '@/Mobile/Call/ControlerContext';
import { AICallAgentType } from 'aliyun-auikit-aicall';
import Icon from '@ant-design/icons';
import SettingSvg from './svg/setting.svg?react';
import { useTranslation } from '@/common/i18nContext';

const layout = {
  labelCol: { span: 8 },
  wrapperCol: { span: 16 },
};

function CallSettingsPopover() {
  const { t } = useTranslation();

  const [messageApi, contextHolder] = message.useMessage();
  const controller = useContext(ControllerContext);

  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const updatingPushToTalk = useCallStore((state) => state.updatingPushToTalk);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);
  const agentType = useCallStore((state) => state.agentType);
  const agentVoiceIdList = useCallStore((state) => state.agentVoiceIdList);

  const onPushToTalkChange = async (e: RadioChangeEvent) => {
    const checked = e.target.value === 'pushToTalk';
    const original = useCallStore.getState().enablePushToTalk;
    useCallStore.setState({ enablePushToTalk: checked, updatingPushToTalk: true });
    const updated = await controller?.enablePushToTalk(checked);
    if (updated) {
      messageApi.success(checked ? t('settings.pushToTalk.enabled') : t('settings.pushToTalk.disabled'));
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

  const onVoiceInterruptChange = async (checked: boolean) => {
    const original = useCallStore.getState().enableVoiceInterrupt;
    useCallStore.setState({ enableVoiceInterrupt: checked, updatingVoiceInterrupt: true });
    const updated = await controller?.enableVoiceInterrupt(checked);

    if (updated) {
      messageApi.success(checked ? t('settings.interrupt.enabled') : t('settings.interrupt.disabled'));
    }
    useCallStore.setState({ enableVoiceInterrupt: updated ? checked : original, updatingVoiceInterrupt: false });
  };

  const onVoiceChange = async (e: RadioChangeEvent) => {
    const original = useCallStore.getState().voiceId;
    useCallStore.setState({ voiceId: e.target.value, updatingVoiceId: true });

    const updated = await controller?.switchVoiceId(e.target.value);
    if (updated) {
      messageApi.success(t('settings.voiceId.success'));
    }
    useCallStore.setState({ voiceId: updated ? e.target.value : original, updatingVoiceId: false });
  };

  return (
    <Form {...layout} colon={false} labelAlign='left' className='voice-call-settings-form'>
      {contextHolder}
      <Form.Item label={t('settings.mode.title')} className='_mode'>
        <Radio.Group
          name='mode'
          value={enablePushToTalk ? 'pushToTalk' : 'normal'}
          disabled={updatingPushToTalk}
          onChange={onPushToTalkChange}
        >
          <Space direction='vertical'>
            <Radio value='normal'>{t('settings.mode.natural')}</Radio>
            <Radio value='pushToTalk'>{t('settings.mode.pushToTalk')}</Radio>
          </Space>
        </Radio.Group>
      </Form.Item>

      {!enablePushToTalk && !updatingPushToTalk && (
        <Form.Item label={t('settings.interrupt.title')} help={t('settings.interrupt.help')}>
          <Switch checked={enableVoiceInterrupt} disabled={updatingVoiceInterrupt} onChange={onVoiceInterruptChange} />
        </Form.Item>
      )}

      {agentType !== AICallAgentType.AvatarAgent &&
        agentType !== AICallAgentType.VideoAgent &&
        (agentVoiceIdList.length || 0) > 0 && (
          <Form.Item label={t('settings.voiceId.title')} help={t('settings.voiceId.help')}>
            <Radio.Group name='voiceId' value={voiceId} disabled={updatingVoiceId} onChange={onVoiceChange}>
              <Space direction='vertical'>
                {agentVoiceIdList.map((voiceId, index) => {
                  return (
                    <Radio key={index} value={voiceId}>
                      {voiceId}
                    </Radio>
                  );
                })}
              </Space>
            </Radio.Group>
          </Form.Item>
        )}
    </Form>
  );
}

function CallSettings() {
  const { t } = useTranslation();

  return (
    <Popover
      overlayClassName='stage-settings-content'
      placement='bottomRight'
      arrow={false}
      title={t('settings.title')}
      content={<CallSettingsPopover />}
      trigger='click'
    >
      <Button>
        <Icon component={SettingSvg} />
        {t('settings.title')}
      </Button>
    </Popover>
  );
}

export default CallSettings;
