package com.alivc.auicommon.core.event;

/**
 * @author puke
 * @version 2021/7/30
 */
public interface EventListener {

    void onEvent(String action, Object... args);
}
