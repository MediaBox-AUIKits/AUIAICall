package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * RobotStopRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class RobotStopRequestDto {

    @ApiModelProperty(value = "机器人实例id")
    @NotBlank(message="机器人实例id不能为空")
    @JsonProperty("robot_instance_id")
    private String robotInstanceId;

}
