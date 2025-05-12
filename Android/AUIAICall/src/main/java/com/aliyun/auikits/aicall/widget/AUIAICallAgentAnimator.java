package com.aliyun.auikits.aicall.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

public class AUIAICallAgentAnimator extends FrameLayout {

        public enum AUIAICallState {
        None(0),            // 初始化
        Connecting(1),      // 接通中
        Connected(2),       // 通话中
        Over(3),            // 通话结束
        Error(4);           // 通话出错了

        private final int value;

        AUIAICallState(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }

        public static AUIAICallState fromValue(int value) {
            for (AUIAICallState state : values()) {
                if (state.value == value) {
                    return state;
                }
            }
            return None;
        }
    }

    /**
     * 智能体状态
     * Agent State
     */
    public enum ARTCAICallAgentState {

        /**
         * 聆听中
         * Listening
         */
        Listening(0),

        /**
         * 思考中
         * Thinking
         */
        Thinking(1),

        /**
         * 讲话中
         * Speaking
         */
        Speaking(2);

        private final int value;

        ARTCAICallAgentState(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }

        public static ARTCAICallAgentState fromValue(int value) {
            for (ARTCAICallAgentState state : values()) {
                if (state.value == value) {
                    return state;
                }
            }
            return Listening; // 默认返回 Listening
        }
    }

    public AUIAICallAgentAnimator(Context context) {
        super(context);
    }

    public AUIAICallAgentAnimator(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public AUIAICallAgentAnimator(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void updateState(AUIAICallState newState) {
    }

    public void updateAgentAnimator(ARTCAICallAgentState state) {
    }

    public void onAgentInterrupted() {
    }

    public void updateAgentAnimator(String emotion) {
    }
}