package com.aliyun.auikits.aicall.base.card;

import android.content.Context;
import android.widget.LinearLayout;

import androidx.recyclerview.widget.RecyclerView;

public abstract class BaseCard extends LinearLayout {
    protected CardEntity entity;
    protected String cardType;

    public BaseCard(Context context) {
        super(context);
        this.setLayoutParams(new RecyclerView.LayoutParams(RecyclerView.LayoutParams.MATCH_PARENT, RecyclerView.LayoutParams.WRAP_CONTENT));
    }

    public abstract void onCreate(Context context);

    public void onBind(CardEntity entity) {
        this.entity = entity;
    }

    public void onUnBind() {}

    public String getCardType() {
        return cardType;
    }

    public void setCardType(String cardType) {
        this.cardType = cardType;
    }
}
