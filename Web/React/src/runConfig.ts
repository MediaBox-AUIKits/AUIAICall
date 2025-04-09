import { AICallRunConfig } from '@/interface.ts';
// import { AICallTemplateConfig } from 'aliyun-auikit-aicall';

// 如果需要自定义 TemplateConfig，请参考以下写法
// const callTemplateConfig = new AICallTemplateConfig();
// callTemplateConfig.agentGreeting = 'Custom Greeting';

// 支持的配置项参考 src/interface.ts
const runConfig: AICallRunConfig = {
  appServer: '您的应用服务器地址',
  chatAgentId: '您的消息通话智能体id',
  // callTemplateConfig: callTemplateConfig,
};

export default runConfig;
