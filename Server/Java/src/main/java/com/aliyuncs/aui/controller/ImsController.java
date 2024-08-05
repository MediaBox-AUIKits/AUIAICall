package com.aliyuncs.aui.controller;

import com.aliyuncs.aui.common.utils.Result;
import com.aliyuncs.aui.common.utils.ValidatorUtils;
import com.aliyuncs.aui.dto.req.RobotStartRequestDto;
import com.aliyuncs.aui.dto.req.RobotStopRequestDto;
import com.aliyuncs.aui.dto.req.RobotUpdateRequestDto;
import com.aliyuncs.aui.dto.req.RtcAuthTokenRequestDto;
import com.aliyuncs.aui.dto.res.AiRobotStartResponse;
import com.aliyuncs.aui.dto.res.RtcAuthTokenResponse;
import com.aliyuncs.aui.service.ImsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

/**
 * 直播间管理的Controller
 *
 * @author chunlei.zcl
 */
@RestController
@RequestMapping("/api/v1/imsRobot")
@Slf4j
public class ImsController {

    @Resource
    private ImsService imsService;

    @RequestMapping("/startRobot")
    public Result startRobot(@RequestBody RobotStartRequestDto robotStartRequestDto) {
        ValidatorUtils.validateEntity(robotStartRequestDto);

        AiRobotStartResponse aiRobotStartResponse = imsService.startRobot(robotStartRequestDto);
        if (aiRobotStartResponse != null) {
            Map<String, Object> map = new HashMap<>();
            map.put("robot_instance_id", aiRobotStartResponse.getRobotInstanceId());
            map.put("rtc_auth_token", aiRobotStartResponse.getRtcAuthToken());
            map.put("robot_user_id", aiRobotStartResponse.getRobotUserId());
            map.put("channel_id", aiRobotStartResponse.getChannelId());
            Result result = Result.ok();
            result.putAll(map);
            return result;
        }
        return Result.error();
    }

    @RequestMapping("/stopRobot")
    public Result stopRobot(@RequestBody RobotStopRequestDto robotStopRequestDto) {
        ValidatorUtils.validateEntity(robotStopRequestDto);

        boolean result = imsService.stopRobot(robotStopRequestDto);

        return Result.ok().put("result", result);
    }

    @RequestMapping("/updateRobot")
    public Result updateRobot(@RequestBody RobotUpdateRequestDto robotUpdateRequestDto) {
        ValidatorUtils.validateEntity(robotUpdateRequestDto);

        boolean result = imsService.updateRobot(robotUpdateRequestDto);

        return Result.ok().put("result", result);
    }

    @RequestMapping("/getRtcAuthToken")
    public Result getRtcAuthToken(@RequestBody RtcAuthTokenRequestDto rtcAuthTokenRequestDto) {

        ValidatorUtils.validateEntity(rtcAuthTokenRequestDto);
        RtcAuthTokenResponse rtcAuthTokenResponse =  imsService.getRtcAuthToken(rtcAuthTokenRequestDto);

        Map<String, Object> map = new HashMap<>(1);
        map.put("rtc_auth_token", rtcAuthTokenResponse.getAuthToken());
        map.put("channel_id", rtcAuthTokenRequestDto.getChannelId());
        Result result = Result.ok();
        result.putAll(map);
        return result;
    }
}
