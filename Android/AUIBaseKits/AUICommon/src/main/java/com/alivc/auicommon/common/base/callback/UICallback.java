package com.alivc.auicommon.common.base.callback;


import android.os.Handler;
import android.os.Looper;

import com.alivc.auicommon.common.base.exposable.Callback;

/**
 * @author puke
 * @version 2021/4/28
 */
public class UICallback<T> implements Callback<T> {

    private static final Handler UI_HANDLER = new Handler(Looper.getMainLooper());

    private final Callback<T> callback;

    public UICallback(Callback<T> callback) {
        this.callback = callback;
    }

    @Override
    public void onSuccess(final T data) {
        if (callback != null) {
            if (isMainThread()) {
                callback.onSuccess(data);
            } else {
                UI_HANDLER.post(new Runnable() {
                    @Override
                    public void run() {
                        callback.onSuccess(data);
                    }
                });
            }
        }
    }

    @Override
    public void onError(final String errorMsg) {
        if (callback != null) {
            if (isMainThread()) {
                callback.onError(errorMsg);
            } else {
                UI_HANDLER.post(new Runnable() {
                    @Override
                    public void run() {
                        callback.onError(errorMsg);
                    }
                });
            }
        }
    }

    private boolean isMainThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }
}
