package com.alivc.auicommon.common.base.util;
/*
 * Copyright (C) 2010-2018 Alibaba Group Holding Limited.
 */

import java.util.concurrent.TimeUnit;

/**
 * 时间格式化工具类
 */
public class TimeFormat {
    private static final long LEAST_UTC_TIME = 1628071201217L - TimeUnit.DAYS.toMillis(10); //1 day before Wed Aug 04 2021 10:00:01 (UTC)

    /**
     * 格式化毫秒数为 xx:xx:xx这样的时间格式。
     *
     * @param ms 毫秒数
     * @return 格式化后的字符串
     */
    public static String formatMs(long ms) {
        int seconds = (int) (ms / 1000);
        int finalSec = seconds % 60;
        int finalMin = seconds / 60 % 60;
        int finalHour = seconds / 3600;

        StringBuilder msBuilder = new StringBuilder("");
        if (finalHour > 9) {
            msBuilder.append(finalHour).append(":");
        } else if (finalHour > 0) {
            msBuilder.append("0").append(finalHour).append(":");
        }

        if (finalMin > 9) {
            msBuilder.append(finalMin).append(":");
        } else if (finalMin > 0) {
            msBuilder.append("0").append(finalMin).append(":");
        } else {
            msBuilder.append("00").append(":");
        }

        if (finalSec > 9) {
            msBuilder.append(finalSec);
        } else if (finalSec > 0) {
            msBuilder.append("0").append(finalSec);
        } else {
            msBuilder.append("00");
        }

        return msBuilder.toString();
    }

    public static boolean isUtcTimeValid(long utcTime) {
        return utcTime > LEAST_UTC_TIME;
    }
}
