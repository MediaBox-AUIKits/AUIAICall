package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * AiAgentStopRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class AiAgentStopRequestDto {

    @NotBlank(message="机器人实例id不能为空")
    @JsonProperty("ai_agent_instance_id")
    private String aiAgentInstanceId;

}
