package com.aliyuncs.aui.service;

/**
 * AiRobotService
 *
 * @author chunlei.zcl
 */
public interface AiRobotService {

    String startRobot(String ChannelId, String userId, String rtcAuthToken, String notifyConfig, String robotId);

    boolean stopRobot(String robotInstanceId);

    boolean updateRobot(String robotInstanceId, String config);
}
