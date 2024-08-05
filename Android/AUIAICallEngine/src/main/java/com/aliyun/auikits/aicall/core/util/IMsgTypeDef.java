package com.aliyun.auikits.aicall.core.util;

public interface IMsgTypeDef {
    int MSG_TYPE_ROBOT_STATE_CHANGE = 1001;
    int MSG_TYPE_ROBOT_TEXT = 1002;
    int MSG_TYPE_USER_ASR_TEXT = 1003;

    int MSG_TYPE_INTERRUPT_ROBOT_SPEAK = 1101;

    interface ROBOT_STATE {
        int ROBOT_STATE_LISTENING = 1;
        int ROBOT_STATE_THINKING = 2;
        int ROBOT_STATE_SPEAKING = 3;
    }
}
