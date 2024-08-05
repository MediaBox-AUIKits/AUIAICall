package com.aliyun.auikits.aicall.base.card;

import android.content.Context;
import android.util.Log;
import android.view.ViewGroup;

import java.lang.reflect.Constructor;
import java.util.HashMap;
import java.util.Map;

public class DefaultCardViewFactory implements ICardViewFactory {
    private Map<String,Class> cardViewTypeMap = new HashMap<>();
    private Map<String, Constructor> creators= new HashMap<>();
    @Override
    public void registerCardView(String cardType, Class clazz) {
        cardViewTypeMap.put(cardType, clazz);
    }

    @Override
    public BaseCard createCardView(Context context, ViewGroup parent, String cardType) {
        Constructor constructor = creators.get(cardType);
        if(constructor == null) {
            Class clazz = cardViewTypeMap.get(cardType);
            if(clazz != null) {
                try {
                    constructor = clazz.getConstructor(Context.class);
                    creators.put(cardType, constructor);
                } catch (NoSuchMethodException e) {
                    e.printStackTrace();
                }
            }
        }

        if(constructor == null) {
            throw new RuntimeException("constructor==null for cardType=" + cardType);
        }

        BaseCard card = null;
        try {
            card = (BaseCard) constructor.newInstance(context);
            card.setCardType(cardType);
            card.onCreate(context);
        } catch (Exception e) {
            card = new FakeCard(context);
            e.printStackTrace();
            Log.e("Card", "创建卡片失败: cardType=" + cardType);
        }
        return card;
    }
}
