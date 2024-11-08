package com.aliyun.auikits.aiagent.util;

import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class Logger {
    private static final String TAG = "AUIAICall";

    private static List<String> sLogList = new ArrayList();
    private static final int MAX_LOG_SIZE = 1000;

    public static void i(String log) {
        Log.i(TAG, log);

        addLog(log);
    }

    private static void addLog(String log) {
        String recordStr = "[" + TimeUtil.formatedDateTime()+"]"+log;

        synchronized (Logger.class) {
            if (sLogList.size() < MAX_LOG_SIZE) {
                sLogList.add(recordStr);
            }
        }
    }

    public static String getAllLogRecordStr() {
        List<String> newLogList = new ArrayList<>();
        synchronized (Logger.class) {
            newLogList.addAll(sLogList);
            sLogList = new ArrayList<>();
        }

        StringBuilder builder = new StringBuilder();
        for (String log: newLogList) {
            builder.append(log).append("`");
        }

        return builder.toString();
    }
}
