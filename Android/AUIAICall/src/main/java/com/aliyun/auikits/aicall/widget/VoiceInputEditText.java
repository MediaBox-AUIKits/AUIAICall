package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.EditText;

public class VoiceInputEditText extends EditText {
    private VoiceInputListener mVoiceInputListener;

    public interface VoiceInputListener {
        void onLongPressStart();
        void onLongPressEnd(boolean isUpperSlip);
        void onUpperSlip();
        void onBackSlip();
    }

    private boolean isLongPress = false;
    private boolean isUpperslip = false;
    private float lastDeltaY = 0;
    private boolean isEnabled = true;

    public void setVoiceInputListener(VoiceInputListener listener) {
        this.mVoiceInputListener = listener;
    }

    public void setEnabled(boolean enabled) {
        this.isEnabled = enabled;
    }

    public VoiceInputEditText(Context context) {
        super(context);
    }

    public VoiceInputEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public VoiceInputEditText(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if(!isEnabled) {
            return true;
        }
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                // 开始长按事件
                isLongPress = true;
                isUpperslip = false;
                lastDeltaY = 0;
                postDelayed(longPressRunnable, 200); // 500ms后视为长按
                break;
            case MotionEvent.ACTION_MOVE:
                if (isLongPress) {
                    // 在长按情况下进行滑动处理
                    float deltaY = event.getY() - getHeight() / 2;
                    if (!isUpperslip && deltaY < -100) { // 向上滑动，距离可调
                        // 处理取消语音输入等操作
                        onUpperSlip();
                        isUpperslip = true;
                    } else if(isUpperslip && deltaY > lastDeltaY && deltaY > 0 && deltaY < 100){
                        onUpperBack();
                        isUpperslip = false;
                    }
                    lastDeltaY = deltaY;
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                // 结束长按
                if(isLongPress) {
                    isLongPress = false;
                    removeCallbacks(longPressRunnable);
                    // 结束语音输入
                    stopVoiceInput();
                }
                break;
        }
        return true; // 处理掉事件
    }

    private Runnable longPressRunnable = new Runnable() {
        @Override
        public void run() {
            // 开始语音输入
            startVoiceInput();
        }
    };

    private void startVoiceInput() {
        if(mVoiceInputListener != null) {
            mVoiceInputListener.onLongPressStart();
        }
    }

    private void stopVoiceInput() {
        if(mVoiceInputListener != null) {
            mVoiceInputListener.onLongPressEnd(isUpperslip);
        }
    }

    private void onUpperSlip() {
        if(mVoiceInputListener != null) {
            mVoiceInputListener.onUpperSlip();
        }
    }

    private void onUpperBack() {
        if(mVoiceInputListener != null) {
            mVoiceInputListener.onBackSlip();
        }
    }
}