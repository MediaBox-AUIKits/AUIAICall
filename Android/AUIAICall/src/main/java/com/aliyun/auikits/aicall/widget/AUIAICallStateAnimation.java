package com.aliyun.auikits.aicall.widget;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.auikits.aicall.R;

public class AUIAICallStateAnimation extends RelativeLayout {

    private SpeechAnimationView loadingAniView;
    private ImageView errorView;
    private boolean isStartAni = false;
    private boolean isAppActive = false;

    private Application.ActivityLifecycleCallbacks lifecycleCallbacks;

    public AUIAICallStateAnimation(Context context) {
        super(context);
        init(context);
    }

    public AUIAICallStateAnimation(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public AUIAICallStateAnimation(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context);
    }

    private void init(Context context) {
        loadingAniView = new SpeechAnimationView(context);
        loadingAniView.setVisibility(GONE);

        errorView = new ImageView(context);
        errorView.setImageResource(R.drawable.ic_error);
        errorView.setContentDescription("error");
        errorView.setVisibility(GONE);

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
        );

        params.addRule(CENTER_IN_PARENT, TRUE);

        addView(loadingAniView, params);
        addView(errorView, params);

        lifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle bundle) {

            }

            @Override
            public void onActivityStarted(@NonNull Activity activity) {

            }

            @Override
            public void onActivityResumed(@NonNull Activity activity) {
                if (activity == getContext()) {
                    isAppActive = true;
                    applicationDidBecomeActive();
                }
            }

            @Override
            public void onActivityPaused(@NonNull Activity activity) {
                if (activity == getContext()) {
                    isAppActive = false;
                    applicationWillResignActive();
                }
            }

            @Override
            public void onActivityStopped(@NonNull Activity activity) {

            }

            @Override
            public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle bundle) {

            }

            @Override
            public void onActivityDestroyed(@NonNull Activity activity) {

            }
        };
        ((Application) getContext().getApplicationContext())
                .registerActivityLifecycleCallbacks(lifecycleCallbacks);
    }

    public void updateState(AUIAICallAgentAnimator.AUIAICallState newState) {
        boolean isLoading = newState == AUIAICallAgentAnimator.AUIAICallState.Connecting || newState == AUIAICallAgentAnimator.AUIAICallState.None;
        boolean isError = newState == AUIAICallAgentAnimator.AUIAICallState.Error;

        loadingAniView.setVisibility(isLoading ? VISIBLE : GONE);
        errorView.setVisibility(isError ? VISIBLE : GONE);

        if (isLoading) {
            if (isAppActive && !isStartAni) {
                isStartAni = true;
                loadingAniView.setAnimationType(SpeechAnimationView.AnimationType.Connecting);
                loadingAniView.startAnimation();
            }
        } else {
            loadingAniView.stopAnimation();
            isStartAni = false;
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ((Application) getContext().getApplicationContext())
                .unregisterActivityLifecycleCallbacks(lifecycleCallbacks);
    }

    private void applicationWillResignActive() {
        loadingAniView.stopAnimation();
    }

    private void applicationDidBecomeActive() {
        if (isStartAni) {
            loadingAniView.setAnimationType(SpeechAnimationView.AnimationType.Connecting);
            loadingAniView.startAnimation();
        }
    }
}