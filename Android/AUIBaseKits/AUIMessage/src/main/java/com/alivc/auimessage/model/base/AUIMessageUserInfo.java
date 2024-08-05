package com.alivc.auimessage.model.base;

/**
 * @author puke
 * @version 2023/4/13
 */
public class AUIMessageUserInfo {
    public String userId;
    public String userNick;
    public String userAvatar;
    public String userExtension;

    @Override
    public String toString() {
        return "AUIMessageUserInfo{" +
                "userId='" + userId + '\'' +
                ", userNick='" + userNick + '\'' +
                ", userAvatar='" + userAvatar + '\'' +
                ", userExtension='" + userExtension + '\'' +
                '}';
    }
}
