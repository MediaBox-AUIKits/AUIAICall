package com.aliyun.auikits.aicall.util;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;

public class AUIAICallAgentDebug {

    public static String PRE_HOST = "xxx";

    private static String PRE_VOICE_AGENT_ID = "";
    private static String PRE_Avatar_AGENT_ID = "";
    private static String PRE_VISION_AGENT_ID = "";
    private static String PRE_ChatBot_AGENT_ID = "";
    private static String PRE_VIDEO_AGENT_ID = "";
    private static String PRE_OUT_BOUND_AGENT_ID = "";

    private static String PRE_VOICE_AGENT_EMOTION_ID = "";
    private static String PRE_Avatar_AGENT_EMOTION_ID = "";
    private static String PRE_VISION_AGENT_EMOTION_ID = "";
    private static String PRE_VIDEO_AGENT_EMOTION_ID = "";

    private static String Region = "cn-shanghai";

    public static  String  getAIAgentId(ARTCAICallEngine.ARTCAICallAgentType agentType, boolean openEmotion) {
        String agentId = "";
        switch (agentType) {
            case VoiceAgent:
                agentId = openEmotion ? PRE_VOICE_AGENT_EMOTION_ID : PRE_VOICE_AGENT_ID;
                break;
            case AvatarAgent:
                agentId = openEmotion ? PRE_Avatar_AGENT_EMOTION_ID : PRE_Avatar_AGENT_ID;
                break;
            case VisionAgent:
                agentId = openEmotion ? PRE_VISION_AGENT_EMOTION_ID : PRE_VISION_AGENT_ID;
                break;
            case ChatBot:
                agentId =  PRE_ChatBot_AGENT_ID;
                break;
            case VideoAgent:
                agentId = openEmotion ? PRE_VIDEO_AGENT_EMOTION_ID : PRE_VIDEO_AGENT_ID;
        }
        return agentId;
    }

    public static String getOutBoundAgentId() {
        return PRE_OUT_BOUND_AGENT_ID;
    }

    public static String getRegion() {
        return Region;
    }

}
