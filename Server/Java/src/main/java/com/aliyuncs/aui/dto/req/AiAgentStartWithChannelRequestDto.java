package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class AiAgentStartWithChannelRequestDto {

    @NotBlank
    @JsonProperty("user_id")
    private String userId;

    @NotBlank
    @JsonProperty("ai_agent_id")
    private String aiAgentId;

    @NotBlank
    @JsonProperty("channel_id")
    private String channelId;

    @JsonProperty("template_config")
    private String templateConfig;

    @NotBlank
    @JsonProperty("workflow_type")
    private String workflowType;

    @JsonProperty("user_data")
    private String userData;

    @JsonProperty("session_id")
    private String sessionId;

    @JsonProperty("chat_sync_config")
    private String chatSyncConfig;

    @NotBlank
    @JsonProperty("region")
    private String region;
}
