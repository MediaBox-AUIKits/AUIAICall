package com.aliyuncs.aui.controller;

import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.AIAgentStartRequestDto;
import com.aliyuncs.aui.dto.req.AiAgentStopRequestDto;
import com.aliyuncs.aui.dto.req.AiAgentUpdateRequestDto;
import com.aliyuncs.aui.dto.req.GenerateAIAgentCallRequestDto;
import com.aliyuncs.aui.dto.res.AiAgentStartResponse;
import com.aliyuncs.aui.dto.res.CommonResponse;
import com.aliyuncs.aui.dto.res.GenerateAIAgentCallResponse;
import com.aliyuncs.aui.service.ImsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

/**
 * Controller
 *
 * @author chunlei.zcl
 */
@RestController
@RequestMapping("/api/v2/aiagent")
@Slf4j
public class AIAgentController {

    @Resource
    private ImsService imsService;

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
            return Result.error(500, aiAgentStartResponse.getMessage()).put("request_id", aiAgentStartResponse.getRequestId());
        }

    }

    @RequestMapping("/stopAIAgentInstance")
    public Result stopAIAgentInstance(@RequestBody AiAgentStopRequestDto aiAgentStopRequestDto) {
        ValidatorUtils.validateEntity(aiAgentStopRequestDto);
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
            return Result.error(500, aiAgentStopResponse.getMessage()).put("request_id", aiAgentStopResponse.getRequestId());
        }
    }

    @RequestMapping("/updateAIAgentInstance")
    public Result updateAIAgentInstance(@RequestBody AiAgentUpdateRequestDto aiAgentUpdateRequestDto) {
        ValidatorUtils.validateEntity(aiAgentUpdateRequestDto);
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
            return Result.error(500, aiAgentUpdateResponse.getMessage()).put("request_id", aiAgentUpdateResponse.getRequestId());
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
            return Result.error(500, generateAIAgentCallResponse.getMessage()).put("request_id", generateAIAgentCallResponse.getRequestId());
        }
    }
}
