package com.aliyun.auikits.aicall.base.feed;

import java.util.List;

public interface IBizCallback<T> {
    void onSuccess(List<T> data);
    void onError(int code, String msg);
}
