package com.aliyun.auikits.aicall.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class TimeUtil {
    public static String formatDuration(long milliseconds) {
        // 计算总秒数
        long totalSeconds = milliseconds / 1000;

        // 计算当前小时数
        long hours = totalSeconds / 3600;

        // 计算当前分钟数
        long minutes = (totalSeconds % 3600) / 60;

        // 计算当前秒数
        long seconds = totalSeconds % 60;

        // 格式化为 hh:mm:ss
        String timeFormatted;
        if (hours > 0) {
            timeFormatted = String.format("%02d:%02d:%02d", hours, minutes, seconds);
        } else {
            timeFormatted = String.format("%02d:%02d", minutes, seconds);
        }
        return timeFormatted;
    }

    public static String videoPrintRecordFormatDuration(long milliseconds) {
        // 计算总秒数
        long totalSeconds = milliseconds / 1000;

        // 计算当前小时数
        long hours = totalSeconds / 3600;

        // 计算当前分钟数
        long minutes = (totalSeconds % 3600) / 60;

        // 计算当前秒数
        long seconds = totalSeconds % 60;

        // 格式化为 hh:mm:ss
        String timeFormatted;
        timeFormatted = String.format("%2d",  seconds);
        return timeFormatted;
    }

    private static SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss.SSS");
    public static String formatedDateTime() {
        String dateTimeStr = sDateFormat.format(new Date());
        return dateTimeStr;
    }
}
