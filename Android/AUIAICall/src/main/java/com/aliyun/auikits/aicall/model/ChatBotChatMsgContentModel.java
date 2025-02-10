package com.aliyun.auikits.aicall.model;

import android.content.Context;

import com.aliyun.auikits.aiagent.service.IARTCAICallService;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.bean.ChatBotChatMessage;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;

import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.feed.AbsContentModel;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.base.feed.IBizCallback;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatBotChatMsgContentModel extends AbsContentModel<CardEntity> {
    private WeakReference<Context> mContextRef;

    private Map<String, Integer> mRequestIdToPositionMap = new HashMap<>();

    public ChatBotChatMsgContentModel(Context context) {
        super();
        this.mContextRef = new WeakReference<>(context);


    }

    @Override
    public void release() {
        super.release();
    }

    @Override
    public void initData(BizParameter parameter, IBizCallback<CardEntity> callback) {
        List<CardEntity> mChatMsgItemList = new ArrayList<>();
        if(callback != null) {
            callback.onSuccess(mChatMsgItemList);
        }

    }

    public void AddChatMsg(ChatBotChatMessage message, int currentPosition) {
        CardEntity cardEntity = new CardEntity();
        if(message.isAIResponse()) {
            cardEntity.cardType = CardTypeDef.CHATBOT_RECEIVE_TEXT_MESSAGE_CARD;
        }
        else {
            cardEntity.cardType = CardTypeDef.CHATBOT_SEND_TEXT_MESSAGE_CARD;
        }
        mRequestIdToPositionMap.put(getRequestIdMapId(message.getRequestId(), message.isAIResponse()), currentPosition);
        cardEntity.bizData = message;

        List<CardEntity> cardEntityList = new ArrayList<>();
        cardEntityList.add(cardEntity);
        insertContent(cardEntityList);
    }

    public void AddChatMsgFromHeader(ChatBotChatMessage message) {
        CardEntity cardEntity = new CardEntity();
        if(message.isAIResponse()) {
            cardEntity.cardType = CardTypeDef.CHATBOT_RECEIVE_TEXT_MESSAGE_CARD;
        }
        else {
            cardEntity.cardType = CardTypeDef.CHATBOT_SEND_TEXT_MESSAGE_CARD;
        }

        countPositionForHeader();

        mRequestIdToPositionMap.put(getRequestIdMapId(message.getRequestId(), message.isAIResponse()), 0);
        cardEntity.bizData = message;

        List<CardEntity> cardEntityList = new ArrayList<>();
        cardEntityList.add(cardEntity);
        insertContentHeader(cardEntityList);
    }

    public int getPositionByRequestId(String requestId, boolean isAIResponse) {

        if(!mRequestIdToPositionMap.containsKey(getRequestIdMapId(requestId, isAIResponse))) {
            return -1;
        }

        return mRequestIdToPositionMap.get(getRequestIdMapId(requestId, isAIResponse)).intValue();
    }

    public void countPositionForHeader() {
        for (Map.Entry<String, Integer> entry : mRequestIdToPositionMap.entrySet()) {
            String key = entry.getKey();
            Integer value = entry.getValue();
            mRequestIdToPositionMap.put(key, value + 1);
        }
    }

    public int getLenghtOfRequestMap() {
        return mRequestIdToPositionMap.size();
    }

    @Override
    public void updateContent(CardEntity data, int pos) {
        super.updateContent(data, pos);
    }

    @Override
    public void fetchData(boolean isPullToRefresh, BizParameter parameter, IBizCallback<CardEntity> callback) {

    }

    private String getRequestIdMapId(String requestId, boolean isAIResponse) {
        return requestId + (isAIResponse ? "aiResponse" : "UserSend");
    }
}
