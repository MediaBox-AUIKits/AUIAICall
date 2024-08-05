package com.aliyun.auikits.aicall.base.feed;

import android.text.TextUtils;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class BizParameter {
    /**
     * 请求参数
     */
    private Map<String,String> querySet = new HashMap<>();
    /**
     * 业务透传
     */
    private Set<String> payLoad = new HashSet<>();

    public BizParameter append(String name, String value) {
        if(!TextUtils.isEmpty(value)) {
            querySet.put(name, value);
        }
        return this;
    }

    boolean contain(String name) {
        return querySet.containsKey(name);
    }

    public Map<String, String> getQuerySet() {
        return querySet;
    }

    public Set<String> getPayLoad() {
        return payLoad;
    }
}
