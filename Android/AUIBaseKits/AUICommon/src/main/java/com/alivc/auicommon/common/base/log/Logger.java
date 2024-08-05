package com.alivc.auicommon.common.base.log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * @author puke
 * @version 2021/5/27
 */
public class Logger {
    private static final String TAG = "Logger";

    private static LoggerHandler loggerHandler = new DefaultLoggerHandler();

    /**
     * 自定义日志处理逻辑
     *
     * @param loggerHandler 日志处理器
     */
    public static void setLoggerHandler(@NonNull LoggerHandler loggerHandler) {
        Logger.loggerHandler = loggerHandler;
    }

    public static void d(@Nullable Object content) {
        d(TAG, String.valueOf(content));
    }

    public static void d(@Nullable String tag, @NonNull String msg) {
        d(tag, msg, null);
    }

    public static void d(@Nullable String tag, @Nullable String msg, @Nullable Throwable e) {
        loggerHandler.log(LogLevel.DEBUG, tag, msg, e);
    }

    public static void i(@Nullable Object content) {
        i(TAG, String.valueOf(content));
    }

    public static void i(@Nullable String tag, @NonNull String msg) {
        i(tag, msg, null);
    }

    public static void i(@Nullable String tag, @Nullable String msg, @Nullable Throwable e) {
        loggerHandler.log(LogLevel.INFO, tag, msg, e);
    }

    public static void w(@Nullable Object content) {
        w(TAG, String.valueOf(content));
    }

    public static void w(@Nullable String tag, @NonNull String msg) {
        w(tag, msg, null);
    }

    public static void w(@Nullable String tag, @Nullable String msg, @Nullable Throwable e) {
        loggerHandler.log(LogLevel.WARN, tag, msg, e);
    }

    public static void e(@Nullable Object content) {
        e(TAG, String.valueOf(content));
    }

    public static void e(@Nullable String tag, @NonNull String msg) {
        e(tag, msg, null);
    }

    public static void e(@Nullable String tag, @Nullable String msg, @Nullable Throwable e) {
        loggerHandler.log(LogLevel.ERROR, tag, msg, e);
    }
}
