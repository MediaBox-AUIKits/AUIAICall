package com.aliyun.auikits.aicall.widget;

import android.graphics.Rect;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class AICallSubtitleSpacingItemDecoraion extends RecyclerView.ItemDecoration {
    private final int space;

    public AICallSubtitleSpacingItemDecoraion(int space) {
        this.space = space;
    }

    @Override
    public void getItemOffsets(Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        outRect.bottom = space;
    }
}
