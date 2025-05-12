package com.aliyun.auikits.aicall.util.markwon;

import android.graphics.drawable.Drawable;
import android.text.style.ClickableSpan;
import android.text.style.ImageSpan;
import android.view.View;

import androidx.annotation.NonNull;

public class AUIAIMarkwonClickableImageSpan extends ImageSpan {

    public interface OnImageClickListener {
        void onImageClick(String imageUrl);
    }

    private final String imageUrl;
    private final OnImageClickListener listener;

    public AUIAIMarkwonClickableImageSpan(Drawable drawable, String source, OnImageClickListener listener) {
        super(drawable, source);
        this.imageUrl = source;
        this.listener = listener;
    }

    public void onClick() {
        if (listener != null) {
            listener.onImageClick(imageUrl);
        }
    }

    // 可选：结合ClickableSpan来处理点击
    public static ClickableSpan createClickableSpan(String url, OnImageClickListener listener) {
        return new ClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                if (listener != null) {
                    listener.onImageClick(url);
                }
            }
        };
    }
}
