package com.alivc.auimessage.model.base;

import com.alivc.auimessage.AUIMessageLevel;

/**
 * @author puke
 * @version 2023/4/13
 */
public class AUIMessageModel<T> {
    /**
     * 消息ID
     */
    public String id;

    /**
     * 群组ID
     */
    public String groupId;

    /**
     * 消息级别
     */
    public @AUIMessageLevel int msgLevel;

    /**
     * 发送者信息
     */
    public AUIMessageUserInfo senderInfo;

    /**
     * 消息类型
     */
    public int type;

    /**
     * 消息体内容
     */
    public T data;

    public static <T> AUIMessageModel<T> from(int type, T data) {
        AUIMessageModel<T> message = new AUIMessageModel<>();
        message.type = type;
        message.data = data;
        return message;
    }

    @Override
    public String toString() {
        return "AUIMessageModel{" +
                "id='" + id + '\'' +
                ", groupId='" + groupId + '\'' +
                ", senderInfo=" + senderInfo +
                ", type=" + type +
                ", data=" + data +
                '}';
    }
}
