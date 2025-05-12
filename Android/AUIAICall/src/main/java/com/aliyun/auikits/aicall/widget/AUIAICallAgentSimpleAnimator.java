package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.util.AttributeSet;

public class AUIAICallAgentSimpleAnimator extends AUIAICallAgentAnimator {

    private AUIAICallStateAnimation callStateAni;
    private AUIAICallState curCallState = AUIAICallState.None;

    public AUIAICallAgentSimpleAnimator(Context context) {
        super(context);
        init(context);
    }

    public AUIAICallAgentSimpleAnimator(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public AUIAICallAgentSimpleAnimator(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    private void init(Context context) {
        callStateAni = new AUIAICallStateAnimation(context);
        addView(callStateAni, new LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
        ));
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        callStateAni.layout(0, 0, getWidth(), getHeight());
    }

    @Override
    public void updateState(AUIAICallState newState) {
        if (curCallState == newState) {
            return;
        }
        curCallState = newState;
        callStateAni.updateState(newState);
    }

}
