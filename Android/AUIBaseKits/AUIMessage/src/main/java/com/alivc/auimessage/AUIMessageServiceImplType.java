package com.alivc.auimessage;

import static com.alivc.auimessage.AUIMessageConstants.ALIVC_IMPL;
import static com.alivc.auimessage.AUIMessageConstants.ALIVC_IM_IMPL;
import static com.alivc.auimessage.AUIMessageConstants.ALIVC_IM_NAME;
import static com.alivc.auimessage.AUIMessageConstants.ALIVC_NAME;
import static com.alivc.auimessage.AUIMessageConstants.RC_CHAT_ROOM_IMPL;
import static com.alivc.auimessage.AUIMessageConstants.RC_CHAT_ROOM_NAME;

/**
 * @author baorunchen
 * @date 2023/11/8
 * @brief AUIMessage接口的实现类型
 */
public enum AUIMessageServiceImplType {

    /**
     * 阿里视频云旧版互动消息SDK
     *
     * @implNote 对应`AUIMessageImpl-Internal`模块
     */
    ALIVC(ALIVC_NAME, ALIVC_IMPL),

    /**
     * 阿里视频云新版互动消息SDK
     *
     * @implNote 对应`AUIMessageImpl-AliVCIM`模块
     */
    ALIVC_IM(ALIVC_IM_NAME, ALIVC_IM_IMPL),

    /**
     * 融云聊天室SDK
     *
     * @implNote 对应`AUIMessageImpl-RongCloud`模块
     */
    RC_CHAT_ROOM(RC_CHAT_ROOM_NAME, RC_CHAT_ROOM_IMPL),

    ;

    /**
     * AUIMessage类型
     *
     * @implNote 如：internal、rongcloud
     */
    public final String name;

    /**
     * AUIMessage实现路径
     *
     * @implNote 对应MessageServiceImpl具体的包名路径，通过反射实例化
     */
    public final String impl;

    AUIMessageServiceImplType(String name, String impl) {
        this.name = name;
        this.impl = impl;
    }

    @Override
    public String toString() {
        return "AUIMessageServiceImplType{" +
                "name='" + name + '\'' +
                ", impl='" + impl + '\'' +
                '}';
    }

}
