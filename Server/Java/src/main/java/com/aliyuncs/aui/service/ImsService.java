package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;

/**
 * IMS管理服务
 *
 * @author chunlei.zcl
 */
public interface ImsService {
    RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto);

    GenerateMessageChatTokenResponse generateMessageChatToken(GenerateMessageChatTokenRequestDto requestDto);

    AiAgentInstanceDescribeResponse describeAiAgentInstance(AiAgentInstanceDescribeRequestDto aiAgentDescribeRequestDto);
}

