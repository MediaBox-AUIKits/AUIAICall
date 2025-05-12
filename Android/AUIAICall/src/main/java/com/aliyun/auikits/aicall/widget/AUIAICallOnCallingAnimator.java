package com.aliyun.auikits.aicall.widget;

import android.animation.AnimatorListenerAdapter;
import android.animation.ValueAnimator;
import android.animation.Animator;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.graphics.Canvas;
import android.media.Image;
import android.os.Bundle;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;

public class AUIAICallOnCallingAnimator extends FrameLayout {

    private LottieAnimationView headAnimator;
    private LottieAnimationView handAnimator;
    private LottieAnimationView interruptAnimator;
    private LottieAnimationView eyeAnimator;
    private LottieAnimationView nextEyeAnimator;

    private FrameLayout eyeAnimatorContainerView;

    public boolean isStartAni = false;
    private boolean isPlayingAni = false;

    private static final float eyeOffset = 20.0f;
    private static final int frameCount = 40;


    private EyeAnimator currEyeAnimatorType = EyeAnimator.None;
    private EyeAnimator nextEyeAnimatorType = EyeAnimator.None;

    private Application.ActivityLifecycleCallbacks lifecycleCallbacks;

    public enum EyeAnimator {
        None,// 非动画场景
        Start,// 智能体启动
        Error,// 智能体出错
        Interrupting,// 智能体被打断
        Thinking,// 智能体思考中，或者加载中
        Listening,// 智能体聆听中
        Speaking,// 智能体讲话中（自然形态）
        HappySpeaking,// 智能体讲话中（开心形态）
        SadSpeaking// 智能体讲话中（伤心形态）
    }

    public AUIAICallOnCallingAnimator(Context context) {
        super(context);
        init();
    }

    public AUIAICallOnCallingAnimator(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public AUIAICallOnCallingAnimator(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        headAnimator = createAnimator("/Head", false, getContext(), 1);
        headAnimator.addAnimatorListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                headAnimator.reverseAnimationSpeed();
                headAnimator.playAnimation();
                if (nextEyeAnimatorType != EyeAnimator.None) {
                    startNextEyeAnimator(nextEyeAnimatorType);
                    if (currEyeAnimatorType == EyeAnimator.Interrupting) {
                        nextEyeAnimatorType = EyeAnimator.Listening;
                    } else {
                        nextEyeAnimatorType = EyeAnimator.None;
                    }
                }
            }
        });
        headAnimator.addAnimatorUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                float animatedFraction = animation.getAnimatedFraction();
                float speed = headAnimator.getSpeed();
                float progress;
                if (speed < 0) {
                    progress = 1 - animatedFraction;
                } else {
                    progress = animatedFraction;
                }
                float y = eyeOffset * (progress - 1.0f);
                eyeAnimatorContainerView.setTranslationY(y);
            }
        });

        handAnimator = createAnimator("/Hand", true, getContext(), 0);
        eyeAnimatorContainerView = new FrameLayout(getContext());
        eyeAnimator = new LottieAnimationView(getContext());
        this.addView(headAnimator);
        this.addView(handAnimator);
        this.addView(eyeAnimatorContainerView);

        eyeAnimatorContainerView.addView(eyeAnimator);

        lifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle bundle) {

            }

            @Override
            public void onActivityStarted(@NonNull Activity activity) {

            }

            @Override
            public void onActivityPaused(@NonNull Activity activity) {
                if (activity == getContext()) {
                    applicationWillResignActive();
                }
            }

            @Override
            public void onActivityResumed(@NonNull Activity activity) {
                if (activity == getContext()) {
                    applicationDidBecomeActive();
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
        ((Application) getContext().getApplicationContext()).registerActivityLifecycleCallbacks(lifecycleCallbacks);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);

        headAnimator.layout(0, 0, getWidth(), getHeight());
        handAnimator.layout(0, 0, getWidth(), getHeight());
        if (interruptAnimator != null) {
            interruptAnimator.layout(0, 0, getWidth(), getHeight());
        }

        eyeAnimatorContainerView.layout(0, 0, getWidth(), getWidth());
        eyeAnimatorContainerView.setX(getWidth() / 2.0f - eyeAnimatorContainerView.getWidth() / 2.0f);
        eyeAnimatorContainerView.setY(9);
        eyeAnimator.layout(0, 0, eyeAnimatorContainerView.getWidth(), eyeAnimatorContainerView.getHeight());
    }

    private LottieAnimationView createAnimator(String path, boolean loop, Context context, int repeatCount) {
        LottieAnimationView animator = new LottieAnimationView(context);
        String[] parts = path.split("/");
        String resName = parts[parts.length - 1];
        animator.setImageAssetsFolder("Avatar" + path + "/images");
        animator.setAnimation("Avatar" + path + "/" + resName + ".json");
        animator.setScaleType(ImageView.ScaleType.CENTER_CROP);
        animator.setRepeatCount(loop ? LottieDrawable.INFINITE : repeatCount);
        if (loop || repeatCount > 0) {
            animator.setRepeatMode(LottieDrawable.REVERSE);
        }
        animator.setSpeed(1f);
        return animator;
    }

    public void startAni() {
        if (isStartAni) {
            return;
        }
        isStartAni = true;

        if (currEyeAnimatorType == EyeAnimator.None) {
            if (nextEyeAnimator != null) {
                eyeAnimator.cancelAnimation();
                eyeAnimatorContainerView.removeView(eyeAnimator);

                eyeAnimator = nextEyeAnimator;
                eyeAnimatorContainerView.addView(eyeAnimator);
                currEyeAnimatorType = nextEyeAnimatorType;
                Log.d("Animator", "Start Animator Type: " + currEyeAnimatorType);
            }
        }
        playAni();
    }

    public void stopAni() {
        headAnimator.removeAllUpdateListeners();
        headAnimator.removeAllAnimatorListeners();
        headAnimator.cancelAnimation();
        handAnimator.cancelAnimation();
        eyeAnimator.cancelAnimation();
        if (interruptAnimator != null) {
            interruptAnimator.cancelAnimation();
        }
        isStartAni = false;
    }

    public void playAni() {
        if (isPlayingAni) {
            return;
        }
        isPlayingAni = true;

        headAnimator.playAnimation();
        handAnimator.playAnimation();
        eyeAnimator.playAnimation();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ((Application) getContext().getApplicationContext())
                .unregisterActivityLifecycleCallbacks(lifecycleCallbacks);
        stopAni();
    }

    public void pauseAni() {
        if (!isPlayingAni) {
            return;
        }
        isPlayingAni = false;

        if (nextEyeAnimatorType == EyeAnimator.Error) {
            startNextEyeAnimator(nextEyeAnimatorType);
        }
        headAnimator.pauseAnimation();
        handAnimator.pauseAnimation();
        eyeAnimator.pauseAnimation();
        if (interruptAnimator != null) {
            interruptAnimator.pauseAnimation();
        }
    }

    private void applicationWillResignActive() {
        pauseAni();
    }

    private void applicationDidBecomeActive() {
        if (isStartAni) {
            playAni();
        }
    }

    private void startNextEyeAnimator(EyeAnimator type) {
        LottieAnimationView animator = createEyeAnimator(type);
        if (animator == null) {
            return;
        }
        eyeAnimator.cancelAnimation();
        eyeAnimatorContainerView.removeView(eyeAnimator);

        animator.layout(0, 0, eyeAnimatorContainerView.getWidth(), eyeAnimatorContainerView.getWidth());
        animator.playAnimation();
        eyeAnimatorContainerView.addView(animator);

        eyeAnimator = animator;
        currEyeAnimatorType = type;
        Log.d("Animator", "Start Animator Type: " + currEyeAnimatorType);

        handAnimator.setVisibility(VISIBLE);
        if (interruptAnimator != null) {
            interruptAnimator.cancelAnimation();
            removeView(interruptAnimator);
            interruptAnimator = null;
        }
        if (currEyeAnimatorType == EyeAnimator.Interrupting || currEyeAnimatorType == EyeAnimator.Error) {
            handAnimator.setVisibility(GONE);
            interruptAnimator = createAnimator("/CoveringEyes", false, getContext(), 1);
            addView(interruptAnimator);
            interruptAnimator.playAnimation();
        }
    }

    public LottieAnimationView createEyeAnimator(EyeAnimator type) {
        String path = "";
        switch (type) {
            case None:
                return null;
            case Thinking:
                path = "/EyeEmotions/Thinking";
                break;
            case Listening:
                path = "/EyeEmotions/Listening";
                break;
            case Interrupting:
                path = "/EyeEmotions/Interrupting";
                break;
            case Speaking:
                path = "/EyeEmotions/Speaking";
                break;
            case HappySpeaking:
                path = "/EyeEmotions/Happy";
                break;
            case SadSpeaking:
                path = "/EyeEmotions/Sad";
                break;
            case Start:
                path = "/EyeEmotions/Thinking";
                break;
            case Error:
                path = "/EyeEmotions/Interrupting";
                break;
        }
        return createAnimator(path, true, getContext(), 0);
    }

    public void setEyeAnimatorType(EyeAnimator type) {
        Log.d("Animator", "Will Set Animator Type Curr: " + currEyeAnimatorType + " To: " + type);
        if (type == EyeAnimator.None) {
            return;
        }

        if (currEyeAnimatorType == type) {
            return;
        }

        if (currEyeAnimatorType == EyeAnimator.Error) {
            // 出错时最终状态，不能切换
            return;
        }

        if (nextEyeAnimatorType == EyeAnimator.Interrupting || nextEyeAnimatorType == EyeAnimator.Error) {
            // 如果下一个是打断状态，不能打断
            return;
        }
        if (currEyeAnimatorType == EyeAnimator.Interrupting) {
            // 当前打断状态，不能打断，需要等继续执行完成
            if (type == EyeAnimator.Speaking && nextEyeAnimatorType.ordinal() > type.ordinal()) {
                // 下一个是带表情状态讲话时，下一个不能切换为自然状态讲话
                return;
            }
            nextEyeAnimatorType = type;
            return;
        }

        if (type == EyeAnimator.Speaking && currEyeAnimatorType.ordinal() > type.ordinal()) {
            // 当前是带表情状态讲话时，不能切换为自然状态讲话
            return;
        }

        if (type == EyeAnimator.Interrupting || type == EyeAnimator.Error) {
            // 下一个是打断状态或错误状态，需要等当前执行完成
            nextEyeAnimatorType = type;
            return;
        }
        Log.d("Animator", "Set Animator Type Next: " + type + " Curr: " + currEyeAnimatorType);
        startNextEyeAnimator(type);
    }
}
