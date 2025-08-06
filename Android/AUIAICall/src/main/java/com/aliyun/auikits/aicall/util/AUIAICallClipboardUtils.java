package com.aliyun.auikits.aicall.util;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;

import java.util.Locale;

public class AUIAICallClipboardUtils {
    public static void copyToClipboard(Context context, String text) {
        // 获取剪贴板管理器
        ClipboardManager clipboard = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        // 创建剪贴板数据
        ClipData clip = ClipData.newPlainText("AUIAICall", text); // "label" 可以自定义
        // 将数据放入剪贴板
        clipboard.setPrimaryClip(clip);
    }
}
