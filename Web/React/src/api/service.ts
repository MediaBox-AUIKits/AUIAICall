import { AICallAgentInfo } from './type';

const APP_SERVER = "你的AppServer域名";

type OneLevelJSONData = {
  [key: string]: string | number | boolean;
};

type TemplateConfig = {
  VoiceChat?: OneLevelJSONData;
  AvatarChat3D?: OneLevelJSONData;
  MessageChat?: OneLevelJSONData;
};

enum WorkflowType {
  VoiceChat = 'VoiceChat',
  AvatarChat3D = 'AvatarChat3D',
}

/**
 * 启动智能体实例
 * @param userId 用户 id，需要按需要生成，用于处理业务相关逻辑
 * @param templateConfig {"xxx":"xx"}	AIAgent模版配置
 * @returns
 */
export const startAIAgent = async (userId: string, templateConfig?: TemplateConfig): Promise<AICallAgentInfo> => {
  const param: {
    user_id: string;
    workflow_type: WorkflowType;
    template_config?: string;
    expire?: number;
  } = {
    user_id: userId,
    workflow_type: WorkflowType.VoiceChat,
    expire: 86400,
  };
  if (templateConfig) {
    param.template_config = JSON.stringify(templateConfig);
  }

  return fetch(`${APP_SERVER}/api/v1/aiagent/startAIAgentInstance`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(param),
  })
    .then((res) => res.json())
    .then((res) => {
      if (res.code === 200) {
        return res;
      }
      throw new Error(res.message);
    });
};

/**
 * 停止智能体实例
 * @param agentInstanceId 智能体实例 id
 * @returns
 */
export const stopAIAgent = async (agentInstanceId: string): Promise<boolean> => {
  return fetch(`${APP_SERVER}/api/v1/aiagent/stopAIAgentInstance`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ai_agent_instance_id: agentInstanceId,
    }),
  })
    .then((res) => res.json())
    .then((res) => {
      if (res.code === 200) {
        return !!res.result;
      }
      throw new Error(res.message);
    });
};

/**
 * 更新智能体实例
 * @param agentInstanceId 智能体实例 id
 * @param templateConfig {"xxx":"xx"}	AIAgent模版配置
 * @returns
 */
export const updateAIAgent = async (agentInstanceId: string, templateConfig: TemplateConfig): Promise<boolean> => {
  return fetch(`${APP_SERVER}/api/v1/aiagent/updateAIAgentInstance`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ai_agent_instance_id: agentInstanceId,
      template_config: JSON.stringify(templateConfig),
    }),
  })
    .then((res) => res.json())
    .then((res) => {
      if (res.code === 200) {
        return !!res.result;
      }
      throw new Error(res.message);
    });
};

/**
 * 获取 rtc 鉴权 token
 * @param channeId 频道 id
 * @param userId 用户 id
 * @returns
 */
export const getRtcAuthToken = async (channeId: string, userId: string): Promise<string> => {
  return fetch(`${APP_SERVER}/api/v1/aiagent/getRtcAuthToken`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      channel_id: channeId,
      user_id: userId,
    }),
  })
    .then((res) => res.json())
    .then((res) => {
      if (res.code === 200) {
        return res.rtc_auth_token;
      }
      throw new Error(res.message);
    });
};
