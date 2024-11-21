import { AICallAgentInfo, AICallAgentType } from 'aliyun-auikit-aicall';
import AUIAICallConfig from '../AUIAICallConfig';

import { APP_SERVER, getWorkflowType, JSONData, ServiceAuthError, TemplateConfig, WorkflowType } from './interface';

class StandardAppService {
  private appServer = APP_SERVER;

  private getInitTemplateConfig = (config: AUIAICallConfig): TemplateConfig => {
    const templateConfig: TemplateConfig = {};
    const configDict: JSONData = {
      EnableVoiceInterrupt: config.enableVoiceInterrupt,
      MaxIdleTime: config.agentMaxIdleTime,
    };
    if (config.agentVoiceId) {
      configDict.VoiceId = config.agentVoiceId;
    }
    if (config.agentType === AICallAgentType.AvatarAgent && config.agentAvatarId) {
      configDict.AvatarId = config.agentAvatarId;
    }
    if (config.enablePushToTalk) {
      configDict.EnablePushToTalk = config.enablePushToTalk;
    }

    templateConfig[getWorkflowType(config.agentType)] = configDict;

    return templateConfig;
  };

  setAppServer(appServer: string) {
    this.appServer = appServer;
  }

  /**
   * 启动智能体实例
   * @param userId 用户 id
   * @param token token
   * @param config 智能体实例配置
   * @returns {Promise<AICallAgentInfo>} 智能体实例信息
   * @note 调用之前需要先设置用户 id 和 token
   */
  generateAIAgent = async (userId: string, token: string, config: AUIAICallConfig): Promise<AICallAgentInfo> => {
    if (!userId || !token) {
      throw new Error('userId or token is empty');
    }

    const param: {
      user_id: string;
      workflow_type?: WorkflowType;
      ai_agent_id?: string;
      template_config?: string;
      expire?: number;
    } = {
      user_id: userId,
      expire: 24 * 60 * 60,
      template_config: JSON.stringify(this.getInitTemplateConfig(config)),
    };

    if (config.agentId) {
      param.ai_agent_id = config.agentId;
    } else {
      param.workflow_type = getWorkflowType(config.agentType);
    }

    return fetch(`${this.appServer}/api/v2/aiagent/generateAIAgentCall`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          throw new ServiceAuthError('token is invalid');
        } else if (res.status !== 200) {
          throw new Error(`response status is ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return {
            agentType: config.agentType,
            instanceId: data.ai_agent_instance_id,
            channelId: data.channel_id,
            userId: data.ai_agent_user_id,
            rtcToken: data.rtc_auth_token,
            reqId: data.request_id || '',
          };
        }
        throw new Error(data.message || 'request error');
      });
  };

  describeAIAgent = async (userId: string, token: string, instanceId: string): Promise<TemplateConfig> => {
    if (!userId || !instanceId) {
      throw new Error('userId or instanceId is empty');
    }

    const param: {
      user_id: string;
      ai_agent_instance_id: string;
    } = {
      user_id: userId,
      ai_agent_instance_id: instanceId,
    };

    return fetch(`${this.appServer}/api/v2/aiagent/describeAIAgentInstance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          throw new ServiceAuthError('token is invalid');
        } else if (res.status !== 200) {
          throw new Error(`response status is ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return JSON.parse(data.template_config);
        }
        throw new Error(data.message || 'request error');
      });
  };
}

export default new StandardAppService();
