package com.aliyun.auikits.aicall.util;

import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;

import java.util.Locale;

public class AUIAICallLanguageUtils {
    public static void setAppLanguage(Context context, String languageCode) {
        Resources resources = context.getResources();
        Configuration config = resources.getConfiguration();

        // 设置语言
        Locale locale = new Locale(languageCode);
        Locale.setDefault(locale);

        // 更新配置
        config.setLocale(locale);
        resources.updateConfiguration(config, resources.getDisplayMetrics());
    }
}
