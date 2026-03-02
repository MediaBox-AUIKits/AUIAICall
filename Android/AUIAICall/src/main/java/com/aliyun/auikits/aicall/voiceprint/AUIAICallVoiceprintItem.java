package com.aliyun.auikits.aicall.voiceprint;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * 声纹信息实体类
 */
public class AUIAICallVoiceprintItem {

    private String voiceprintId;
    private String name;
    private String filePath;
    private String ossUrl;

    public AUIAICallVoiceprintItem(String voiceprintId) {
        this.voiceprintId = voiceprintId;
        this.name = "";
        this.filePath = "";
        this.ossUrl = "";
    }

    public AUIAICallVoiceprintItem(JSONObject json) {
        if (json == null) {
            this.voiceprintId = "";
            this.name = "";
            this.filePath = "";
            this.ossUrl = "";
            return;
        }
        this.voiceprintId = json.optString("voiceprintId", "");
        this.name = json.optString("name", "");
        this.filePath = json.optString("filePath", "");
        this.ossUrl = json.optString("ossUrl", "");
    }

    public JSONObject toJson() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("voiceprintId", voiceprintId);
        json.put("name", name);
        json.put("filePath", filePath);
        json.put("ossUrl", ossUrl);
        return json;
    }

    public String getVoiceprintId() {
        return voiceprintId;
    }

    public void setVoiceprintId(String voiceprintId) {
        this.voiceprintId = voiceprintId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getOssUrl() {
        return ossUrl;
    }

    public void setOssUrl(String ossUrl) {
        this.ossUrl = ossUrl;
    }
}
