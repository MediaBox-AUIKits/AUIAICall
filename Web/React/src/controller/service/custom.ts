import { AICallAgentError, AICallAgentInfo, AICallErrorCode } from 'aliyun-auikit-aicall';
import AUIAICallConfig from '../AUIAICallConfig';

import { APP_SERVER, getWorkflowType, JSONObject, TemplateConfig, WorkflowType } from './interface';

class AppServerService {
  private _userId?: string;
  private _token?: string;

  /**
   * 设置用户 id
   * @param userId 用户 id
   * @note 在调用 API 之前必须先完成设置用户 id
   */
  setUserId(userId: string) {
    this._userId = userId;
  }
  /**
   * 设置 token
   * @param token token
   * @note 在调用 API 之前必须先完成设置 token
   */
  setToken(token: string) {
    this._token = token;
  }

  /**
   * 启动智能体实例
   * @param userId 用户 id
   * @param token token
   * @param config 智能体实例配置
   * @returns {Promise<AICallAgentInfo>} 智能体实例信息
   * @note 调用之前需要先设置用户 id 和 token
   */
  startAIAgent = async (userId: string, token: string, config: AUIAICallConfig): Promise<AICallAgentInfo> => {
    if (userId) {
      this._userId = userId;
    }
    if (token) {
      this._token = token;
    }
    if (!this._userId || !this._token) {
      throw new AICallAgentError('userId or token is empty');
    }

    const param: {
      user_id: string;
      workflow_type: WorkflowType;
      template_config?: string;
      expire?: number;
      user_data?: string;
      region?: string;
    } = {
      user_id: this._userId,
      expire: 24 * 60 * 60,
      template_config: config.templateConfig.getJsonString(config.agentType),
      workflow_type: getWorkflowType(config.agentType),
    };

    if (config.userData) {
      param.user_data = config.userData;
    }
    if (config.region) {
      param.region = config.region;
    }

    return fetch(`${APP_SERVER}/api/v2/aiagent/startAIAgentInstance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this._token,
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

  describeAIAgent = async (instanceId: string, token: string, userId: string): Promise<JSONObject> => {
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

    return fetch(`${APP_SERVER}/api/v2/aiagent/describeAIAgentInstance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: token,
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          const error = new AICallAgentError('token is invalid');
          error.name = 'ServiceAuthError';
          throw error;
        } else if (res.status !== 200) {
          throw new AICallAgentError(`response status is ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return JSON.parse(data.template_config);
        }
        throw new AICallAgentError(data.message || 'request error');
      });
  };

  /**
   * 停止智能体实例
   * @param agentInstanceId 智能体实例 id
   * @returns {Promise<boolean>} 是否停止成功
   * @note 调用之前需要先设置用户 id 和 token
   */
  stopAIAgent = async (agentInstanceId: string): Promise<boolean> => {
    if (!this._userId || !this._token) {
      throw new AICallAgentError('userId or token is empty');
    }
    return fetch(`${APP_SERVER}/api/v2/aiagent/stopAIAgentInstance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this._token,
      },
      body: JSON.stringify({
        ai_agent_instance_id: agentInstanceId,
        user_id: this._userId,
      }),
    })
      .then((res) => {
        if (res.status !== 200) {
          throw new AICallAgentError(`response status is ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return !!data.result;
        }
        throw new AICallAgentError(data.message || 'request error');
      });
  };

  /**
   * 更新智能体实例
   * @param agentInstanceId 智能体实例 id
   * @param templateConfig {"xxx":"xx"}	AIAgent模版配置
   * @returns {Promise<boolean>} 是否更新成功
   * @note 调用之前需要先设置用户 id 和 token
   */
  updateAIAgent = async (agentInstanceId: string, templateConfig: TemplateConfig): Promise<boolean> => {
    if (!this._userId || !this._token) {
      throw new AICallAgentError('userId or token is empty');
    }
    return fetch(`${APP_SERVER}/api/v2/aiagent/updateAIAgentInstance`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this._token,
      },
      body: JSON.stringify({
        ai_agent_instance_id: agentInstanceId,
        template_config: JSON.stringify(templateConfig),
        user_id: this._userId,
      }),
    })
      .then((res) => {
        if (res.status !== 200) {
          throw new AICallAgentError(`response status is ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return !!data.result;
        }
        throw new AICallAgentError(data.message || 'request error');
      });
  };

  /**
   * 获取 rtc 鉴权 token
   * @param channeId 频道 id
   * @param userId 用户 id
   * @returns
   */
  getRtcAuthToken = async (channeId: string, userId: string): Promise<string> => {
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
        throw new AICallAgentError(res.message);
      });
  };
}

export default new AppServerService();
