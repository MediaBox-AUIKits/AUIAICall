package com.aliyuncs.aui.controller;

import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.AIAgentStartRequestDto;
import com.aliyuncs.aui.dto.req.AiAgentStopRequestDto;
import com.aliyuncs.aui.dto.req.AiAgentUpdateRequestDto;
import com.aliyuncs.aui.dto.req.GenerateAIAgentCallRequestDto;
import com.aliyuncs.aui.dto.res.AiAgentStartResponse;
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
        if (aiAgentStartResponse != null) {
            Map<String, Object> map = new HashMap<>();
            map.put("ai_agent_instance_id", aiAgentStartResponse.getAiAgentInstanceId());
            map.put("rtc_auth_token", aiAgentStartResponse.getRtcAuthToken());
            map.put("ai_agent_user_id", aiAgentStartResponse.getAiAgentUserId());
            map.put("channel_id", aiAgentStartResponse.getChannelId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/stopAIAgentInstance")
    public Result stopAIAgentInstance(@RequestBody AiAgentStopRequestDto aiAgentStopRequestDto) {
        ValidatorUtils.validateEntity(aiAgentStopRequestDto);
        boolean result = imsService.stopAIAgentInstance(aiAgentStopRequestDto);
        return Result.ok().put("result", result);
    }

    @RequestMapping("/updateAIAgentInstance")
    public Result updateAIAgentInstance(@RequestBody AiAgentUpdateRequestDto aiAgentUpdateRequestDto) {
        ValidatorUtils.validateEntity(aiAgentUpdateRequestDto);
        boolean result = imsService.updateAIAgentInstance(aiAgentUpdateRequestDto);
        return Result.ok().put("result", result);
    }

    @RequestMapping("/generateAIAgentCall")
    public Result generateAIAgentCall(@RequestBody GenerateAIAgentCallRequestDto generateAIAgentCallRequestDto) {
        ValidatorUtils.validateEntity(generateAIAgentCallRequestDto);
        GenerateAIAgentCallResponse generateAIAgentCallResponse =  imsService.generateAIAgentCall(generateAIAgentCallRequestDto);
        if (generateAIAgentCallResponse == null) {
            return Result.error();
        }
        Map<String, Object> map = new HashMap<>(1);
        map.put("rtc_auth_token", generateAIAgentCallResponse.getRtcAuthToken());
        map.put("ai_agent_id", generateAIAgentCallResponse.getAiAgentId());
        map.put("ai_agent_instance_id", generateAIAgentCallResponse.getAiAgentInstanceId());
        map.put("ai_agent_user_id", generateAIAgentCallResponse.getAiAgentUserId());
        map.put("channel_id", generateAIAgentCallResponse.getChannelId());
        map.put("workflow_type", generateAIAgentCallResponse.getWorkflowType());
        Result result = Result.ok();
        result.putAll(map);
        return result;
    }
}
