package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * GenerateAIAgentCallResponse
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenerateAIAgentCallResponse {

    @JsonProperty("ai_agent_id")
    private String aiAgentId;

    @JsonProperty("workflow_type")
    private String WorkflowType;

    @JsonProperty("ai_agent_user_id")
    private String aiAgentUserId;

    @JsonProperty("ai_agent_instance_id")
    private String aiAgentInstanceId;

    @JsonProperty("channel_id")
    private String channelId;

    @JsonProperty("rtc_auth_token")
    private String rtcAuthToken;

    @JsonProperty("result")
    private boolean result;

    @JsonProperty("message")
    private String message;

    @JsonProperty("request_id")
    private String requestId;

    @JsonProperty("error_code")
    private String errorCode;

    @JsonProperty("code")
    private int code;

}
