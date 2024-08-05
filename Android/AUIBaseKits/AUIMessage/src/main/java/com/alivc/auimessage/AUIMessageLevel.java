package com.alivc.auimessage;

import static com.alivc.auimessage.AUIMessageLevel.HIGH;
import static com.alivc.auimessage.AUIMessageLevel.NORMAL;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * @author keria
 * @date 2023/11/8
 * @brief 消息等级
 */
@Retention(RetentionPolicy.SOURCE)
@IntDef({
        NORMAL,
        HIGH,
})
public @interface AUIMessageLevel {

    int NORMAL = 0;

    int HIGH = 1;

}
