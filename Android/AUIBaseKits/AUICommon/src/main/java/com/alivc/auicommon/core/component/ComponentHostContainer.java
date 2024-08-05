package com.alivc.auicommon.core.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;

/**
 * 逻辑组件容器 (不包含视图的纯逻辑组件容器)
 *
 * @author puke
 * @version 2021/8/30
 */
public class ComponentHostContainer extends ViewGroup {

    public ComponentHostContainer(Context context) {
        this(context, null, 0);
    }

    public ComponentHostContainer(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ComponentHostContainer(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setVisibility(GONE);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        // do nothing
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        // zero size
        int minSizeSpec = MeasureSpec.makeMeasureSpec(0, MeasureSpec.EXACTLY);
        super.onMeasure(minSizeSpec, minSizeSpec);
    }
}
