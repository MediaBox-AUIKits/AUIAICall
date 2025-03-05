package com.aliyuncs.aui.controller;

import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.service.ImsService;
import com.aliyuncs.aui.service.UploadService;
import com.aliyuncs.aui.service.VoiceService;
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
public class AIAgentController {

    @Resource
    private ImsService imsService;

    @Resource
    private VoiceService voiceService;

    @Resource
    private UploadService uploadService;

    @RequestMapping("/startAIAgentInstance")
    public Result startAIAgentInstance(@RequestBody AIAgentStartRequestDto aiAgentStartRequestDto) {
        ValidatorUtils.validateEntity(aiAgentStartRequestDto);
        AiAgentStartResponse aiAgentStartResponse = imsService.startAIAgentInstance(aiAgentStartRequestDto);
        if (aiAgentStartResponse == null) {
            return Result.error();
        }
        if (aiAgentStartResponse.isResult()) {
            Map<String, Object> map = new HashMap<>();
            map.put("ai_agent_instance_id", aiAgentStartResponse.getAiAgentInstanceId());
            map.put("rtc_auth_token", aiAgentStartResponse.getRtcAuthToken());
            map.put("ai_agent_user_id", aiAgentStartResponse.getAiAgentUserId());
            map.put("channel_id", aiAgentStartResponse.getChannelId());
            map.put("request_id", aiAgentStartResponse.getRequestId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        } else {
            return getErrorResult(aiAgentStartResponse.getErrorCode(), aiAgentStartResponse.getRequestId(), aiAgentStartResponse.getCode(), aiAgentStartResponse.getMessage());
        }
    }

    @RequestMapping("/stopAIAgentInstance")
    public Result stopAIAgentInstance(@RequestBody AiAgentStopRequestDto aiAgentStopRequestDtoV2) {
        ValidatorUtils.validateEntity(aiAgentStopRequestDtoV2);
        AiAgentStopRequestDto aiAgentStopRequestDto = new AiAgentStopRequestDto();
        aiAgentStopRequestDto.setAiAgentInstanceId(aiAgentStopRequestDtoV2.getAiAgentInstanceId());
        CommonResponse aiAgentStopResponse = imsService.stopAIAgentInstance(aiAgentStopRequestDto);
        if(aiAgentStopResponse == null) {
            return Result.error();
        }
        if(aiAgentStopResponse.isResult()) {
            Map<String, Object> map = new HashMap<>();
            map.put("result", aiAgentStopResponse.isResult());
            map.put("request_id", aiAgentStopResponse.getRequestId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        } else {
            return getErrorResult(aiAgentStopResponse.getErrorCode(), aiAgentStopResponse.getRequestId(), aiAgentStopResponse.getCode(), aiAgentStopResponse.getMessage());
        }
    }

    @RequestMapping("/updateAIAgentInstance")
    public Result updateAIAgentInstance(@RequestBody AiAgentUpdateRequestDto aiAgentUpdateRequestDtoV2) {
        ValidatorUtils.validateEntity(aiAgentUpdateRequestDtoV2);

        AiAgentUpdateRequestDto aiAgentUpdateRequestDto = new AiAgentUpdateRequestDto();
        aiAgentUpdateRequestDto.setAiAgentInstanceId(aiAgentUpdateRequestDtoV2.getAiAgentInstanceId());
        aiAgentUpdateRequestDto.setTemplateConfig(aiAgentUpdateRequestDtoV2.getTemplateConfig());


        CommonResponse aiAgentUpdateResponse = imsService.updateAIAgentInstance(aiAgentUpdateRequestDto);
        if(aiAgentUpdateResponse == null) {
            return Result.error();
        }
        if(aiAgentUpdateResponse.isResult()) {
            Map<String, Object> map = new HashMap<>();
            map.put("result", aiAgentUpdateResponse.isResult());
            map.put("request_id", aiAgentUpdateResponse.getRequestId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        } else {
            return getErrorResult(aiAgentUpdateResponse.getErrorCode(), aiAgentUpdateResponse.getRequestId(), aiAgentUpdateResponse.getCode(), aiAgentUpdateResponse.getMessage());
        }
    }

    @RequestMapping("/generateAIAgentCall")
    public Result generateAIAgentCall(@RequestBody GenerateAIAgentCallRequestDto generateAIAgentCallRequestDto) {
        ValidatorUtils.validateEntity(generateAIAgentCallRequestDto);
        GenerateAIAgentCallResponse generateAIAgentCallResponse =  imsService.generateAIAgentCall(generateAIAgentCallRequestDto);
        if (generateAIAgentCallResponse == null) {
            return Result.error();
        }
        if(generateAIAgentCallResponse.isResult()) {
            Map<String, Object> map = new HashMap<>(1);
            map.put("rtc_auth_token", generateAIAgentCallResponse.getRtcAuthToken());
            map.put("ai_agent_id", generateAIAgentCallResponse.getAiAgentId());
            map.put("ai_agent_instance_id", generateAIAgentCallResponse.getAiAgentInstanceId());
            map.put("ai_agent_user_id", generateAIAgentCallResponse.getAiAgentUserId());
            map.put("channel_id", generateAIAgentCallResponse.getChannelId());
            map.put("workflow_type", generateAIAgentCallResponse.getWorkflowType());
            map.put("request_id", generateAIAgentCallResponse.getRequestId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        } else {
            return getErrorResult(generateAIAgentCallResponse.getErrorCode(), generateAIAgentCallResponse.getRequestId(), generateAIAgentCallResponse.getCode(), generateAIAgentCallResponse.getMessage());
        }
    }

    @RequestMapping("/describeAIAgentInstance")
    public Result describeAIAgentInstance(@RequestBody AiAgentInstanceDescribeRequestDto aiAgentDescribeRequestDto) {
        ValidatorUtils.validateEntity(aiAgentDescribeRequestDto);
        AiAgentInstanceDescribeResponse response = imsService.describeAiAgentInstance(aiAgentDescribeRequestDto.getAiAgentInstanceId());
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

    private Result getErrorResult(String errCode, String requestId, int code, String message) {
        Result result = Result.error(code, message);
        Map<String, Object> map = new HashMap<>();
        map.put("error_code", errCode);
        map.put("request_id", requestId);
        result.putAll(map);
        return result;
    }

    @RequestMapping("/cosyVoiceClone")
    public Result CosyVoiceClone(@RequestBody CosyVoiceCloneRequestDto cosyVoiceCloneRequestDto) {
        ValidatorUtils.validateEntity(cosyVoiceCloneRequestDto);
        CosyVoiceCloneResponse response = voiceService.cosyVoiceClone(cosyVoiceCloneRequestDto);
        if (response == null) {
            return Result.error();
        }
        if(200 == response.getCode()){
            Map<String, Object> map = new HashMap<>(1);
            map.put("voice_id", response.getVoiceId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        } else {
            return getErrorResult(response.getErrorCode(), response.getRequestId(), response.getCode(), response.getMessage());
        }
    }

    /**
     * 获取上传 OSS 所需的 STS 数据
     */
    @RequestMapping("/getOssConfig")
    public Result getOssConfig(@RequestBody UploadConfigGetRequestDto uploadConfigGetRequestDto) {

        ValidatorUtils.validateEntity(uploadConfigGetRequestDto);

        UploadSTSInfoResponse response = uploadService.get(uploadConfigGetRequestDto);
        if(response == null) {
            return Result.error();
        }
        if (200 == response.getCode()) {
            Map<String, Object> map = new HashMap<>(1);
            map.put("access_key_id", response.getAccessKeyId());
            map.put("access_key_secret", response.getAccessKeySecret());
            map.put("sts_token", response.getStsToken());
            map.put("bucket", response.getBucket());
            map.put("base_path", response.getBasePath());
            map.put("region", response.getRegion());
            map.put("expiration", response.getExpiration());
            return Result.ok(map);
        } else {
            return getErrorResult(response.getErrorCode(), response.getRequestId(), response.getCode(), response.getMessage());
        }
    }

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
}

