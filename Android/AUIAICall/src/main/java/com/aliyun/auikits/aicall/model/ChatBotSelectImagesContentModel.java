package com.aliyun.auikits.aicall.model;

import android.net.Uri;

import com.aliyun.auikits.aiagent.ARTCAIChatEngine;
import com.aliyun.auikits.aiagent.util.Logger;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.feed.AbsContentModel;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.base.feed.IBizCallback;
import com.aliyun.auikits.aicall.bean.ChatBotSelectedFileAttachment;

import java.util.ArrayList;
import java.util.List;

public class ChatBotSelectImagesContentModel extends AbsContentModel<CardEntity> {

    private List<ChatBotSelectedFileAttachment> mSelectedImages;
    private String mCardType;

    public ChatBotSelectImagesContentModel(List<ChatBotSelectedFileAttachment> selectedImages, String cardType) {
        mSelectedImages = selectedImages;
        mCardType = cardType;
    }

    @Override
    public void initData(BizParameter parameter, IBizCallback<CardEntity> callback) {
        List<CardEntity> cardEntities = new ArrayList<>();
        if(mSelectedImages != null) {
            for (ChatBotSelectedFileAttachment url : mSelectedImages) {
                CardEntity cardEntity = new CardEntity();
                cardEntity.cardType = mCardType;
                cardEntity.bizData = url;
                cardEntities.add(cardEntity);
            }
        }
        callback.onSuccess(cardEntities);
    }

    @Override
    public void updateContent(CardEntity data, int pos) {
            super.updateContent(data, pos);
    }


    @Override
    public void fetchData(boolean isPullToRefresh, BizParameter parameter, IBizCallback<CardEntity> callback) {
    }

    public void addSelectedImage(ChatBotSelectedFileAttachment imageUri) {
        CardEntity cardEntity = new CardEntity();
        cardEntity.cardType = mCardType;
        cardEntity.bizData = imageUri;
        List<CardEntity> cardEntityList = new ArrayList<>();
        cardEntityList.add(cardEntity);
        insertContent(cardEntityList);
    }

    public void removeSelectedImage(ChatBotSelectedFileAttachment imageUri) {
        CardEntity cardEntity = new CardEntity();
        cardEntity.cardType = mCardType;
        cardEntity.bizData = imageUri;
        List<CardEntity> cardEntityList = new ArrayList<>();
        cardEntityList.add(cardEntity);
        removeContent(cardEntityList);
    }
}
