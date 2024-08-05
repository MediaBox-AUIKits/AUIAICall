package com.alivc.auicommon.common.base.callback;

import com.alivc.auicommon.common.base.exposable.Callback;

/**
 * 回调函数实现类
 *
 * @author puke
 * @version 2021/5/27
 */
public class Callbacks {
    /**
     * 支持外部Lambda语法糖调用
     *
     * @param <T>
     */
    public static class Lambda<T> implements Callback<T> {

        private final CallbackWrapper<T> wrapper;

        public Lambda(CallbackWrapper<T> callback) {
            this.wrapper = callback;
        }

        @Override
        public void onSuccess(T data) {
            if (wrapper != null) {
                wrapper.onCall(true, data, null);
            }
        }

        @Override
        public void onError(String errorMsg) {
            if (wrapper != null) {
                wrapper.onCall(false, null, errorMsg);
            }
        }

        public interface CallbackWrapper<T> {
            void onCall(boolean success, T data, String errorMsg);
        }
    }
}
