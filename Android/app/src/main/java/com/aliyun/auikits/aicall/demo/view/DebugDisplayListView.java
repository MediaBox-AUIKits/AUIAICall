package com.aliyun.auikits.aicall.demo.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.ListView;

public final class DebugDisplayListView extends ListView {
    public DebugDisplayListView( Context context) {
        super(context);
    }

    public DebugDisplayListView( Context context,  AttributeSet attri) {
        super(context, attri);
    }

    public DebugDisplayListView( Context context,  AttributeSet attri, int defStyle) {
        super(context, attri, defStyle);
    }

    public DebugDisplayListView(Context context, AttributeSet attri, int defStyle, int defStyleRes) {
        super(context, attri, defStyle, defStyleRes);
    }

    @Override // android.widget.AbsListView, android.view.View
    public boolean onTouchEvent(MotionEvent ev) {
        return false;
    }

    @Override // android.widget.AbsListView, android.view.ViewGroup
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return false;
    }
}