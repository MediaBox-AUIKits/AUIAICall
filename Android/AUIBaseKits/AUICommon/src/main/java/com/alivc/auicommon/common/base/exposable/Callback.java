package com.alivc.auicommon.common.base.exposable;

/**
 * @author puke
 * @version 2021/4/28
 */
public interface Callback<T> {

    void onSuccess(T data);

    void onError(String errorMsg);
}
