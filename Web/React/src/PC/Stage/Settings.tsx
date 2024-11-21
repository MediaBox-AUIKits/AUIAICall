import { Button, Form, Popover, Radio, RadioChangeEvent, Space, Switch, message } from 'antd';

import './settings.less';
import useCallStore from '@/common/store';
import { useContext } from 'react';
import ControllerContext from '@/common/ControlerContext';
import { AICallAgentType } from 'aliyun-auikit-aicall';
import i18n from '@/common/i18n';
import Icon from '@ant-design/icons';
import SettingSvg from './svg/setting.svg?react';

const layout = {
  labelCol: { span: 8 },
  wrapperCol: { span: 16 },
};

function CallSettingsPopover() {
  const [messageApi, contextHolder] = message.useMessage();
  const controller = useContext(ControllerContext);

  const enablePushToTalk = useCallStore((state) => state.enablePushToTalk);
  const updatingPushToTalk = useCallStore((state) => state.updatingPushToTalk);
  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);
  const agentType = useCallStore((state) => state.agentType);

  const onPushToTalkChange = async (e: RadioChangeEvent) => {
    const checked = e.target.value === 'pushToTalk';
    const original = useCallStore.getState().enablePushToTalk;
    useCallStore.setState({ enablePushToTalk: checked, updatingPushToTalk: true });
    const updated = await controller?.enablePushToTalk(checked);
    if (updated) {
      messageApi.success(`对讲机模式已${checked ? '开启' : '关闭'}`);
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

  const onVoiceInterruptChange = async (checked: boolean) => {
    const original = useCallStore.getState().enableVoiceInterrupt;
    useCallStore.setState({ enableVoiceInterrupt: checked, updatingVoiceInterrupt: true });
    const updated = await controller?.enableVoiceInterrupt(checked);

    if (updated) {
      messageApi.success(`智能打断成功已${checked ? '开启' : '关闭'}`);
    }
    useCallStore.setState({ enableVoiceInterrupt: updated ? checked : original, updatingVoiceInterrupt: false });
  };

  const onVoiceChange = async (e: RadioChangeEvent) => {
    const original = useCallStore.getState().voiceId;
    useCallStore.setState({ voiceId: e.target.value, updatingVoiceId: true });

    const updated = await controller?.switchVoiceId(e.target.value);
    if (updated) {
      messageApi.success('音色切换成功');
    }
    useCallStore.setState({ voiceId: updated ? e.target.value : original, updatingVoiceId: false });
  };

  return (
    <Form {...layout} colon={false} labelAlign='left' className='voice-call-settings-form'>
      {contextHolder}
      <Form.Item label={i18n['setting.modeTitle']} className='_mode'>
        <Radio.Group
          name='mode'
          value={enablePushToTalk ? 'pushToTalk' : 'normal'}
          disabled={updatingPushToTalk}
          onChange={onPushToTalkChange}
        >
          <Space direction='vertical'>
            <Radio value='normal'>自然对话模式</Radio>
            <Radio value='pushToTalk'>对讲机模式</Radio>
          </Space>
        </Radio.Group>
      </Form.Item>

      {!enablePushToTalk && !updatingPushToTalk && (
        <Form.Item label={i18n['setting.voiceInterruptTitle']} help={i18n['setting.voiceInterruptHelp']}>
          <Switch checked={enableVoiceInterrupt} disabled={updatingVoiceInterrupt} onChange={onVoiceInterruptChange} />
        </Form.Item>
      )}

      {/* 3D数字人不支持切换音色，防止出现声音与形象不符的情况 */}
      {agentType !== AICallAgentType.AvatarAgent && (
        <Form.Item label={i18n['setting.voiceIdTitle']} help={i18n['setting.voiceIdHelp']}>
          <Radio.Group name='voiceId' value={voiceId} disabled={updatingVoiceId} onChange={onVoiceChange}>
            <Space direction='vertical'>
              <Radio value='zhixiaobai'>智小白</Radio>
              <Radio value='zhixiaoxia'>智小夏</Radio>
              <Radio value='abin'>阿斌</Radio>
            </Space>
          </Radio.Group>
        </Form.Item>
      )}
    </Form>
  );
}

function CallSettings() {
  return (
    <Popover
      overlayClassName='stage-settings-content'
      placement='bottomRight'
      arrow={false}
      title='设置'
      content={<CallSettingsPopover />}
      trigger='click'
    >
      <Button>
        <Icon component={SettingSvg} />
        设置
      </Button>
    </Popover>
  );
}

export default CallSettings;
