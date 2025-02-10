package com.aliyun.auikits.aicall.model;

import com.aliyun.auikits.aicall.R;
import com.aliyun.auikits.aicall.base.card.CardEntity;
import com.aliyun.auikits.aicall.base.feed.AbsContentModel;
import com.aliyun.auikits.aicall.base.feed.BizParameter;
import com.aliyun.auikits.aicall.base.feed.IBizCallback;
import com.aliyun.auikits.aicall.bean.AudioToneData;
import com.aliyun.auikits.aicall.widget.card.CardTypeDef;

import java.util.ArrayList;
import java.util.List;

public class AudioToneContentModel extends AbsContentModel<CardEntity> {

    private List<AudioToneData> mAudioToneList;

    public AudioToneContentModel( List<AudioToneData> audioToneList) {
        mAudioToneList = audioToneList;
    }

    @Override
    public void initData(BizParameter parameter, IBizCallback<CardEntity> callback) {
        List<CardEntity> cardEntities = new ArrayList<>();
        for (AudioToneData audioToneData : mAudioToneList) {
            CardEntity cardEntity = new CardEntity();
            cardEntity.cardType = CardTypeDef.AUDIO_TONE_CARD;
            cardEntity.bizData = audioToneData;
            cardEntities.add(cardEntity);
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

}
