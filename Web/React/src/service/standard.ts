import {
  AICallAgentError,
  AICallAgentInfo,
  AICallConfig,
  AICallErrorCode,
  AIChatAuthToken,
  JSONObject,
} from 'aliyun-auikit-aicall';

import { getWorkflowType, TemplateConfig, WorkflowType } from './interface';

class StandardAppService {
  private appServer = '';
  private serverAuth = '';

  setAppServer(appServer: string) {
    this.appServer = appServer;
  }

  setServerAuth(serverAuth: string) {
    this.serverAuth = serverAuth;
  }

  /**
   * 启动智能体实例 Start a AI agent instance
   * @param userId
   * @param token token
   * @param config 智能体实例配置 agent instance config
   * @returns {Promise<AICallAgentInfo>} 智能体实例信息 agent instance info
   * @note 调用之前需要先设置用户 id 和 token
   * @note id and token are required before calling this method
   */
  generateAIAgent = async (userId: string, token: string, config: AICallConfig): Promise<AICallAgentInfo> => {
    if (!userId) {
      throw new AICallAgentError('userId is empty');
    }

    const param: {
      user_id: string;
      workflow_type?: WorkflowType;
      ai_agent_id?: string;
      template_config?: string;
      agent_config?: string;
      expire?: number;
      user_data?: string;
      region?: string;
      session_id?: string;
      chat_sync_config?: string;
    } = {
      user_id: userId,
      expire: 24 * 60 * 60,
      template_config: JSON.stringify({}),
    };

    if (config.agentId) {
      param.ai_agent_id = config.agentId;
    } else {
      param.workflow_type = getWorkflowType(config.agentType);
    }
    if (config.templateConfig) {
      param.template_config = config.templateConfig.getJsonString(config.agentType);
    }
    if (config.agentConfig) {
      param.agent_config = JSON.stringify(config.agentConfig.toJSON());
    }

    if (config.userData) {
      param.user_data = config.userData;
    }
    if (config.region) {
      param.region = config.region;
    }

    if (config.chatSyncConfig) {
      param.session_id = config.chatSyncConfig.sessionId;
      param.chat_sync_config = config.chatSyncConfig.getConfigString();
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

  getRtcAuthToken = async (userId: string, channelId: string) => {
    const body = {
      user_id: userId,
      channel_id: channelId,
    };
    return fetch(`${this.appServer}/api/v2/aiagent/getRtcAuthToken`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.serverAuth || '',
      },
      body: JSON.stringify(body),
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
          return data.rtc_auth_token;
        }
        throw new AICallAgentError(`request error, message: ${data.message || 'request error'}`);
      });
  };

  describeAIAgentInstance = async (
    userId: string,
    token: string,
    region: string,
    instanceId: string
  ): Promise<TemplateConfig> => {
    if (!userId || !instanceId) {
      throw new AICallAgentError('userId or instanceId is empty');
    }

    const param: {
      user_id: string;
      ai_agent_instance_id: string;
      region: string;
    } = {
      user_id: userId,
      ai_agent_instance_id: instanceId,
      region,
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

  describeAIAgent = async (userId: string, region: string, agentId: string): Promise<JSONObject> => {
    if (!userId || !agentId) {
      throw new AICallAgentError('userId or agentId is empty');
    }

    const param: {
      user_id: string;
      ai_agent_id: string;
      region: string;
    } = {
      user_id: userId,
      ai_agent_id: agentId,
      region,
    };

    return fetch(`${this.appServer}/api/v2/aiagent/describeAIAgent`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.serverAuth || '',
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          const error = new AICallAgentError('token is invalid');
          error.name = 'ServiceAuthError';
          throw error;
        } else if (res.status !== 200) {
          throw new AICallAgentError(`describeAIAgent error, response status: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return JSON.parse(data.ai_agent);
        }
        throw new AICallAgentError(`describeAIAgent error, message: ${data.message || 'request error'}`);
      });
  };

  generateMessageChatToken = async (
    userId: string,
    token: string,
    agentId?: string,
    region?: string
  ): Promise<AIChatAuthToken> => {
    if (!userId) {
      throw new AICallAgentError('userId or instanceId is empty');
    }

    const param: {
      user_id: string;
      ai_agent_id?: string;
      region?: string;
    } = {
      user_id: userId,
      ai_agent_id: agentId,
    };

    if (region) {
      param.region = region;
    }

    return fetch(`${this.appServer}/api/v2/aiagent/generateMessageChatToken`, {
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
          throw new AICallAgentError(`generateMessageChatToken error, response status: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return AIChatAuthToken.fromData(data);
        }
        throw new AICallAgentError(`generateMessageChatToken error, message: ${data.message || 'request error'}`);
      });
  };

  startAIAgentOutboundCall = async (userId: string, phoneNumber: string, config: AICallConfig) => {
    const body: {
      ai_agent_id?: string;
      region?: string;
      called_number: string;
      user_id: string;
      config?: string;
      user_data?: string;
    } = {
      ai_agent_id: config.agentId,
      region: config.region,
      called_number: phoneNumber,
      user_id: userId,
    };

    if (config.agentConfig) {
      body.config = JSON.stringify(config.agentConfig.toJSON());
    }
    if (config.userData) {
      body.user_data = config.userData;
    }

    return fetch(`${this.appServer}/api/v2/aiagent/startAIAgentOutboundCall`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.serverAuth || '',
      },
      body: JSON.stringify(body),
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
          return {
            instanceId: data.instance_id,
            reqId: data.request_id || '',
          };
        }
        const error = new AICallAgentError(
          `request error, message: ${data.message || 'request error'}`,
          data.error_code
        );
        // @ts-expect-error reqId
        error.reqId = data.request_id || '';
        throw error;
      });
  };

  getOssConfig = async (userId: string): Promise<JSONObject> => {
    if (!userId) {
      throw new AICallAgentError('userId is empty');
    }

    const param: {
      user_id: string;
    } = {
      user_id: userId,
    };

    return fetch(`${this.appServer}/api/v2/aiagent/getOssConfig`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.serverAuth || '',
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          const error = new AICallAgentError('token is invalid');
          error.name = 'ServiceAuthError';
          throw error;
        } else if (res.status !== 200) {
          throw new AICallAgentError(`getOssConfig error, response status: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return data;
        }
        throw new AICallAgentError(`getOssConfig error, message: ${data.message || 'request error'}`);
      });
  };

  setAIAgentVoiceprint = async (
    userId: string,
    region: string,
    voiceprintId: string,
    input: string
  ): Promise<JSONObject> => {
    if (!userId || !voiceprintId || !input) {
      throw new AICallAgentError('userId or voiceprintId or input is empty');
    }

    const param: {
      user_id: string;
      region: string;
      voiceprint_id: string;
      input: string;
    } = {
      user_id: userId,
      region,
      voiceprint_id: voiceprintId,
      input,
    };

    return fetch(`${this.appServer}/api/v2/aiagent/setAIAgentVoiceprint`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.serverAuth || '',
      },
      body: JSON.stringify(param),
    })
      .then((res) => {
        if (res.status === 403) {
          const error = new AICallAgentError('token is invalid');
          error.name = 'ServiceAuthError';
          throw error;
        } else if (res.status !== 200) {
          throw new AICallAgentError(`setAIAgentVoiceprint error, response status: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        if (data.code === 200) {
          return data;
        }
        if (data.error_code === 'InvalidAudioDuration') {
          const error = new AICallAgentError('InvalidAudioDuration');
          error.name = 'InvalidAudioDuration';
          throw error;
        }
        throw new AICallAgentError(`setAIAgentVoiceprint error, message: ${data.message || 'request error'}`);
      });
  };
}

export default new StandardAppService();
