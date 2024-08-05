package com.alivc.auimessage.listener;

/**
 * @author keria
 * @date 2023/11/8
 * @brief AUIMessage连接回调
 * @note 对应iOS实现`AUIMessageServiceConnectionDelegate`
 */
public abstract class MessageConnectionListener {

    /**
     * Token过期事件
     */
    public abstract void onTokenExpire();

}
