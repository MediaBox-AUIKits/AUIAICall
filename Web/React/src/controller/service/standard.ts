import { AICallAgentError, AICallAgentInfo, AICallErrorCode } from 'aliyun-auikit-aicall';
import AUIAICallConfig from '../AUIAICallConfig';

import { APP_SERVER, getWorkflowType, TemplateConfig, WorkflowType } from './interface';

class StandardAppService {
  private appServer = APP_SERVER;

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
    if (!userId) {
      throw new AICallAgentError('userId is empty');
    }

    const param: {
      user_id: string;
      workflow_type?: WorkflowType;
      ai_agent_id?: string;
      template_config?: string;
      expire?: number;
      user_data?: string;
      region?: string;
    } = {
      user_id: userId,
      expire: 24 * 60 * 60,
      template_config: config.templateConfig.getJsonString(config.agentType),
    };

    if (config.agentId) {
      param.ai_agent_id = config.agentId;
    } else {
      param.workflow_type = getWorkflowType(config.agentType);
    }

    if (config.userData) {
      param.user_data = config.userData;
    }
    if (config.region) {
      param.region = config.region;
    }

    return fetch(`${this.appServer}/api/v2/aiagent/generateAIAgentCall`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token || '',
      },
      body: JSON.stringify(param),
    })
      .then(async (res) => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        let data: any = {};
        try {
          data = await res.json();
        } catch (e) {
          console.error(e);
        }
        if (data.error_code === 'Forbidden.SubscriptionRequired') {
          throw new AICallAgentError('Forbidden.SubscriptionRequired', AICallErrorCode.AgentSubscriptionRequired);
        } else if (data.error_code === 'AgentNotFound') {
          throw new AICallAgentError('AgentNotFound', AICallErrorCode.AgentNotFound);
        }

        if (res.status === 403) {
          const error = new AICallAgentError('token is invalid');
          error.name = 'ServiceAuthError';
          throw error;
        } else if (res.status !== 200) {
          throw new AICallAgentError(`response status is ${res.status}`);
        }

        return data;
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
        throw new AICallAgentError(data.message || 'request error');
      });
  };

  describeAIAgent = async (userId: string, token: string, instanceId: string): Promise<TemplateConfig> => {
    if (!userId || !instanceId) {
      throw new AICallAgentError('userId or instanceId is empty');
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
        Authorization: token || '',
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          const error = new AICallAgentError('token is invalid');
          error.name = 'ServiceAuthError';
          throw error;
        } else if (res.status !== 200) {
          throw new AICallAgentError(`describeAIAgentInstance error, response status: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return JSON.parse(data.template_config);
        }
        throw new AICallAgentError(`describeAIAgentInstance error, message: ${data.message || 'request error'}`);
      });
  };
}

export default new StandardAppService();
