package com.aliyun.auikits.aicall.util;

import android.content.Context;

import com.aliyun.auikits.aicall.BuildConfig;
import com.aliyun.auikits.aiagent.ARTCAICallEngine;
import com.aliyun.auikits.aicall.bean.AUIAICallAgentScenario;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class AUIAICallAgentScenarioConfig {

    private static final String CONFIG_DIR = "AgentConfig";
    private static final String CONFIG_FILE_ONLINE = "agent_scenes.json";
    private static final String CONFIG_FILE_PRE = "agent_scenes_pre.json";
    private static final String DEFAULT_COLOR_TOKEN = "DEFAULT";

    public static List<AUIAICallAgentScenario> getScenariosByAgentType(
            Context context,
            ARTCAICallEngine.ARTCAICallAgentType agentType,
            boolean useEmotional,
            boolean isPstnCall,
            boolean isInboundCall
    ) {
        List<AUIAICallAgentScenario> scenarios = new ArrayList<>();
        if (context == null) {
            return scenarios;
        }

        String fileName = chooseConfigFileName();
        String jsonText = loadJsonFromAssets(context, CONFIG_DIR + "/" + fileName);
        if (jsonText == null || jsonText.isEmpty()) {
            return scenarios;
        }

        try {
            JSONObject root = new JSONObject(jsonText);
            JSONArray agentsArray = root.optJSONArray("agents");
            if (agentsArray == null) {
                return scenarios;
            }

            for (int i = 0; i < agentsArray.length(); i++) {
                JSONObject agentItem = agentsArray.optJSONObject(i);
                if (agentItem == null) {
                    continue;
                }
                String agentTypeStr = agentItem.optString("agent_type");

                // 根据是否电话场景 / 智能体类型筛选
                if (!matchAgentType(agentTypeStr, agentType, isPstnCall, isInboundCall)) {
                    continue;
                }

                JSONArray scenesArray = agentItem.optJSONArray("scenes");
                if (scenesArray == null) {
                    continue;
                }

                for (int j = 0; j < scenesArray.length(); j++) {
                    JSONObject scene = scenesArray.optJSONObject(j);
                    if (scene == null) {
                        continue;
                    }

                    String agentId = scene.optString("agent_id");
                    String region = scene.optString("region");
                    String title = scene.optString("title");
                    String asrModelId = scene.optString("asr_model_id");
                    String ttsModelId = scene.optString("tts_model_id");
                    JSONArray tagsArray = scene.optJSONArray("tags");
                    String tags = buildTags(tagsArray);
                    String tagFgColors = buildTagFgColors(tagsArray);
                    String tagBgColors = buildTagBgColors(tagsArray);
                    String voiceId = buildVoiceId(scene.optJSONArray("voice_styles"));
                    String voiceName = buildVoiceName(scene.optJSONArray("voice_styles"));
                    int limitSeconds = scene.optInt("limit_seconds", -1);

                    // 电话呼入/呼出本质还是语音通话，这里统一走 VoiceAgent 类型
                    ARTCAICallEngine.ARTCAICallAgentType scenarioAgentType = agentType;
                    if (isPstnCall) {
                        scenarioAgentType = ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
                    }

                    AUIAICallAgentScenario scenario = new AUIAICallAgentScenario(
                            title,
                            agentId,
                            asrModelId,
                            ttsModelId,
                            tags,
                            tagFgColors,
                            tagBgColors,
                            scenarioAgentType
                    );

                    // 体验时长（秒），-1 表示不限时
                    scenario.setLimitSeconds(limitSeconds);

                    // 设置智能体所在区域
                    if (region != null && !region.isEmpty()) {
                        scenario.setRegion(region);
                    }

                    // 如果 JSON 里有 voice_styles，就用第一个 voice_id 覆盖默认的 "0"
                    if (voiceId != null && !voiceId.isEmpty()) {
                        scenario.setVoiceId(voiceId);
                    }

                    // 设置音色展示名称
                    if (voiceName != null && !voiceName.isEmpty()) {
                        scenario.setVoiceName(voiceName);
                    }

                    scenarios.add(scenario);
                }
            }
            
            // 在线上环境下，添加内置的低延迟评测智能体
            if (BuildConfig.TEST_ENV_MODE) {
                boolean usePreHost = SettingStorage.getInstance().getBoolean(
                        SettingStorage.KEY_APP_SERVER_TYPE,
                        SettingStorage.DEFAULT_APP_SERVER_TYPE
                );
                        
                if (!usePreHost) {
                    addDebugScenarios(scenarios, agentType, isPstnCall);
                }
            }
            
            // 默认选中第一个场景
            if (!scenarios.isEmpty()) {
                scenarios.get(0).setSelected(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return scenarios;
    }

    private static String chooseConfigFileName() {
        if (BuildConfig.TEST_ENV_MODE) {
            boolean usePreHost = SettingStorage.getInstance().getBoolean(
                    SettingStorage.KEY_APP_SERVER_TYPE,
                    SettingStorage.DEFAULT_APP_SERVER_TYPE
            );
            if (usePreHost) {
                return CONFIG_FILE_PRE;
            }
        }
        return CONFIG_FILE_ONLINE;
    }

    /**
     * 触发配置更新
     * 应在应用启动或进入场景选择页时调用
     */
    public static void reloadConfigFromRemote(Context context) {
        if (context == null) {
            return;
        }
        
        boolean usePreHost = false;
        if (BuildConfig.TEST_ENV_MODE) {
            usePreHost = SettingStorage.getInstance().getBoolean(
                    SettingStorage.KEY_APP_SERVER_TYPE,
                    SettingStorage.DEFAULT_APP_SERVER_TYPE
            );
        }
        
        // 异步从远端更新配置
        String fileName = chooseConfigFileName();
        AUIAICallAgentConfigUpdater.getInstance(context).reloadConfig(fileName, usePreHost, 
            new AUIAICallAgentConfigUpdater.UpdateCallback() {
                @Override
                public void onSuccess(boolean isUpdated) {
                    if (isUpdated) {
                        android.util.Log.i("AgentScenarioConfig", "Remote config updated successfully");
                    } else {
                        android.util.Log.i("AgentScenarioConfig", "Config is up to date");
                    }
                }
                
                @Override
                public void onFailure(String errorMsg) {
                    android.util.Log.w("AgentScenarioConfig", "Update failed, use local config: " + errorMsg);
                }
            });
    }

    private static String loadJsonFromAssets(Context context, String assetPath) {
        // 优先从缓存读取（如果远端更新过）
        String fileName = assetPath.substring(assetPath.lastIndexOf("/") + 1);
        String cachedContent = AUIAICallAgentConfigUpdater.getInstance(context).getConfig(fileName);
        if (cachedContent != null && !cachedContent.isEmpty()) {
            return cachedContent;
        }
        
        // 缓存不存在，从 Assets 读取（兜底）
        try (InputStream is = context.getAssets().open(assetPath);
             BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
            StringBuilder builder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
            return builder.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private static boolean matchAgentType(
            String agentTypeStr,
            ARTCAICallEngine.ARTCAICallAgentType agentType,
            boolean isPstnCall,
            boolean isInboundCall
    ) {
        if (isPstnCall) {
            if (isInboundCall) {
                return "InboundCall".equalsIgnoreCase(agentTypeStr);
            } else {
                return "OutboundCall".equalsIgnoreCase(agentTypeStr);
            }
        }

        switch (agentType) {
            case VoiceAgent:
                return "VoiceAgent".equalsIgnoreCase(agentTypeStr);
            case AvatarAgent:
                return "AvatarAgent".equalsIgnoreCase(agentTypeStr);
            case VisionAgent:
                return "VisionAgent".equalsIgnoreCase(agentTypeStr);
            case VideoAgent:
                return "VideoAgent".equalsIgnoreCase(agentTypeStr);
            case ChatBot:
                // JSON 里用的是 ChatAgent
                return "ChatAgent".equalsIgnoreCase(agentTypeStr) || "ChatBot".equalsIgnoreCase(agentTypeStr);
        }
        return false;
    }

    private static String buildTags(JSONArray tagsArray) {
        if (tagsArray == null || tagsArray.length() == 0) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < tagsArray.length(); i++) {
            JSONObject tagObj = tagsArray.optJSONObject(i);
            if (tagObj == null) {
                continue;
            }
            String name = tagObj.optString("name");
            if (name == null || name.isEmpty()) {
                continue;
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(name);
        }
        return builder.toString();
    }

    private static String buildTagFgColors(JSONArray tagsArray) {
        if (tagsArray == null || tagsArray.length() == 0) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < tagsArray.length(); i++) {
            JSONObject tagObj = tagsArray.optJSONObject(i);
            if (tagObj == null) {
                continue;
            }
            String name = tagObj.optString("name");
            if (name == null || name.isEmpty()) {
                continue;
            }
            String fg = tagObj.optString("fg");
            if (fg == null || fg.isEmpty()) {
                fg = DEFAULT_COLOR_TOKEN;
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(fg);
        }
        return builder.toString();
    }

    private static String buildTagBgColors(JSONArray tagsArray) {
        if (tagsArray == null || tagsArray.length() == 0) {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < tagsArray.length(); i++) {
            JSONObject tagObj = tagsArray.optJSONObject(i);
            if (tagObj == null) {
                continue;
            }
            String name = tagObj.optString("name");
            if (name == null || name.isEmpty()) {
                continue;
            }
            String bg = tagObj.optString("bg");
            if (bg == null || bg.isEmpty()) {
                bg = DEFAULT_COLOR_TOKEN;
            }
            if (builder.length() > 0) {
                builder.append(" ");
            }
            builder.append(bg);
        }
        return builder.toString();
    }

    /**
     * 从 voice_styles 数组中提取第一个 voice_id
     */
    private static String buildVoiceId(JSONArray voiceStylesArray) {
        if (voiceStylesArray == null || voiceStylesArray.length() == 0) {
            return "";
        }
        try {
            // 只取第一个 voice_styles 里的 voice_id
            JSONObject first = voiceStylesArray.optJSONObject(0);
            if (first != null) {
                return first.optString("voice_id", "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 从 voice_styles 数组中默认提取第一个（音色展示名称）
     */
    private static String buildVoiceName(JSONArray voiceStylesArray) {
        if (voiceStylesArray == null || voiceStylesArray.length() == 0) {
            return "";
        }
        try {
            JSONObject first = voiceStylesArray.optJSONObject(0);
            if (first != null) {
                return first.optString("name", "");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * 根据 agentId 获取指定场景的音色列表
     * @param context 上下文
     * @param agentId 智能体ID
     * @param agentType 智能体类型（保留用于向后兼容，实际通过agentId直接匹配）
     * @return 音色列表，默认第一个为 voice_styles[0]
     */
    public static List<com.aliyun.auikits.aicall.bean.AudioToneData> getVoiceStylesForAgent(
            Context context,
            String agentId,
            ARTCAICallEngine.ARTCAICallAgentType agentType
    ) {
        List<com.aliyun.auikits.aicall.bean.AudioToneData> voiceList = new ArrayList<>();
        if (context == null || android.text.TextUtils.isEmpty(agentId)) {
            return voiceList;
        }

        String fileName = chooseConfigFileName();
        String jsonText = loadJsonFromAssets(context, CONFIG_DIR + "/" + fileName);
        if (android.text.TextUtils.isEmpty(jsonText)) {
            return voiceList;
        }

        try {
            JSONObject root = new JSONObject(jsonText);
            JSONArray agentsArray = root.optJSONArray("agents");
            if (agentsArray == null) {
                return voiceList;
            }

            // 遍历所有 agent_type，直接通过 agent_id 匹配
            // 这样可以支持 OutboundCall、InboundCall 等所有类型
            for (int i = 0; i < agentsArray.length(); i++) {
                JSONObject agentObj = agentsArray.optJSONObject(i);
                if (agentObj == null) {
                    continue;
                }

                JSONArray scenesArray = agentObj.optJSONArray("scenes");
                if (scenesArray == null) {
                    continue;
                }

                for (int j = 0; j < scenesArray.length(); j++) {
                    JSONObject sceneObj = scenesArray.optJSONObject(j);
                    if (sceneObj == null) {
                        continue;
                    }

                    String sceneAgentId = sceneObj.optString("agent_id", "");
                    // 直接通过 agent_id 匹配，不限制 agent_type
                    if (!agentId.equals(sceneAgentId)) {
                        continue;
                    }

                    // 找到匹配的 agent_id，读取 voice_styles
                    JSONArray voiceStylesArray = sceneObj.optJSONArray("voice_styles");
                    if (voiceStylesArray == null || voiceStylesArray.length() == 0) {
                        return voiceList;
                    }

                    for (int k = 0; k < voiceStylesArray.length(); k++) {
                        JSONObject voiceStyle = voiceStylesArray.optJSONObject(k);
                        if (voiceStyle == null) {
                            continue;
                        }

                        String voiceId = voiceStyle.optString("voice_id", "");
                        String name = voiceStyle.optString("name", "");

                        if (!android.text.TextUtils.isEmpty(voiceId) && !android.text.TextUtils.isEmpty(name)) {
                            com.aliyun.auikits.aicall.bean.AudioToneData audioTone = new com.aliyun.auikits.aicall.bean.AudioToneData(voiceId, name);
                            if (k % 2 == 0) {
                                audioTone.setIconResId(com.aliyun.auikits.aicall.R.drawable.ic_audio_tone_0);
                            } else {
                                audioTone.setIconResId(com.aliyun.auikits.aicall.R.drawable.ic_audio_tone_1);
                            }
                            voiceList.add(audioTone);
                        }
                    }
                    return voiceList;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return voiceList;
    }

    private static String getAgentTypeStringForVoiceQuery(ARTCAICallEngine.ARTCAICallAgentType agentType) {
        if (agentType == ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent) {
            return "VoiceAgent";
        } else if (agentType == ARTCAICallEngine.ARTCAICallAgentType.AvatarAgent) {
            return "AvatarAgent";
        } else if (agentType == ARTCAICallEngine.ARTCAICallAgentType.VisionAgent) {
            return "VisionAgent";
        } else if (agentType == ARTCAICallEngine.ARTCAICallAgentType.VideoAgent) {
            return "VideoAgent";
        } else if (agentType == ARTCAICallEngine.ARTCAICallAgentType.ChatBot) {
            return "ChatAgent";
        }
        return "OutboundCall";
    }

    /**
     * 添加内置的低延迟评测智能体场景
     */
    private static void addDebugScenarios(
            List<AUIAICallAgentScenario> scenarios,
            ARTCAICallEngine.ARTCAICallAgentType agentType,
            boolean isPstnCall) {
        if (isPstnCall) {
            return;
        }

        if (agentType == ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent) {
            AUIAICallAgentScenario lowDelayVoice = new AUIAICallAgentScenario(
                    "官方-低延迟评测-语音通话-勿动",
                    "16dcf4be3a08433f8d33e5cae43eea61",
                    "",
                    "",
                    "",
                    ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent
            );
            scenarios.add(lowDelayVoice);
        } else if (agentType == ARTCAICallEngine.ARTCAICallAgentType.VisionAgent) {
            AUIAICallAgentScenario lowDelayVision = new AUIAICallAgentScenario(
                    "官方-低延迟评测-视觉理解通话-勿动",
                    "332707eddbff4d93a07654256ff77f49",
                    "",
                    "",
                    "",
                    ARTCAICallEngine.ARTCAICallAgentType.VisionAgent
            );
            scenarios.add(lowDelayVision);
        }
    }
}
