package com.aliyun.auikits.aiagent.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class TimeUtil {

    private static SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss.SSS");
    public static String formatedDateTime() {
        String dateTimeStr = sDateFormat.format(new Date());
        return dateTimeStr;
    }
}
