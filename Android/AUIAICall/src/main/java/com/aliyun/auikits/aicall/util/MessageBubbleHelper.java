package com.aliyun.auikits.aicall.util;

import android.content.Context;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;

/**
 * 消息气泡宽度自适应辅助类
 * 根据设备屏幕尺寸动态计算合适的消息气泡最大宽度
 */
public class MessageBubbleHelper {
    
    private static final float BUBBLE_WIDTH_RATIO = 1.0f;
    private static final int MIN_BUBBLE_WIDTH_DP = 240;
    private static final int DEFAULT_BUBBLE_WIDTH_DP = 280;
    private static final int MAX_BUBBLE_WIDTH_DP = 420;
    private static Integer cachedMaxWidth = null;
    
    /**
     * 获取消息气泡最大宽度（像素）
     */
    public static int getMaxBubbleWidthPx(Context context) {
        if (cachedMaxWidth != null) {
            return cachedMaxWidth;
        }
        
        Resources resources = context.getResources();
        DisplayMetrics metrics = resources.getDisplayMetrics();
        
        int screenWidthDp = (int) (metrics.widthPixels / metrics.density);
        
        int horizontalMarginDp = 40;
        int paddingDp = 32;
        int availableWidthDp = screenWidthDp - horizontalMarginDp - paddingDp;
        
        int bubbleWidthDp = (int) (availableWidthDp * BUBBLE_WIDTH_RATIO);
        
        bubbleWidthDp = Math.max(bubbleWidthDp, MIN_BUBBLE_WIDTH_DP);
        bubbleWidthDp = Math.min(bubbleWidthDp, MAX_BUBBLE_WIDTH_DP);
        
        cachedMaxWidth = dp2px(context, bubbleWidthDp);
        return cachedMaxWidth;
    }
    
    /**
     * dp转px
     */
    public static int dp2px(Context context, float dpValue) {
        float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }
    
    /**
     * 为多个View应用最大宽度
     */
    public static void applyMaxWidth(Context context, View... views) {
        int maxWidth = getMaxBubbleWidthPx(context);
        for (View view : views) {
            if (view != null) {
                if (view instanceof TextView) {
                    ((TextView) view).setMaxWidth(maxWidth);
                } else if (view instanceof ConstraintLayout) {
                    ViewGroup.LayoutParams params = view.getLayoutParams();
                    if (params instanceof ConstraintLayout.LayoutParams) {
                        ((ConstraintLayout.LayoutParams) params).matchConstraintMaxWidth = maxWidth;
                        view.setLayoutParams(params);
                    }
                }
            }
        }
    }
}
