package com.alivc.auicommon.common.base.log;

import androidx.annotation.Nullable;

/**
 * @author puke
 * @version 2021/5/27
 */
public interface LoggerHandler {

    void log(LogLevel level, String tag, String msg, @Nullable Throwable e);
}
