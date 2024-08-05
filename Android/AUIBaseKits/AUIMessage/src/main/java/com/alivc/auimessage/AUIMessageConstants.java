package com.alivc.auimessage;

import static com.alivc.auimessage.AUIMessageConstants.ALIVC_IMPL;
import static com.alivc.auimessage.AUIMessageConstants.ALIVC_IM_IMPL;
import static com.alivc.auimessage.AUIMessageConstants.ALIVC_IM_NAME;
import static com.alivc.auimessage.AUIMessageConstants.ALIVC_NAME;
import static com.alivc.auimessage.AUIMessageConstants.RC_CHAT_ROOM_IMPL;
import static com.alivc.auimessage.AUIMessageConstants.RC_CHAT_ROOM_NAME;

import androidx.annotation.StringDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * @author baorunchen
 * @date 2023/11/8
 * @brief AUIMessage常量管理
 */
@Retention(RetentionPolicy.SOURCE)
@StringDef({
        ALIVC_NAME,
        ALIVC_IMPL,
        ALIVC_IM_NAME,
        ALIVC_IM_IMPL,
        RC_CHAT_ROOM_NAME,
        RC_CHAT_ROOM_IMPL,
})
public @interface AUIMessageConstants {

    /**
     * 阿里视频云旧版互动消息SDK
     */
    String ALIVC_NAME = "internal";
    String ALIVC_IMPL = "com.alivc.auimessage.internal.MessageServiceImpl";

    /**
     * 阿里视频云新版互动消息SDK
     */
    String ALIVC_IM_NAME = "alivcim";
    String ALIVC_IM_IMPL = "com.alivc.auimessage.alivcim.MessageServiceImpl";

    /**
     * 融云聊天室SDK
     */
    String RC_CHAT_ROOM_NAME = "rongcloud";
    String RC_CHAT_ROOM_IMPL = "com.alivc.auimessage.rongcloud.MessageServiceImpl";

}
