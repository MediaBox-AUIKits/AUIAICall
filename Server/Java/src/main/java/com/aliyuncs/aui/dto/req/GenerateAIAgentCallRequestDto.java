package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * GenerateAIAgentCallRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class GenerateAIAgentCallRequestDto {

    @JsonProperty("ai_agent_id")
    private String aiAgentId;

    @JsonProperty("expire")
    private Integer expire;

    @JsonProperty("user_id")
    private String userId;

    @NotBlank(message="配置信息不能为空")
    @JsonProperty("template_config")
    private String templateConfig;

    @JsonProperty("workflow_type")
    private String workflowType;

    @JsonProperty("region")
    private String region;

    @JsonProperty("user_data")
    private String userData;

}
