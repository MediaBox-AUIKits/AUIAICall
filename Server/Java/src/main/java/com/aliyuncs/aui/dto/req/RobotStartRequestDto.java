package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * RobotStartRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class RobotStartRequestDto {

    @JsonProperty("channel_id")
    private String channelId;

    @NotBlank
    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("config")
    private String config;

    @JsonProperty("robot_id")
    private String robotId;
}
