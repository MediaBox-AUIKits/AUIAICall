package com.aliyun.auikits.aicall.base.feed;

import java.util.Map;

public interface IUiEventHandler {
    void onUIEvent(int eventId, Map<String,Object> param, Map<String,Object> result);
}
