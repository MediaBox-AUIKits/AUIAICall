package com.alivc.auicommon.common.base;

import androidx.annotation.CallSuper;

import com.alivc.auicommon.common.base.util.ThreadUtil;
import com.alivc.auicommon.common.base.util.Utils;

import java.util.HashSet;
import java.util.Set;

/**
 * Created by KyleCe on 2021/7/2
 */
public abstract class BaseManager<E extends Enum<E>> implements IDestroyable {
    private Set<EventHandler<E>> eventHandlerSet;

    public void addEventHandler(EventHandler<E> handler) {
        initEventHandlerSetIfNecessary();
        eventHandlerSet.add(handler);
    }

    public void removeEventHandler(EventHandler<E> handler) {
        if (Utils.isEmpty(eventHandlerSet) || handler == null) {
            return;
        }

        eventHandlerSet.remove(handler);
    }

    @CallSuper
    @Override
    public void destroy() {
        clearEventHandler();
    }

    public void clearEventHandler() {
        Utils.clear(eventHandlerSet);
    }

    protected void postEvent(final E event) {
        postEvent(event, null);
    }

    protected void postEvent(final E event, final Object obj) {
        if (Utils.isEmpty(eventHandlerSet)) {
            return;
        }
        ThreadUtil.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                for (EventHandler<E> handler : eventHandlerSet) {
                    if (handler != null) {
                        handler.onEvent(event, obj);
                    }
                }
            }
        });
    }

    private void initEventHandlerSetIfNecessary() {
        if (eventHandlerSet == null) {
            eventHandlerSet = new HashSet<>(1);
        }
    }
}
