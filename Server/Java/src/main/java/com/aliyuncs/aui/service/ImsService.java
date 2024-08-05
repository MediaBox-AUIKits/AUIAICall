package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.RobotStartRequestDto;
import com.aliyuncs.aui.dto.req.RobotStopRequestDto;
import com.aliyuncs.aui.dto.req.RobotUpdateRequestDto;
import com.aliyuncs.aui.dto.req.RtcAuthTokenRequestDto;
import com.aliyuncs.aui.dto.res.AiRobotStartResponse;
import com.aliyuncs.aui.dto.res.RtcAuthTokenResponse;

/**
 * IMS管理服务
 *
 * @author chunlei.zcl
 */
public interface ImsService {

    AiRobotStartResponse startRobot(RobotStartRequestDto robotStartRequestDto);

    boolean stopRobot(RobotStopRequestDto robotStopRequestDto);

    boolean updateRobot(RobotUpdateRequestDto robotUpdateRequestDto);

    RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto);
}

