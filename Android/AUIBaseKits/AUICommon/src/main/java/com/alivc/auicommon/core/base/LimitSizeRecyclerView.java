package com.alivc.auicommon.core.base;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

/**
 * @author puke
 * @version 2021/5/13
 */
public class LimitSizeRecyclerView extends RecyclerView {

    private int maxWidth;
    private int maxHeight;

    public LimitSizeRecyclerView(@NonNull Context context) {
        super(context);
    }

    public LimitSizeRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public LimitSizeRecyclerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setMaxWidth(int maxWidth) {
        this.maxWidth = maxWidth;
    }

    public void setMaxHeight(int maxHeight) {
        this.maxHeight = maxHeight;
    }

    @Override
    protected void onMeasure(int widthSpec, int heightSpec) {
        if (maxWidth > 0) {
            int width = View.MeasureSpec.getSize(widthSpec);
            if (width > maxWidth) {
                widthSpec = View.MeasureSpec.makeMeasureSpec(
                        maxWidth, View.MeasureSpec.getMode(widthSpec));
            }
        }
        if (maxHeight > 0) {
            int height = View.MeasureSpec.getSize(heightSpec);
            if (height > maxHeight) {
                heightSpec = View.MeasureSpec.makeMeasureSpec(
                        maxHeight, View.MeasureSpec.getMode(heightSpec));
            }
        }
        super.onMeasure(widthSpec, heightSpec);
    }
}
