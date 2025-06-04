package com.aliyun.auikits.aicall.widget;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewGroup;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.aliyun.auikits.aiagent.util.Logger;

public class AUIAICallDraggableConstraintLayout extends ConstraintLayout {

    private int xDelta;
    private int yDelta;

    public AUIAICallDraggableConstraintLayout(Context context) {
        super(context);
        init();
    }

    public AUIAICallDraggableConstraintLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public AUIAICallDraggableConstraintLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        // Set up touch listener
        setOnTouchListener((view, event) -> {
            ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) getLayoutParams();

            // 获取当前 View 在屏幕上的位置
            int[] location = new int[2];
            view.getLocationOnScreen(location);
            int viewLeftOnScreen = location[0];

            final int x = (int) event.getRawX();
            final int y = (int) event.getRawY();

            switch (event.getAction() & MotionEvent.ACTION_MASK) {
                case MotionEvent.ACTION_DOWN:
                    xDelta = x - viewLeftOnScreen;
                    yDelta = y - layoutParams.topMargin;
                    break;
                case MotionEvent.ACTION_MOVE:
                    int newLeftMargin = x - xDelta;
                    int newTopMargin = y - yDelta;

                    ViewGroup parent = (ViewGroup) getParent();
                    if (parent != null) {
                        // 边界限制
                        newLeftMargin = Math.max(0, Math.min(newLeftMargin, parent.getWidth() - getWidth()));
                        newTopMargin = Math.max(0, Math.min(newTopMargin, parent.getHeight() - getHeight()));

                        int newRightMargin = parent.getWidth() - newLeftMargin - getWidth();

                        layoutParams.leftMargin = newLeftMargin;
                        layoutParams.topMargin = newTopMargin;
                        layoutParams.rightMargin = newRightMargin;
                        setLayoutParams(layoutParams);
                        requestLayout();
                        invalidate();
                    }
                    break;
            }
            return true;
        });

    }
}
