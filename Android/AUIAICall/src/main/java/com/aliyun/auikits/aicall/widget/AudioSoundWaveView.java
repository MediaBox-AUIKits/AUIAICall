package com.aliyun.auikits.aicall.widget;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import java.util.Random;

/**
 * 音频波形模拟视图
 */
public class AudioSoundWaveView extends View {

    public enum AnimationState { STOPPED, RUNNING, PAUSED }

    private int mBarCount = 7;
    private float[] mBarHeights;
    private int[] mPhases;     // 0 idle, 1 rising, 2 falling
    private float[] mProgress;
    private float[] riseSpeeds;
    private float[] fallSpeeds;

    private Paint mPaint;
    private int barColor = 0xFF457AFF;
    private float mBarSpacingRate = 0.25f;
    private float mBarWidth;
    private float mMinHeight = 0f;

    private ValueAnimator mFrameAnimator;
    private Random mRandom = new Random();

    private AnimationState currentState = AnimationState.STOPPED;
    private boolean isPaused = false;

    public AudioSoundWaveView(Context context) {
        super(context);
        init();
    }

    public AudioSoundWaveView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public AudioSoundWaveView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        mBarHeights = new float[mBarCount];
        mPhases = new int[mBarCount];
        mProgress = new float[mBarCount];
        riseSpeeds = new float[mBarCount];
        fallSpeeds = new float[mBarCount];

        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mPaint.setColor(barColor);

        resetBars();
        setupFrameAnimator();
    }

    private void setupFrameAnimator() {
        mFrameAnimator = ValueAnimator.ofFloat(0f, 1f);
        mFrameAnimator.setDuration(16);
        mFrameAnimator.setRepeatCount(ValueAnimator.INFINITE);
        mFrameAnimator.addUpdateListener(animation -> updateFrame());
    }

    private void updateFrame() {
        if (isPaused || getHeight() <= 0) return;

        float height = getHeight();
        mMinHeight = mBarWidth > 0f? mBarWidth : height / 10f;
        float maxHeight = height;

        // 每帧更新所有柱子
        for (int i = 0; i < mBarCount; i++) {
            switch (mPhases[i]) {
                case 1: // rising
                    mProgress[i] += riseSpeeds[i];
                    if (mProgress[i] >= 1f) {
                        mProgress[i] = 1f;
                        mPhases[i] = 2;
                    }
                    break;
                case 2: // falling
                    mProgress[i] -= fallSpeeds[i];
                    if (mProgress[i] <= 0f) {
                        mProgress[i] = 0f;
                        mPhases[i] = 0;
                    }
                    break;
                default:
                    // idle: 随机触发
                    if (mRandom.nextFloat() < 0.05f) {
                        mPhases[i] = 1;
                        riseSpeeds[i] = 0.05f + mRandom.nextFloat() * 0.1f;
                        fallSpeeds[i] = 0.01f + mRandom.nextFloat() * 0.03f;
                    }
            }
            mBarHeights[i] = mMinHeight + mProgress[i] * (maxHeight - mMinHeight);
        }

        postInvalidateOnAnimation();
    }

    private void resetBars() {
        for (int i = 0; i < mBarCount; i++) {
            mPhases[i] = 0;
            mProgress[i] = 0f;
            mBarHeights[i] = mMinHeight;
            riseSpeeds[i] = 0.05f + mRandom.nextFloat() * 0.1f;
            fallSpeeds[i] = 0.01f + mRandom.nextFloat() * 0.03f;
        }
    }

    public void start() {
        if (currentState == AnimationState.RUNNING) return;

        resetBars();
        isPaused = false;
        if (mFrameAnimator != null && !mFrameAnimator.isStarted()) {
            mFrameAnimator.start();
        }
        currentState = AnimationState.RUNNING;
    }

    public void pause() {
        if (currentState != AnimationState.RUNNING) return;
        for(int i = 0; i < mBarCount; i++) {
            mPhases[i] = 0;
            mProgress[i] = 0f;
            mBarHeights[i] = mMinHeight;
        }
        isPaused = true;
        currentState = AnimationState.PAUSED;
    }

    public void resume() {
        if (currentState != AnimationState.PAUSED) return;
        isPaused = false;
        currentState = AnimationState.RUNNING;
    }

    public void stop() {
        if (mFrameAnimator != null && mFrameAnimator.isRunning()) {
            mFrameAnimator.cancel();
        }
        resetBars();
        isPaused = false;
        currentState = AnimationState.STOPPED;
        invalidate();
    }

    public AnimationState getState() {
        return currentState;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        int width = getWidth();
        int height = getHeight();
        if (width == 0 || height == 0) return;

        float totalGapUnits = (mBarCount - 1) * mBarSpacingRate;
        mBarWidth = width / (mBarCount + totalGapUnits);
        float gap = mBarWidth * mBarSpacingRate;

        for (int i = 0; i < mBarCount; i++) {
            float left = i * (mBarWidth + gap);
            float top = height - mBarHeights[i];
            float right = left + mBarWidth;
            canvas.drawRect(left, top, right, height, mPaint);
        }
    }

    public void setBarColor(int color) {
        this.barColor = color;
        if (mPaint != null) {
            mPaint.setColor(color);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        stop();
    }
}