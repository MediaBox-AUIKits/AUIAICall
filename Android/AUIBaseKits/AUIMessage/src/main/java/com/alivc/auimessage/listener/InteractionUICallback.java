package com.alivc.auimessage.listener;

import com.alivc.auicommon.common.base.util.ThreadUtil;
import com.alivc.auimessage.model.base.InteractionError;

/**
 * @author puke
 * @version 2023/4/13
 */
public class InteractionUICallback<T> implements InteractionCallback<T> {

    private final InteractionCallback<T> callback;

    public InteractionUICallback(InteractionCallback<T> callback) {
        this.callback = callback;
    }

    @Override
    public void onSuccess(final T data) {
        if (callback != null) {
            if (callback instanceof InteractionUICallback) {
                callback.onSuccess(data);
            } else {
                ThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        callback.onSuccess(data);
                    }
                });
            }
        }
    }

    @Override
    public void onError(final InteractionError error) {
        if (callback != null) {
            if (callback instanceof InteractionUICallback) {
                callback.onError(error);
            } else {
                ThreadUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        callback.onError(error);
                    }
                });
            }
        }
    }
}
