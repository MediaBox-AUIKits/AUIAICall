import { Form, Radio, RadioChangeEvent, Space, Switch, message } from 'antd';

import './settings.less';
import useCallStore from '../store';
import { updateAIAgent } from '../../api/service';

const layout = {
  labelCol: { span: 8 },
  wrapperCol: { span: 16 },
};

function CallSettings() {
  const [messageApi, contextHolder] = message.useMessage();

  const enableVoiceInterrupt = useCallStore((state) => state.enableVoiceInterrupt);
  const updatingVoiceInterrupt = useCallStore((state) => state.updatingVoiceInterrupt);
  const voiceId = useCallStore((state) => state.voiceId);
  const updatingVoiceId = useCallStore((state) => state.updatingVoiceId);

  const onVoiceInterruptChange = (checked: boolean) => {
    const agentInstanceId = useCallStore.getState().agentInfo?.ai_agent_instance_id;
    if (!agentInstanceId) return;

    const original = useCallStore.getState().enableVoiceInterrupt;
    useCallStore.setState({ enableVoiceInterrupt: checked, updatingVoiceInterrupt: true });
    updateAIAgent(agentInstanceId, {
      VoiceChat: {
        EnableVoiceInterrupt: checked,
      },
    })
      .catch((error: unknown) => {
        console.error('updateAIAgent error', error);
        return false;
      })
      .then((updated) => {
        if (updated) {
          messageApi.success(`智能打断成功已${checked ? '开启' : '关闭'}`);
        }
        useCallStore.setState({ enableVoiceInterrupt: updated ? checked : original, updatingVoiceInterrupt: false });
      });
  };

  const onVoiceChange = (e: RadioChangeEvent) => {
    const agentInstanceId = useCallStore.getState().agentInfo?.ai_agent_instance_id;
    if (!agentInstanceId) return;

    const original = useCallStore.getState().voiceId;
    useCallStore.setState({ voiceId: e.target.value, updatingVoiceId: true });
    updateAIAgent(agentInstanceId, {
      VoiceChat: {
        VoiceId: e.target.value,
      },
    })
      .catch((error: unknown) => {
        console.error('updateAIAgent error', error);
        return false;
      })
      .then((updated) => {
        useCallStore.setState({ voiceId: updated ? e.target.value : original, updatingVoiceId: false });
      });
  };

  return (
    <Form {...layout} colon={false} labelAlign='left' className='voice-call-settings-form'>
      {contextHolder}
      <Form.Item label='智能打断' help='根据声音和环境智能打断AI机器人'>
        <Switch checked={enableVoiceInterrupt} disabled={updatingVoiceInterrupt} onChange={onVoiceInterruptChange} />
      </Form.Item>
      <Form.Item label='选择音色' help='切换音色后，AI将在下一次回答中使用新的角色'>
        <Radio.Group name='voiceId' value={voiceId} disabled={updatingVoiceId} onChange={onVoiceChange}>
          <Space direction='vertical'>
            <Radio value='zhixiaobai'>智小白</Radio>
            <Radio value='zhixiaoxia'>智小夏</Radio>
            <Radio value='abin'>阿斌</Radio>
          </Space>
        </Radio.Group>
      </Form.Item>
    </Form>
  );
}

export default CallSettings;
