package com.aliyun.auikits.aicall.util;

import android.content.Context;
import android.view.Gravity;

import com.aliyun.auikits.aicall.R;

import io.github.muddz.styleabletoast.StyleableToast;

public class ToastHelper {

    public static void showToast(Context context, String text, int duration) {
        new StyleableToast.Builder(context)
                .text(text)
                .textColor(context.getResources().getColor(R.color.layout_base_white_default))
                .textSize(14)
                .cornerRadius(8)
                .backgroundColor(context.getResources().getColor(R.color.layout_base_toast_background))
                .length(duration)
                .gravity(Gravity.CENTER)
                .build().show();
    }

    public static void showToast(Context context, int resId, int duration) {
        showToast(context, context.getString(resId), duration);
    }
}
