package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * RtcAuthTokenRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class RtcAuthTokenRequestDto {

    @JsonProperty("channel_id")
    private String channelId;

    @JsonProperty("user_id")
    private String userId;

}
