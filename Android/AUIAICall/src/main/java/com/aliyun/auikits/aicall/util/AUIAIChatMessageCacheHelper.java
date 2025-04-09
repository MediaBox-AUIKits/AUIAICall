package com.aliyun.auikits.aicall.util;

import android.text.TextUtils;

import com.aliyun.auikits.aiagent.ARTCAIChatAttachmentUploader;
import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.util.Logger;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class AUIAIChatMessageCacheHelper {
    private static final String TAG = "AUIAIChatMessageCache";

    public static  void saveMessage(String sessionId, List<ARTCAIChatEngine.ARTCAIChatMessage> message) {

        if(TextUtils.isEmpty(sessionId)) {
            return;
        }

        List<String> listStr = new ArrayList<>();
        for (ARTCAIChatEngine.ARTCAIChatMessage item : message) {
            listStr.add(item.toData().toString());
        }

        JSONArray jsonArray = new JSONArray(listStr);
        SettingStorage.getInstance().set(sessionId, jsonArray.toString());
    }

    public static List<ARTCAIChatEngine.ARTCAIChatMessage> loadMessage(String sessionId) {
        String jsonStr = SettingStorage.getInstance().get(sessionId);
        List<ARTCAIChatEngine.ARTCAIChatMessage> list = new ArrayList<>();
        if(TextUtils.isEmpty(jsonStr)) {
            return list;
        }

        try {
            JSONArray jsonArray = new JSONArray(jsonStr);
            for(int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObject = new JSONObject((String) jsonArray.optString(i));
                if(jsonObject != null) {
                    String dialogueId = jsonObject.getString("dialogueId");
                    String requestId = jsonObject.getString("requestId");
                    ARTCAIChatEngine.ARTCAIChatMessageState messageState = ARTCAIChatEngine.ARTCAIChatMessageState.values()[jsonObject.getInt("messageState")];
                    ARTCAIChatEngine.ARTCAIChatMessageType messageType = ARTCAIChatEngine.ARTCAIChatMessageType.values()[jsonObject.getInt("messageType")];
                    long sendTime = jsonObject.getLong("sendTime");
                    String text = jsonObject.getString("text");
                    String senderId = jsonObject.getString("senderId");
                    boolean isEnd = jsonObject.getBoolean("isEnd");
                    boolean isReasoningEnd = true;
                    if(jsonObject.has("isReasoningEnd")) {
                        isReasoningEnd = jsonObject.getBoolean("isReasoningEnd");
                    }
                    String reasoningText = "";
                    if(jsonObject.has("reasoningText")) {
                        reasoningText = jsonObject.getString("reasoningText");
                    }
                    String source = "";
                    if(jsonObject.has("source")){
                        source = jsonObject.getString("source");
                    }
                    String sourceType = "";
                    if(jsonObject.has("sourceType")){
                        sourceType = jsonObject.getString("sourceType");
                    }
                    ARTCAIChatEngine.ARTCAIChatMessage message = new ARTCAIChatEngine.ARTCAIChatMessage(dialogueId, requestId, messageState, messageType, sendTime, text, senderId, isEnd, reasoningText, isReasoningEnd, source, sourceType);
                    if(jsonObject.has("attachmentList")) {
                        message.attachmentList = new ArrayList<>();
                        JSONArray attachmentList = jsonObject.getJSONArray("attachmentList");
                        for(int j = 0; j < attachmentList.length(); j++) {
                            JSONObject attachment = new JSONObject((String) attachmentList.optString(j));
                            if(attachment != null) {
                                message.attachmentList.add(new ARTCAIChatAttachmentUploader.ARTCAIChatAttachment(attachment));
                            }
                        }
                    }
                    list.add(message);
                }
            }
            return list;
        } catch (JSONException e) {
            Logger.i("queryMessageList JSONObject failed");
        }
        return list;
    }

}
