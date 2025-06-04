package com.aliyuncs.aui.controller;

import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.service.ImsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v2/aiagent")
@Slf4j
public class AIAgentControllerV2 {

    @Resource
    private ImsService imsService;

    @RequestMapping("generateMessageChatToken")
    public Result generateMessageChatToken(@RequestBody GenerateMessageChatTokenRequestDto generateMessageChatTokenRequestDto) {
        ValidatorUtils.validateEntity(generateMessageChatTokenRequestDto);
        GenerateMessageChatTokenResponse response = imsService.generateMessageChatToken(generateMessageChatTokenRequestDto);
        if(response == null) {
            return Result.error();
        }
        if (200 == response.getCode()) {
            Map<String, Object> map = new HashMap<>(1);
            map.put("app_id", response.getAppId());
            map.put("token", response.getToken());
            map.put("user_id", response.getUserId());
            map.put("nonce", response.getNonce());
            map.put("role", response.getRole());
            map.put("timestamp", response.getTimestamp());
            map.put("app_sign", response.getAppSign());
            map.put("request_id", response.getRequestId());
            map.put("message", response.getMessage());
            return Result.ok(map);
        } else {
            return getErrorResult(response.getErrorCode(), response.getRequestId(), response.getCode(), response.getMessage());
        }
    }

    private Result getErrorResult(String errCode, String requestId, int code, String message) {
        Result result = Result.error(code, message);
        Map<String, Object> map = new HashMap<>();
        map.put("error_code", errCode);
        map.put("request_id", requestId);
        result.putAll(map);
        return result;
    }


    @RequestMapping("/getRtcAuthToken")
    public Result getRtcAuthToken(@RequestBody RtcAuthTokenRequestDto rtcAuthTokenRequestDto) {
        ValidatorUtils.validateEntity(rtcAuthTokenRequestDto);
        RtcAuthTokenResponse rtcAuthTokenResponse =  imsService.getRtcAuthToken(rtcAuthTokenRequestDto);

        Map<String, Object> map = new HashMap<>(1);
        map.put("rtc_auth_token", rtcAuthTokenResponse.getAuthToken());
        map.put("timestamp", rtcAuthTokenResponse.getTimestamp());
        map.put("channel_id", rtcAuthTokenRequestDto.getChannelId());
        Result result = Result.ok();
        result.putAll(map);
        return result;
    }

    @RequestMapping("/describeAIAgentInstance")
    public Result describeAIAgentInstance(@RequestBody AiAgentInstanceDescribeRequestDto aiAgentDescribeRequestDto) {
        ValidatorUtils.validateEntity(aiAgentDescribeRequestDto);
        AiAgentInstanceDescribeResponse response = imsService.describeAiAgentInstance(aiAgentDescribeRequestDto);
        if (response == null) {
            return Result.error();
        }
        if(200 == response.getCode()) {
            Map<String, Object> map = new HashMap<>(1);
            map.put("code", response.getCode());
            map.put("message", response.getMessage());
            map.put("request_id", response.getRequestId());
            map.put("call_log_url", response.getCallLogUrl());
            map.put("runtime_config", response.getRuntimeConfig());
            map.put("status", response.getStatus());
            map.put("template_config", response.getTemplateConfig());
            map.put("user_data", response.getUserData());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        } else {
            return getErrorResult(response.getErrorCode(), response.getRequestId(), response.getCode(), response.getMessage());
        }
    }
}

