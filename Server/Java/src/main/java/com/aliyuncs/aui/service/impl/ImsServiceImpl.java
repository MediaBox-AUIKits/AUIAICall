package com.aliyuncs.aui.service.impl;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.aliyuncs.aui.dto.req.*;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.service.AiAgentService;
import com.aliyuncs.aui.service.ImsService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.DateUtils;
import org.apache.shiro.codec.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.nio.charset.StandardCharsets;
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
    private AiAgentService aiAgentService;

    @Override
    public RtcAuthTokenResponse getRtcAuthToken(RtcAuthTokenRequestDto rtcAuthTokenRequestDto) {
        String channelId = rtcAuthTokenRequestDto.getChannelId();
        if (StringUtils.isBlank(channelId)) {
            channelId = UUID.randomUUID().toString().replaceAll("-", "");
        }
        long timestamp = getClientTimestamp();
        // 生成客户端的rtcAuthToken，基于客户端传的userid
        String rtcAuthToken = createBase64Token(channelId, rtcAuthTokenRequestDto.getUserId(), timestamp);
        log.info("getRtcAuthToken, params: {}, rtcAuthToken:{}", rtcAuthTokenRequestDto, rtcAuthToken);

        return RtcAuthTokenResponse.builder().authToken(rtcAuthToken).timestamp(timestamp).build();
    }

    @Override
    public GenerateMessageChatTokenResponse generateMessageChatToken(GenerateMessageChatTokenRequestDto request) {
        return aiAgentService.generateMessageChatToken(request.getAiAgentId(),request.getRole(), request.getUserId(), request.getExpire(), request.getRegion());
    }

    @Override
    public AiAgentInstanceDescribeResponse describeAiAgentInstance(AiAgentInstanceDescribeRequestDto request) {
        return aiAgentService.describeAiAgentInstance(request.getAiAgentInstanceId(), request.getRegion());
    }


    private long getClientTimestamp() {
        /* 过期时间戳最大24小时 */
        return DateUtils.addDays(new Date(), 1).getTime() / 1000;
    }

    private String createBase64Token(String channelId, String userId, long timestamp) {
        String rtcAuthStr = String.format("%s%s%s%s%d", liveMicAppId, liveMicAppKey, channelId, userId, timestamp);
        String rtcAuth = sha256(rtcAuthStr);
        JSONObject tokenJson = new JSONObject();
        tokenJson.put("appid", liveMicAppId);
        tokenJson.put("channelid", channelId);
        tokenJson.put("userid", userId);
        tokenJson.put("nonce", "");
        tokenJson.put("timestamp", timestamp);
        tokenJson.put("token", rtcAuth);
        return Base64.encodeToString(JSON.toJSONBytes(tokenJson));
    }

    /**
     * 字符串签名
     *
     * @param input 输入源
     * @return 返回签名
     */
    private static String sha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
}
