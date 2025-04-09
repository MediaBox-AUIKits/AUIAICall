package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.GenerateMessageChatTokenRequestDto;
import com.aliyuncs.aui.dto.res.*;

/**
 * AiAgentService
 *
 * @author chunlei.zcl
 */
public interface AiAgentService {

    AiAgentStartResponse startAiAgent(String ChannelId, String userId, String rtcAuthToken, String templateConfig, String workflowType, String userData, String sessionId, String chatSyncConfig, String aiAgentId, String region);

    CommonResponse stopAiAgent(String aiAgentInstanceId);

    CommonResponse updateAiAgent(String aiAgentInstanceId, String config);

    GenerateAIAgentCallResponse generateAIAgentCall(String aiAgentId, String userId, Integer expire, String templateConfig, String workflowType, String region, String userData, String sessionId, String chatSyncConfig);

    AiAgentInstanceDescribeResponse describeAiAgentInstance(String aiAgentInstanceId);

    GenerateMessageChatTokenResponse generateMessageChatToken(String aiAgentId, String role, String userId, Integer expire, String region);
}
