package com.alivc.auicommon.common.base;

import android.os.Handler;
import android.os.Looper;

import com.alivc.auicommon.common.base.exposable.IEventHandlerManager;

import java.util.ArrayList;
import java.util.List;

/**
 * 事件处理管理器
 *
 * @author puke
 * @version 2021/7/2
 */
public class EventHandlerManager<EH> implements IEventHandlerManager<EH>, IEventDispatcher<EH> {

    private static final byte[] LOCK = new byte[0];
    private static final Handler UI_HANDLER = new Handler(Looper.getMainLooper());
    private final List<EH> eventHandlers = new ArrayList<>();

    /**
     * 分发事件处理
     *
     * @param consumer 事件处理器
     */
    @Override
    public void dispatch(final Consumer<EH> consumer) {
        if (consumer == null) {
            return;
        }

        synchronized (LOCK) {
            for (final EH eventHandler : eventHandlers) {
                UI_HANDLER.post(new Runnable() {
                    @Override
                    public void run() {
                        consumer.consume(eventHandler);
                    }
                });
            }
        }
    }

    protected void dispatchAsync(Consumer<EH> consumer) {
        if (consumer == null) {
            return;
        }

        synchronized (LOCK) {
            for (EH eventHandler : eventHandlers) {
                consumer.consume(eventHandler);
            }
        }
    }

    @Override
    public void addEventHandler(EH eventHandler) {
        if (eventHandler == null) {
            return;
        }

        if (!eventHandlers.contains(eventHandler)) {
            synchronized (LOCK) {
                if (!eventHandlers.contains(eventHandler)) {
                    eventHandlers.add(eventHandler);
                }
            }
        }
    }

    @Override
    public void removeEventHandler(EH eventHandler) {
        if (eventHandler == null) {
            return;
        }

        synchronized (LOCK) {
            eventHandlers.remove(eventHandler);
        }
    }


    public interface Consumer<EH> {
        void consume(EH eventHandler);
    }
}
