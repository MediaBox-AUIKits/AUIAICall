import { AICallRunConfig } from '@/interface.ts';
// import { AICallAgentConfig } from 'aliyun-auikit-aicall';

// 如果需要自定义 AgentConfig，请参考以下写法
// when you need to customize AgentConfig, please refer to the following code

// const callAgentConfig = new AICallAgentConfig();
// callAgentConfig.agentGreeting = 'Custom Greeting';

const runConfig: AICallRunConfig = {
  region: 'cn-shanghai',
  // 应用服务器地址，格式示例 https://xxxx.domain.com
  // Your Application Server Address
  appServer: 'AppServer',

  // 您的语音通话智能体id
  // Your Voice Agent Id
  voiceAgentId: 'VoiceAgentId',
  // 您的数字人智能体id
  // Your Avatar Agent Id
  avatarAgentId: 'AvatarAgentId',
  // 您的视觉智能体id
  // Your Vision Agent Id
  visionAgentId: 'VisionAgentId',
  // 您的视频通话智能体id
  // Your Video Agent Id
  videoAgentId: 'VideoAgentId',

  // 您的消息通话智能体id
  // Your Chat Agent Id
  chatAgentId: 'ChatAgentId',

  // callAgentConfig: callAgentConfig,
};

export default runConfig;
