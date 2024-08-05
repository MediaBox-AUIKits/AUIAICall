package com.aliyuncs.aui.service.impl;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.aui.dto.req.RobotStartRequestDto;
import com.aliyuncs.aui.dto.req.RobotStopRequestDto;
import com.aliyuncs.aui.dto.req.RobotUpdateRequestDto;
import com.aliyuncs.aui.dto.req.RtcAuthTokenRequestDto;
import com.aliyuncs.aui.dto.res.AiRobotStartResponse;
import com.aliyuncs.aui.dto.res.RtcAuthTokenResponse;
import com.aliyuncs.aui.service.AiRobotService;
import com.aliyuncs.aui.service.ImsService;
import com.google.common.base.Strings;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.time.DateUtils;
import org.apache.shiro.codec.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.UUID;

/**
 * ImsServiceImpl
 *
 * @author chunlei.zcl
 */
@Slf4j
@Service
public class ImsServiceImpl implements ImsService {

    @Value("${biz.live_mic.app_id}")
    private String liveMicAppId;
    @Value("${biz.live_mic.app_key}")
    private String liveMicAppKey;

    @Resource
    private AiRobotService aiRobotService;

    @Override
    public AiRobotStartResponse startRobot(RobotStartRequestDto robotStartRequestDto) {
        String channelId = robotStartRequestDto.getChannelId();
        if (Strings.isNullOrEmpty(channelId)) {
            channelId = UUID.randomUUID().toString().replaceAll("-", "");
        }
        // 生成客户端的rtcAuthToken，基于客户端传的userid
        String rtcAuthToken = createBase64Token(channelId, robotStartRequestDto.getUserId(), getClientTimestamp());

        String robotUserId = UUID.randomUUID().toString().replaceAll("-", "");
        // 生成aigc的rtcAuthToken，基于机器人的userid
        String robotRtcAuthToken = createBase64Token(channelId, robotUserId, getAigcTimestamp());

        String instanceId = aiRobotService.startRobot(channelId, robotUserId, robotRtcAuthToken, robotStartRequestDto.getConfig(), robotStartRequestDto.getRobotId());

        return AiRobotStartResponse.builder().robotInstanceId(instanceId).rtcAuthToken(rtcAuthToken)
                .robotUserId(robotUserId).channelId(channelId).build();
    }

    @Override
    public boolean stopRobot(RobotStopRequestDto robotStopRequestDto) {
        return aiRobotService.stopRobot(robotStopRequestDto.getRobotInstanceId());
    }

    @Override
    public boolean updateRobot(RobotUpdateRequestDto robotUpdateRequestDto) {
        return aiRobotService.updateRobot(robotUpdateRequestDto.getRobotInstanceId(), robotUpdateRequestDto.getConfig());
    }

    @Override
    public RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto) {
        String channelId = rtcAuthTokenRequestDto.getChannelId();
        if (Strings.isNullOrEmpty(channelId)) {
            channelId = UUID.randomUUID().toString().replaceAll("-", "");
        }
        long timestamp = getClientTimestamp();
        // 生成客户端的rtcAuthToken，基于客户端传的userid
        String rtcAuthToken = createBase64Token(channelId, rtcAuthTokenRequestDto.getUserId(), timestamp);

        return RtcAuthTokenResponse.builder().authToken(rtcAuthToken).timestamp(timestamp).build();
    }

    private long getClientTimestamp() {
        /* 过期时间戳最大24小时 */
        return DateUtils.addDays(new Date(), 1).getTime() / 1000;
    }

    private long getAigcTimestamp() {
        /* 过期时间戳最大7天 */
        return DateUtils.addDays(new Date(), 7).getTime() / 1000;
    }

    private String createBase64Token(String channelId, String userId, long timestamp) {
        String rtcAuthStr = String.format("%s%s%s%s%d", liveMicAppId, liveMicAppKey, channelId, userId, timestamp);
        String rtcAuth = getSHA256(rtcAuthStr);
        JSONObject tokenJson = new JSONObject();
        tokenJson.put("appid", liveMicAppId);
        tokenJson.put("channelid", channelId);
        tokenJson.put("userid", userId);
        tokenJson.put("nonce", "");
        tokenJson.put("timestamp", timestamp);
        tokenJson.put("gslb",new String[]{"https://gw.rtn.aliyuncs.com"});
        tokenJson.put("token", rtcAuth);
        return Base64.encodeToString(JSON.toJSONBytes(tokenJson));
    }

    /**
     * 字符串签名
     *
     * @param str 输入源
     * @return 返回签名
     */
    private static String getSHA256(String str) {
        MessageDigest messageDigest;
        String encodestr = "";
        try {
            messageDigest = MessageDigest.getInstance("SHA-256");
            messageDigest.update(str.getBytes("UTF-8"));
            encodestr = byte2Hex(messageDigest.digest());
        } catch (NoSuchAlgorithmException | UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return encodestr;
    }

    private static String byte2Hex(byte[] bytes) {
        StringBuilder stringBuffer = new StringBuilder();
        String temp = null;
        for (byte aByte : bytes) {
            temp = Integer.toHexString(aByte & 0xFF);
            if (temp.length() == 1) {
                stringBuffer.append("0");
            }
            stringBuffer.append(temp);
        }
        return stringBuffer.toString();
    }
}
