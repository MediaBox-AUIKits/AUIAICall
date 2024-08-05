package com.alivc.auicommon.common.base;

import androidx.annotation.CallSuper;

import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Created by KyleCe on 2021/9/15
 */
public class BaseDestroy implements IDestroyable {
    private final AtomicBoolean isDestroyed = new AtomicBoolean(false);

    protected boolean isDestroyed() {
        return isDestroyed.get();
    }

    @CallSuper
    @Override
    public void destroy() {
        isDestroyed.set(true);
    }
}
