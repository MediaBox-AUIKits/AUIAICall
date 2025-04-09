package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;

/**
 * IMS管理服务
 *
 * @author chunlei.zcl
 */
public interface ImsService {

    AiAgentStartResponse startAIAgentInstance(AIAgentStartRequestDto aiAgentStartRequestDto);

    AiAgentStartResponse startAIAgentInstanceWithChannel(AiAgentStartWithChannelRequestDto aiAgentStartWithChannelRequestDto);

    CommonResponse stopAIAgentInstance(AiAgentStopRequestDto aiAgentStopRequestDto);

    CommonResponse updateAIAgentInstance(AiAgentUpdateRequestDto robotUpdateRequestDto);

    RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto);

    GenerateAIAgentCallResponse generateAIAgentCall(GenerateAIAgentCallRequestDto generateAIAgentCallRequestDto);

    AiAgentInstanceDescribeResponse describeAiAgentInstance(String aiAgentInstanceId);

    GenerateMessageChatTokenResponse generateMessageChatToken(GenerateMessageChatTokenRequestDto requestDto);
}

