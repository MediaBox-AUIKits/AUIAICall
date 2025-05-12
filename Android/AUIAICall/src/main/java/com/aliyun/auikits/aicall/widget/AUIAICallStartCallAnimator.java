package com.aliyun.auikits.aicall.widget;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;

public class AUIAICallStartCallAnimator extends ViewGroup {

    private LottieAnimationView enterAnimator;
    private boolean isStartAni = false;
    private Runnable completedBlock;

    public AUIAICallStartCallAnimator(@NonNull Context context) {
        super(context);
    }

    public AUIAICallStartCallAnimator(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public AUIAICallStartCallAnimator(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public AUIAICallStartCallAnimator(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        if (enterAnimator != null) {
            enterAnimator.layout(0, 0, getWidth(), getHeight());
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stopAni();
    }

    private LottieAnimationView createAnimator(String path, boolean loop) {
        LottieAnimationView animator = new LottieAnimationView(this.getContext());
        animator.setImageAssetsFolder("Avatar" + path + "/images");
        animator.setAnimation("Avatar" + path + path + ".json");
        animator.setScaleType(ImageView.ScaleType.CENTER_CROP);
        animator.setRepeatCount(loop ? LottieDrawable.INFINITE : 0);
        animator.setSpeed(1f);
        return animator;
    }

    public void startAni() {
        if (isStartAni) {
            return;
        }
        isStartAni = true;
        enterAnimator = createAnimator("/Enter", false);
        this.addView(enterAnimator);
        requestLayout();
        enterAnimator.playAnimation();
        enterAnimator.addAnimatorListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                stopAni();
                if (completedBlock != null) {
                    completedBlock.run();
                }
            }
        });
    }

    private void stopAni() {
        isStartAni = false;
        if (enterAnimator != null) {
            enterAnimator.removeAllAnimatorListeners();
            removeView(enterAnimator);
            enterAnimator = null;
        }
    }

    public void setCompletedBlock(Runnable completedBlock) {
        this.completedBlock = completedBlock;
    }
}