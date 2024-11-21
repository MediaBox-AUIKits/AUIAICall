package com.aliyuncs.aui.dto.res;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AiAgentInstanceDescribeResponse {

    @JsonProperty("code")
    private int code;

    @JsonProperty("error_code")
    private String errorCode;

    @JsonProperty("message")
    private String message;

    @JsonProperty("request_id")
    private String requestId;

    @JsonProperty("call_log_url")
    private String callLogUrl;

    @JsonProperty("runtime_config")
    private String runtimeConfig;

    @JsonProperty("status")
    private String status;

    @JsonProperty("template_config")
    private String templateConfig;

    @JsonProperty("user_data")
    private String userData;
}
