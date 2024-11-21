package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * AiAgentStartResponse
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiAgentStartResponse {

    @JsonProperty("ai_agent_instance_id")
    private String aiAgentInstanceId;

    @JsonProperty("rtc_auth_token")
    private String rtcAuthToken;

    @JsonProperty("ai_agent_user_id")
    private String aiAgentUserId;

    @JsonProperty("channel_id")
    private String channelId;

    @JsonProperty("result")
    private boolean result;

    @JsonProperty("code")
    private int code;

    @JsonProperty("error_code")
    private String errorCode;

    @JsonProperty("message")
    private String message;

    @JsonProperty("request_id")
    private String requestId;

}
