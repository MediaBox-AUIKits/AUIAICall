package com.alivc.auicommon.common.base.util;

import android.os.Looper;
import android.text.TextUtils;
import android.webkit.URLUtil;

public class Check {
    public static final long DEFAULT_CLICK_CHECK_GAP = 500L;
    public static long lastClickTime = 0L;
    public static long currentClickTime = 0L;

    public static boolean checkClickEvent() {
        return checkClickEvent(DEFAULT_CLICK_CHECK_GAP);
    }

    public static boolean checkClickEvent(long interval) {
        currentClickTime = System.currentTimeMillis();
        if (currentClickTime - lastClickTime > interval) {
            lastClickTime = currentClickTime;
            return true;
        }
        return false;
    }

    public static String getSafeString(String s) {
        if (s == null || s.isEmpty()) {
            return "";
        } else {
            return s;
        }
    }

    public static String getSafeString(String s, String defaultValue) {
        if (s == null || s.isEmpty()) {
            return Check.getSafeString(defaultValue);
        } else {
            return s;
        }
    }

    public static boolean isHttpUrl(String str) {
        return URLUtil.isHttpsUrl(str) || URLUtil.isHttpUrl(str);
    }

    public static String getMainUrl(String url) {
        if (!TextUtils.isEmpty(url)) {
            url = force2HttpUrl(url);
            String[] strs = url.split("\\?");
            if (strs.length > 0) {
                return strs[0];
            }
        }

        return url;
    }

    public static String force2HttpUrl(String url) {
        return TextUtils.isEmpty(url) ? "" : url.replaceAll("^((?i)https:)?//", "http://");
    }

    public static boolean checkMainThread() {
        return Looper.getMainLooper().getThread() == Thread.currentThread();
    }
}
