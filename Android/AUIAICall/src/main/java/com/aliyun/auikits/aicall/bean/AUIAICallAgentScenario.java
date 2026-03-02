package com.aliyun.auikits.aicall.bean;

import com.aliyun.auikits.aiagent.ARTCAICallEngine;

public class AUIAICallAgentScenario {
    private String scenarioName;
    private String agentId;
    private String asrModel;
    private String ttsModel;
    private String voiceId;  // 音色ID
    private String voiceName;  // 音色展示名称
    private String tags;
    private String tagFgColors;  // 标签文字颜色
    private String tagBgColors;  // 标签背景颜色
    private ARTCAICallEngine.ARTCAICallAgentType agentType;
    private boolean selected;
    private int limitSeconds = -1;  // 体验时长限制（单位：秒），-1 表示不限时
    private String region;  // 智能体所在区域

    public AUIAICallAgentScenario(String scenarioName, String agentId, String asrModel, String ttsModel, String tags, ARTCAICallEngine.ARTCAICallAgentType agentType) {
        this(scenarioName, agentId, asrModel, ttsModel, tags, null, null, agentType);
    }

    public AUIAICallAgentScenario(String scenarioName, String agentId, String asrModel, String ttsModel, String tags, String tagFgColors, String tagBgColors, ARTCAICallEngine.ARTCAICallAgentType agentType) {
        this.scenarioName = scenarioName;
        this.agentId = agentId;
        this.asrModel = asrModel;
        this.ttsModel = ttsModel;
        this.voiceId = "";  // 默认值
        this.tags = tags;
        this.tagFgColors = tagFgColors;
        this.tagBgColors = tagBgColors;
        this.agentType = agentType;
        this.selected = false;
    }

    public String getScenarioName() {
        return scenarioName;
    }

    public void setScenarioName(String scenarioName) {
        this.scenarioName = scenarioName;
    }

    public String getAgentId() {
        return agentId;
    }

    public void setAgentId(String agentId) {
        this.agentId = agentId;
    }

    public String getAsrModel() {
        return asrModel;
    }

    public void setAsrModel(String asrModel) {
        this.asrModel = asrModel;
    }

    public String getTtsModel() {
        return ttsModel;
    }

    public void setTtsModel(String ttsModel) {
        this.ttsModel = ttsModel;
    }

    public String getVoiceId() {
        return voiceId;
    }

    public void setVoiceId(String voiceId) {
        this.voiceId = voiceId;
    }

    public String getVoiceName() {
        return voiceName;
    }

    public void setVoiceName(String voiceName) {
        this.voiceName = voiceName;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public String getTagFgColors() {
        return tagFgColors;
    }

    public void setTagFgColors(String tagFgColors) {
        this.tagFgColors = tagFgColors;
    }

    public String getTagBgColors() {
        return tagBgColors;
    }

    public void setTagBgColors(String tagBgColors) {
        this.tagBgColors = tagBgColors;
    }

    public ARTCAICallEngine.ARTCAICallAgentType getAgentType() {
        return agentType;
    }

    public void setAgentType(ARTCAICallEngine.ARTCAICallAgentType agentType) {
        this.agentType = agentType;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }

    public int getLimitSeconds() {
        return limitSeconds;
    }

    public void setLimitSeconds(int limitSeconds) {
        this.limitSeconds = limitSeconds;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }
}
