package com.alivc.auicommon.common.base;

/**
 * @author puke
 * @version 2021/6/24
 */
public interface EventHandler<E extends Enum<E>> {

    /**
     * SDK事件回调
     *
     * @param event 事件类型
     * @param obj   事件参数
     */
    void onEvent(E event, Object obj);
}
