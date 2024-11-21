package com.aliyun.auikits.aiagent.util;

import android.util.Base64;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.service.IARTCAICallService;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class ARTCAIAgentUtil {
    public static class ARTCAIAgentShareInfo {
        public String requestId;
        public String name;
        public String aiAgentId;
        public String workflowType;
        public String expireTime;
        public String region;
        public long expireTimestamp;

        @Override
        public String toString() {
            return "ARTCAIAgentShareInfo{" +
                    "requestId='" + requestId + '\'' +
                    ", name='" + name + '\'' +
                    ", aiAgentId='" + aiAgentId + '\'' +
                    ", workflowType='" + workflowType + '\'' +
                    ", expireTime='" + expireTime + '\'' +
                    ", region='" + region + '\'' +
                    ", expireTimestamp=" + expireTimestamp +
                    '}';
        }
    }

    public static class ARTCAIAgentInfo {
        public String aIAgentInstanceId;
        public String rtcAuthToken;
        public String aIAgentUserId;
        public String channelId;
        public String requestId;
        public ARTCAICallEngine.ARTCAICallAgentType aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;

        @Override
        public String toString() {
            return "ARTCAIAgentInfo{" +
                    "aIAgentInstanceId='" + aIAgentInstanceId + '\'' +
                    ", rtcAuthToken='" + rtcAuthToken + '\'' +
                    ", aIAgentUserId='" + aIAgentUserId + '\'' +
                    ", channelId='" + channelId + '\'' +
                    ", requestId='" + requestId + '\'' +
                    ", aiCallAgentType=" + aiCallAgentType +
                    '}';
        }
    }

    public static ARTCAIAgentShareInfo parseAiAgentShareInfo(String shareInfoText) {
        try {
            byte[] decodeTokenBytes = Base64.decode(shareInfoText, Base64.DEFAULT);
            String decodeToken = new String(decodeTokenBytes);

            ARTCAIAgentShareInfo shareInfo = new ARTCAIAgentShareInfo();
            JSONObject jsonObject = new JSONObject(decodeToken);
            shareInfo.requestId = jsonObject.optString("RequestId");
            shareInfo.name = jsonObject.optString("Name");
            shareInfo.aiAgentId = jsonObject.optString("TemporaryAIAgentId");
            shareInfo.workflowType = jsonObject.optString("WorkflowType");
            shareInfo.expireTime = jsonObject.optString("ExpireTime");
            shareInfo.expireTimestamp = parseTimestamp(shareInfo.expireTime);
            shareInfo.region = jsonObject.optString("Region");

            return shareInfo;
        } catch (Exception ex) {
            ex.printStackTrace();
            Logger.i("parseShareInfo : " + ex.getMessage());
            return null;
        }
    }

    public static ARTCAIAgentInfo parseAiAgentInfo(JSONObject jsonObject) {
        ARTCAIAgentInfo aiAgentInfo = new ARTCAIAgentInfo();

        aiAgentInfo.aIAgentInstanceId = jsonObject.optString("ai_agent_instance_id");
        aiAgentInfo.rtcAuthToken = jsonObject.optString("rtc_auth_token");
        aiAgentInfo.aIAgentUserId = jsonObject.optString("ai_agent_user_id");
        aiAgentInfo.channelId = jsonObject.optString("channel_id");
        aiAgentInfo.requestId = jsonObject.optString("request_id");

        if (jsonObject.has("workflow_type")) {
            String workflowType = jsonObject.optString("workflow_type");
            if (IARTCAICallService.AI_AGENT_TYPE_AVATAR.equals(workflowType)) {
                aiAgentInfo.aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent;
            } else if (IARTCAICallService.AI_AGENT_TYPE_VISION.equals(workflowType)) {
                aiAgentInfo.aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.VisionAgent;
            } else {
                aiAgentInfo.aiCallAgentType = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
            }
        }

        return aiAgentInfo;
    }

    private static long parseTimestamp(String formatTime) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        long timestamp = 0;
        try {
            sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date date = sdf.parse(formatTime);
            timestamp = date.getTime();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return timestamp;
    }

}
