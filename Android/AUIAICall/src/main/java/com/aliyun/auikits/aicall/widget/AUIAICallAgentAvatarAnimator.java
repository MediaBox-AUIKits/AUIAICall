package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageView;

import com.aliyun.auikits.aicall.R;

public class AUIAICallAgentAvatarAnimator extends AUIAICallAgentAnimator {

    private ImageView bgView;
    private AUIAICallStartCallAnimator startCallAni;
    private AUIAICallOnCallingAnimator onCallingAni;
    private boolean isStartAniCompleted = false;

    private AUIAICallState curCallState = AUIAICallState.None;

    public AUIAICallAgentAvatarAnimator(Context context) {
        super(context);
        init(context);
    }

    public AUIAICallAgentAvatarAnimator(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public AUIAICallAgentAvatarAnimator(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    private void init(Context context) {
        bgView = new ImageView(context);
        bgView.setImageResource(R.drawable.bg_ai_agent_avatar);
        bgView.setScaleType(ImageView.ScaleType.FIT_CENTER);

        startCallAni = new AUIAICallStartCallAnimator(context);
        startCallAni.setVisibility(GONE);
        startCallAni.setCompletedBlock(() -> {
            startCallAni.setVisibility(GONE);
            onCallingAni.setVisibility(VISIBLE);
            isStartAniCompleted = true;
        });

        onCallingAni = new AUIAICallOnCallingAnimator(context);
        onCallingAni.setVisibility(GONE);

        addView(bgView, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        addView(startCallAni, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
        addView(onCallingAni, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);

        int length = 1080;

        bgView.layout(0, 0, 360, 360);
        bgView.setX((getWidth() - bgView.getWidth()) / 2f);
        bgView.setY((getHeight() - bgView.getHeight()) / 2f - 64);

        startCallAni.layout(0, 0, length, length);
        startCallAni.setX((getWidth() - startCallAni.getWidth()) / 2f);
        startCallAni.setY((getHeight() - startCallAni.getHeight()) / 2f);

        onCallingAni.layout(0, 0, length, length);
        onCallingAni.setX(startCallAni.getX());
        onCallingAni.setY(startCallAni.getY());
    }

    @Override
    public void updateState(AUIAICallState newState) {
        if (curCallState == newState) {
            return;
        }
        curCallState = newState;
        boolean isLoading = newState == AUIAICallState.Connecting || newState == AUIAICallState.None;
        boolean showOnCall = !isLoading && isStartAniCompleted;

        startCallAni.setVisibility(showOnCall ? GONE : VISIBLE);
        onCallingAni.setVisibility(showOnCall ? VISIBLE : GONE);

        if (isLoading) {
            startCallAni.startAni();
        }

        switch (newState) {
            case Connected:
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Listening);
                onCallingAni.startAni();
                break;
            case Error:
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Error);
                if (!onCallingAni.isStartAni) {
                    onCallingAni.startAni();
                }
                break;
            case Over:
//                onCallingAni.pauseAni();
                break;
            default:
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Start);
                onCallingAni.startAni();
                break;
        }
    }

    @Override
    public void updateAgentAnimator(ARTCAICallAgentState state) {
        if (curCallState == AUIAICallState.Connecting) {
            return;
        }
        switch (state) {
            case Listening:
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Listening);
                break;
            case Speaking:
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Speaking);
                break;
            case Thinking:
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Thinking);
                break;
        }
    }

    @Override
    public void onAgentInterrupted() {
        onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.Interrupting);
    }

    @Override
    public void updateAgentAnimator(String emotion) {
        switch (emotion) {
            case "happy":
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.HappySpeaking);
                break;
            case "sad":
                onCallingAni.setEyeAnimatorType(AUIAICallOnCallingAnimator.EyeAnimator.SadSpeaking);
                break;
        }
    }
}
