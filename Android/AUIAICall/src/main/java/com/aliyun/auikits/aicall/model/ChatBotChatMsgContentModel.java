package com.aliyun.auikits.aicall.model;

import android.content.Context;

import com.aliyun.auikits.aiagent.ARTCAIChatAttachmentUploader;
import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
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
import android.net.Uri;
import android.text.TextUtils;

public class ChatBotChatMsgContentModel extends AbsContentModel<CardEntity> {
    private WeakReference<Context> mContextRef;

    private List<ARTCAIChatEngine.ARTCAIChatMessage> messageList = new ArrayList<ARTCAIChatEngine.ARTCAIChatMessage>();

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

        messageList.add(message.getMessage());

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

        messageList.add(0, message.getMessage());
        cardEntity.bizData = message;

        List<CardEntity> cardEntityList = new ArrayList<>();
        cardEntityList.add(cardEntity);
        insertContentHeader(cardEntityList);
    }

    public void deleteMessageByPosition(int pos) {
        if(pos >= 0 && pos < messageList.size()) {
            messageList.remove(pos);
        }
    }

    public int getPositionByChatMessage(ARTCAIChatEngine.ARTCAIChatMessage mes) {
       int pos = -1;
       if(mes != null) {
           for(int i = 0; i < messageList.size(); i++) {
               ARTCAIChatEngine.ARTCAIChatMessage message = messageList.get(i);
               if(message.requestId.equals(mes.requestId) && message.senderId.equals(mes.senderId)) {

                   if(!TextUtils.isEmpty(mes.nodeID)) {
                       if(TextUtils.isEmpty(message.nodeID)  || message.nodeID.equals(mes.nodeID)) {
                           pos = i;
                           break;
                       }
                   } else {
                       pos = i;
                       break;
                   }
               }
           }
       }
       return pos;
    }

    public ARTCAIChatEngine.ARTCAIChatMessage getCurrentThinkingMessage() {
        for(int i = 0; i < messageList.size(); i++) {
            ARTCAIChatEngine.ARTCAIChatMessage message = messageList.get(i);
            if(message.messageState == ARTCAIChatEngine.ARTCAIChatMessageState.Transfering && TextUtils.isEmpty(message.text)) {
                return message;
            }
        }
        return null;
    }


    @Override
    public void updateContent(CardEntity data, int pos) {
        super.updateContent(data, pos);

        if(pos >= 0 && pos < messageList.size()) {
            ARTCAIChatEngine.ARTCAIChatMessage message = messageList.get(pos);
            message= ((ChatBotChatMessage)data.bizData).getMessage() ;
        }
    }

    @Override
    public void fetchData(boolean isPullToRefresh, BizParameter parameter, IBizCallback<CardEntity> callback) {

    }

}
