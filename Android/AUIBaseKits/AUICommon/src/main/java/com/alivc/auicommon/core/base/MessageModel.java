package com.alivc.auicommon.core.base;

import android.graphics.Color;
import android.text.TextUtils;

import com.alivc.auicommon.core.utils.ColorUtil;

/**
 * @author puke
 * @version 2021/5/13
 */
public class MessageModel {

    public String userNick;

    public String content;

    /**
     * type文字颜色
     */
    public int color;

    public String userId;

    /**
     * content文字颜色
     */
    public int contentColor = Color.WHITE;

    public MessageModel(String userNick, String content) {
        this.userNick = userNick;
        this.content = content;
        setColor(null);
    }

    public MessageModel(String userId, String userNick, String content) {
        this.userId = userId;
        this.content = content;
        this.userNick = userNick;
        setColor(userId);
    }

    private void setColor(String userId) {
        int seed = TextUtils.isEmpty(userId) ? 0 : userId.hashCode();
        this.color = ColorUtil.randomColor(seed);
    }
}
