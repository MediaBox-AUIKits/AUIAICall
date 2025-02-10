package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;

import com.aliyun.auikits.aicall.R;

public class PlayMessageAnimationView extends ImageView {

    private Drawable originalDrawable; // 原始图像
    private Drawable[] animatedDrawables; // 动画图像数组
    private int animationIndex = 0; // 当前动画图像索引
    private boolean isAnimating = false; // 是否正在播放动画
    private Animation animation; // 动画

    public PlayMessageAnimationView(Context context) {
        super(context);
        init();
    }

    public PlayMessageAnimationView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public PlayMessageAnimationView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        // 初始化动画图像（这里你要根据自己的需求加载实际图像）
        animatedDrawables = new Drawable[]{
                getResources().getDrawable(R.drawable.ic_chatbot_message_playing_1),
                getResources().getDrawable(R.drawable.ic_chatbot_message_playing_2),
                getResources().getDrawable(R.drawable.ic_chatbot_message_playing_3)
        };

        // 保存原始图像
        originalDrawable = getDrawable();

        // 这里也可以加载你需要的动画效果
        //animation = AnimationUtils.loadAnimation(getContext(), R.anim.your_animation);
    }

    // 开始播放动画
    public void startAnimation() {
        if (isAnimating) return; // 如果已经在播放，直接返回
        isAnimating = true;
        animationIndex = 0;

        // 设置初始图像并开始动画
        setImageDrawable(animatedDrawables[animationIndex]);
        startAnimating();
    }

    // 递归播放动画
    private void startAnimating() {
        if (!isAnimating) {
            setImageDrawable(originalDrawable);
            return;
        }


        // 使用 Handler 每隔时间切换图像
        postDelayed(new Runnable() {
            @Override
            public void run() {
                animationIndex++;
                if (animationIndex >= animatedDrawables.length) {
                    animationIndex = 0;
                }
                setImageDrawable(animatedDrawables[animationIndex]);
                startAnimating();
            }
        }, 300);
    }

    // 结束播放动画
    public void stopAnimation() {
        isAnimating = false;
        setImageDrawable(originalDrawable);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        // 停止动画，在视图销毁时确保状态正常
        //stopAnimation();
    }
}
