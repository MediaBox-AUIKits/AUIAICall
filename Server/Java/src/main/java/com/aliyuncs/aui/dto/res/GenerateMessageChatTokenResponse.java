package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GenerateMessageChatTokenResponse {
    @JsonProperty("code")
    private int code;

    @JsonProperty("message")
    private String message;

    @JsonProperty("error_code")
    private String errorCode;

    @JsonProperty("request_id")
    private String requestId;

    @JsonProperty("app_id")
    private String appId;

    @JsonProperty("token")
    private String token;

    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("nonce")
    private String nonce;

    @JsonProperty("role")
    private String role;

    @JsonProperty("timestamp")
    private long timestamp;

    @JsonProperty("app_sign")
    private String appSign;
}
