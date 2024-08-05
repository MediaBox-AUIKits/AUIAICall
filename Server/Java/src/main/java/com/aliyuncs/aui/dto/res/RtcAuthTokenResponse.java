package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * RtcAuthTokenResponse
 *
 * @author chunlei.zcl
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RtcAuthTokenResponse {

    @JsonProperty("auth_token")
    private String authToken;

    @JsonProperty("timestamp")
    private Long timestamp;
}
