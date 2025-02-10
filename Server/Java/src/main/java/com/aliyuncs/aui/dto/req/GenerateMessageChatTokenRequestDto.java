package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class GenerateMessageChatTokenRequestDto {
    @JsonProperty("ai_agent_id")
    @NotBlank
    private String aiAgentId;

    @JsonProperty("role")
    private String role;

    @JsonProperty("user_id")
    @NotBlank
    private String userId;

    @JsonProperty("expire")
    private Integer expire;

    @JsonProperty("region")
    private String region;

}
