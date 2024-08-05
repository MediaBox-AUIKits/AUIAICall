package com.alivc.auicommon.common.base;

/**
 * @author puke
 * @version 2021/12/15
 */
public interface IEventDispatcher<EH> {

    void dispatch(final EventHandlerManager.Consumer<EH> consumer);
}
