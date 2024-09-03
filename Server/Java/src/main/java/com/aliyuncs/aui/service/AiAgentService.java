package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.res.GenerateAIAgentCallResponse;

/**
 * AiAgentService
 *
 * @author chunlei.zcl
 */
public interface AiAgentService {

    String startAiAgent(String ChannelId, String userId, String rtcAuthToken, String templateConfig, String workflowType);

    boolean stopAiAgent(String aiAgentInstanceId);

    boolean updateAiAgent(String aiAgentInstanceId, String config);

    GenerateAIAgentCallResponse generateAIAgentCall(String aiAgentId, String userId, Integer expire, String templateConfig, String workflowType);
}
