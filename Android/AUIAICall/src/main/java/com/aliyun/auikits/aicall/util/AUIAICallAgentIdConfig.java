package com.aliyun.auikits.aicall.util;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aiagent.ARTCAICallEngine.ARTCAICallAgentType;

public class AUIAICallAgentIdConfig {

    private static String VOICE_AGENT_ID = "";
    private static String Avatar_AGENT_ID = "";
    private static String VISION_AGENT_ID = "";
    private static String ChatBot_AGENT_ID = "";

    private static String VOICE_AGENT_EMOTION_ID = "";
    private static String Avatar_AGENT_EMOTION_ID = "";
    private static String VISION_AGENT_EMOTION_ID = "";
    private static String ChatBot_AGENT_EMOTION_ID = "";

    private static String PRE_VOICE_AGENT_ID = "";
    private static String PRE_Avatar_AGENT_ID = "";
    private static String PRE_VISION_AGENT_ID = "";
    private static String PRE_ChatBot_AGENT_ID = "";

    private static String PRE_VOICE_AGENT_EMOTION_ID = "";
    private static String PRE_Avatar_AGENT_EMOTION_ID = "";
    private static String PRE_VISION_AGENT_EMOTION_ID = "";
    private static String PRE_ChatBot_AGENT_EMOTION_ID = "";


    public static String getAIAgentId(ARTCAICallAgentType agentType, boolean openEmotion) {
        String agentId = "";
        switch (agentType) {
            case VoiceAgent:
                agentId = openEmotion ? VOICE_AGENT_EMOTION_ID : VOICE_AGENT_ID;
                break;
            case AvatarAgent:
                agentId = openEmotion ? Avatar_AGENT_EMOTION_ID : Avatar_AGENT_ID;
                break;
            case VisionAgent:
                agentId = openEmotion ? VISION_AGENT_EMOTION_ID : VISION_AGENT_ID;
                break;
            case ChatBot:
                agentId =  ChatBot_AGENT_ID;
                break;
        }
        return agentId;
    }

    public static  String  getAIAgentIdForDebug(ARTCAICallAgentType agentType, boolean openEmotion) {
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
        }
        return agentId;
    }
}
