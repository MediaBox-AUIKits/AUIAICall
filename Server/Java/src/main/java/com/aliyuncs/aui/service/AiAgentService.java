package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.GenerateMessageChatTokenRequestDto;
import com.aliyuncs.aui.dto.res.*;

/**
 * AiAgentService
 *
 * @author chunlei.zcl
 */
public interface AiAgentService {

    GenerateMessageChatTokenResponse generateMessageChatToken(String aiAgentId, String role, String userId, Integer expire, String region);

    AiAgentInstanceDescribeResponse describeAiAgentInstance(String aiAgentInstanceId, String region);
}
