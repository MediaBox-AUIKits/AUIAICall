package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * AiRobotStartResponse
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiRobotStartResponse {

    @JsonProperty("robot_instance_id")
    private String robotInstanceId;

    @JsonProperty("rtc_auth_token")
    private String rtcAuthToken;

    @JsonProperty("robot_user_id")
    private String robotUserId;

    @JsonProperty("channel_id")
    private String channelId;

}
