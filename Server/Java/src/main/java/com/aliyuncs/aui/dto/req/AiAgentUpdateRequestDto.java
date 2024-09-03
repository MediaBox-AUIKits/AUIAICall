package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * AiAgentUpdateRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class AiAgentUpdateRequestDto {

    @NotBlank(message="机器人实例id不能为空")
    @JsonProperty("ai_agent_instance_id")
    private String aiAgentInstanceId;


    @NotBlank(message="配置信息不能为空")
    @JsonProperty("template_config")
    private String templateConfig;
}
