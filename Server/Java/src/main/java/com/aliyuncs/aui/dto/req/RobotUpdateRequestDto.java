package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * RobotUpdateRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class RobotUpdateRequestDto {

    @NotBlank(message="机器人实例id不能为空")
    @JsonProperty("robot_instance_id")
    private String robotInstanceId;


    @NotBlank(message="配置信息不能为空")
    @JsonProperty("config")
    private String config;
}
