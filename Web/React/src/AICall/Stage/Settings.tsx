import { Form, Radio, RadioChangeEvent, Space, Switch, message } from 'antd';

import './settings.less';
import useCallStore from '../store';
import { useContext } from 'react';
import ControllerContext from '../../ControlerContext';
import { AICallAgentType } from 'aliyun-auikit-aicall';
import i18n from '../i18n';

const layout = {
  labelCol: { span: 8 },
  wrapperCol: { span: 16 },
};

function CallSettings() {
  const [messageApi, contextHolder] = message.useMessage();
  const controller = useContext(ControllerContext);

  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);
  const agentType = useCallStore((state) => state.agentType);

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
      <Form.Item label={i18n['setting.voiceInterruptTitle']} help={i18n['setting.voiceInterruptHelp']}>
        <Switch checked={enableVoiceInterrupt} disabled={updatingVoiceInterrupt} onChange={onVoiceInterruptChange} />
      </Form.Item>

      {agentType === AICallAgentType.VoiceAgent && (
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

export default CallSettings;
