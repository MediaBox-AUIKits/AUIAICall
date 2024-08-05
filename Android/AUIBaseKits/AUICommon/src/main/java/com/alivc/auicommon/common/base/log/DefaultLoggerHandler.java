package com.alivc.auicommon.common.base.log;

import android.util.Log;

import com.alivc.auicommon.common.base.AppContext;
import com.alivc.auicommon.common.base.util.CommonUtil;

/**
 * 默认日志处理器
 *
 * @author puke
 * @version 2021/5/27
 */
public class DefaultLoggerHandler implements LoggerHandler {
    private static final String MODULE = "RoomPaaS";
    /**
     * to turn on Log for release apk:
     * 1. input command line: adb shell setprop log.tag.RoomPaaS V
     * 2. relaunch app
     */
    public static final boolean LOG_IS_LOGGABLE = Log.isLoggable(MODULE, Log.VERBOSE);
    private static boolean sLoggable;
    private final boolean loggable;

    public DefaultLoggerHandler() {
        sLoggable = this.loggable = CommonUtil.isDebug(AppContext.getContext())/*Release包不做日志打印*/ || LOG_IS_LOGGABLE;
    }

    public static boolean isLoggable() {
        return sLoggable;
    }

    @Override
    public void log(LogLevel level, String tag, String msg, Throwable e) {
        if (!loggable) {
            return;
        }

        tag = "^^^" + tag;
        switch (level) {
            case DEBUG:
                if (e == null) {
                    Log.d(tag, msg);
                } else {
                    Log.d(tag, msg, e);
                }
                break;
            case INFO:
                if (e == null) {
                    Log.i(tag, msg);
                } else {
                    Log.i(tag, msg, e);
                }
                break;
            case WARN:
                if (e == null) {
                    Log.w(tag, msg);
                } else {
                    Log.w(tag, msg, e);
                }
                break;
            case ERROR:
                if (e == null) {
                    Log.e(tag, msg);
                } else {
                    Log.e(tag, msg, e);
                }
                break;
        }
    }
}
