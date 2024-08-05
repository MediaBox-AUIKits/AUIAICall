package com.alivc.auicommon.common.base.util;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.log.Logger;

import java.util.HashMap;

/**
 * Created by baorunchen on 2021/12/23.
 * <p>
 * 设备性能评级分为三个维度：
 * 1、CPU主频（权重：0.5，⼤于2GHz）
 * 2、CPU核数（权重：0.2，⼤于6核）
 * 3、RAM内存（权重：0.3，⼤于4G）
 * <p>
 * 按照市场来划分：
 * 2018年以后的⼿机，可以认定为中端机以上；
 * 基本上满⾜以下条件，即：
 * CPU主频⼤于2GHz，CPU核数⼤于6核，RAM内存⼤于4G
 * 2019年以后的⼿机，基本上可以认定为中端机或⾼端机；
 * <p>
 * 参考芯⽚天梯图：https://www.mydrivers.com/zhuanti/tianti/01/
 * 骁⻰系列芯⽚：
 * 骁⻰845为2018Q1发⾏，搭载基于此以后的芯⽚，可以被认定为中端及以上的机型；（骁⻰835为2017Q1）
 * 麒麟系列芯⽚：
 * 麒麟970为2017Q3发⾏，搭载基于此以后的芯⽚，可以被认定为中端及以上的机型；（麒麟980为2018Q3）
 * 三星系列芯⽚：
 * Exynos9810为2018Q1发⾏，搭载基于此以后的芯⽚，可以被认定为中端及以上的机型；
 * 联发科系列芯⽚：
 * Helio P30为2017Q3发⾏，搭载基于此以后的芯⽚，可以被认定为中端及以上的机型；
 */
public final class DeviceLevelChecker {
    private static final String TAG = DeviceLevelChecker.class.getSimpleName();

    private static final String KEY_CPU_COUNT = "cpuCount";
    private static final String KEY_CPU_GHZ = "cpuGHz";
    private static final String KEY_MEMORY = "memory";
    private static final String KEY_DEVICE_SCORE = "device_score";
    private static final String KEY_DEVICE_LEVEL = "device_level";
    private static final String KEY_CHECKER_VERSION = "checker_version";

    private static final int DEVICE_LEVEL_CHECKER_VERSION = 1;

    private static final long MB = (1024 * 1024);
    private static final int MHZ_IN_KHZ = 1000;

    private static final float DEFAULT_CPU_COUNT_WEIGHT = 0.2f;
    private static final float DEFAULT_CPU_HZ_WEIGHT = 0.5f;
    private static final float DEFAULT_MEMORY_WEIGHT = 0.3f;
    private static final float DEFAULT_MIN_ANDROID_VERSION = Build.VERSION_CODES.O;

    // 参考麒麟970处理器，CPU使用八核心的设计，其中4个大核，主频为2.4GHz；四个小核，主频为1.8GHz。
    private static final int DEFAULT_MIN_CPU_MAX_HZ = 2020 * MHZ_IN_KHZ;
    private static final DeviceInfo mDeviceInfo = new DeviceInfo();
    private static final float THRESHOLD_SCORE_LOW_LEVEL = 8.0f;
    private static final float THRESHOLD_SCORE_MID_LEVEL = 9.0f;
    // Get device info only once to reduce method cost.
    private static volatile boolean mIsDeviceInfoLoaded = false;

    /**
     * Get level of current device
     * <p>
     * High-consuming method!!!
     *
     * @param context android context, not null
     * @return device level
     */
    public static DeviceLevel getDeviceLevel(@NonNull Context context) {
        DeviceInfo deviceInfo = getDeviceInfo(context);
        return deviceInfo.deviceLevel;
    }

    /**
     * Get score of current device
     * <p>
     * High-consuming method!!!
     *
     * @param context android context, not null
     * @return device score
     */
    public static float getDeviceScore(@NonNull Context context) {
        DeviceInfo deviceInfo = getDeviceInfo(context);
        return deviceInfo.deviceScore;
    }

    /**
     * Check the hard constraints of device level
     * If Android OS version is below 8.0,
     * or the cpu frequency is lower than 2GHz.
     * We think the performance of this device is weak.
     * <p>
     * High-consuming method!!!
     *
     * @return true->is low device level, false->not;
     */
    public static boolean isDeviceMatchHardConstraints() {
        int cpuMHz = DeviceInfoUtils.getCPUMaxFreqKHz();
        if (Build.VERSION.SDK_INT <= DEFAULT_MIN_ANDROID_VERSION || cpuMHz <= DEFAULT_MIN_CPU_MAX_HZ) {
            Logger.e(TAG, "android version is too low or cpuMHz is too low!");
            return true;
        }
        return false;
    }

    /**
     * Get device info with cpuCount,cpuMHz,memory
     * <p>
     * High-consuming method!!! <Called once>
     *
     * @param context android context
     * @return device info
     */
    @NonNull
    public static DeviceInfo getDeviceInfo(@NonNull Context context) {
        synchronized (DeviceLevelChecker.class) {
            if (!mIsDeviceInfoLoaded) {
                mDeviceInfo.cpuCount = DeviceInfoUtils.getNumberOfCPUCores();
                mDeviceInfo.cpuMHz = DeviceInfoUtils.getCPUMaxFreqKHz();
                mDeviceInfo.memory = DeviceInfoUtils.getTotalMemory(context);
                mDeviceInfo.deviceScore = calculateDeviceScore(mDeviceInfo.cpuCount, mDeviceInfo.cpuMHz, mDeviceInfo.memory);
                mDeviceInfo.deviceLevel = calculateDeviceLevelByScore(mDeviceInfo.deviceScore);
                trackDeviceLevel(mDeviceInfo);
                mIsDeviceInfoLoaded = true;
            }
        }
        return mDeviceInfo;
    }

    /**
     * Calculate device score by weighted average.
     *
     * @param cpuCount the count of cpu core
     * @param cpuMHz   the max MHz of cpu core
     * @param memory   memory info
     * @return weighted average score
     */
    private static float calculateDeviceScore(int cpuCount, int cpuMHz, long memory) {
        float cpuCountScore = DEFAULT_CPU_COUNT_WEIGHT * getCoreCountScore(cpuCount);
        float cpuMHZScore = DEFAULT_CPU_HZ_WEIGHT * getClockSpeedScore(cpuMHz);
        float memoryScore = DEFAULT_MEMORY_WEIGHT * getMemoryAverageScore(memory);
        return cpuCountScore + cpuMHZScore + memoryScore;
    }

    /**
     * Calculate the device level by device score
     *
     * @param deviceScore device score
     * @return device level
     */
    private static DeviceLevel calculateDeviceLevelByScore(float deviceScore) {
        if (isDeviceMatchHardConstraints()) {
            return DeviceLevel.LOW;
        }

        if (DeviceLevel.HIGH.judge(deviceScore)) {
            return DeviceLevel.HIGH;
        } else if (DeviceLevel.MIDDLE.judge(deviceScore)) {
            return DeviceLevel.MIDDLE;
        }

        return DeviceLevel.LOW;
    }

    /**
     * Get clock speed score
     *
     * @param cpuMHz cpu frequency
     * @return cpu frequency score
     */
    private static int getClockSpeedScore(int cpuMHz) {
        if (cpuMHz <= 0) {
            return 0;
        } else if (cpuMHz <= 528 * MHZ_IN_KHZ) {
            return 1;
        } else if (cpuMHz <= 620 * MHZ_IN_KHZ) {
            return 2;
        } else if (cpuMHz <= 1020 * MHZ_IN_KHZ) {
            return 3;
        } else if (cpuMHz <= 1220 * MHZ_IN_KHZ) {
            return 4;
        } else if (cpuMHz <= 1520 * MHZ_IN_KHZ) {
            return 5;
        } else if (cpuMHz <= 2020 * MHZ_IN_KHZ) {
            return 6;
        } else if (cpuMHz <= 2520 * MHZ_IN_KHZ) {
            return 8;
        } else {
            return 10;
        }
    }

    /**
     * Get cpu core count score
     *
     * @param cpuCount cpu core count
     * @return cpu core count score
     */
    private static int getCoreCountScore(int cpuCount) {
        if (cpuCount <= 0) {
            return 0;
        } else if (cpuCount == 1) {
            return 2;
        } else if (cpuCount <= 3) {
            return 4;
        } else if (cpuCount <= 6) {
            return 6;
        } else if (cpuCount <= 8) {
            return 8;
        } else {
            return 10;
        }
    }

    /**
     * Get score of memory average
     *
     * @param memory device memory
     * @return memory score
     */
    private static int getMemoryAverageScore(long memory) {
        if (memory <= 0L) {
            return 0;
        } else if (memory < 192 * MB) {
            return 1;
        } else if (memory < 290 * MB) {
            return 2;
        } else if (memory < 512 * MB) {
            return 3;
        } else if (memory < 1024 * MB) {
            return 4;
        } else if (memory < 1536 * MB) {
            return 5;
        } else if (memory < 2048 * MB) {
            return 6;
        } else if (memory < 3072 * MB) {
            return 7;
        } else if (memory < 4096 * MB) {
            return 8;
        } else if (memory < 6114 * MB) {
            return 9;
        } else {
            return 10;
        }
    }

    /**
     * Track device level information to sls
     *
     * @param deviceInfo the device info
     */
    @SuppressLint("DefaultLocale")
    private static void trackDeviceLevel(@Nullable DeviceInfo deviceInfo) {
        HashMap<String, String> extras = new HashMap<>(8);

        if (deviceInfo != null) {
            extras.put(KEY_CPU_COUNT, String.valueOf(deviceInfo.cpuCount));
            extras.put(KEY_CPU_GHZ, String.format("%.2f", (float) deviceInfo.cpuMHz / Math.pow(1000, 2)));
            extras.put(KEY_MEMORY, String.format("%.2f", (float) deviceInfo.memory / Math.pow(1024, 3)));
            extras.put(KEY_DEVICE_SCORE, String.valueOf(deviceInfo.deviceScore));
            extras.put(KEY_DEVICE_LEVEL, String.valueOf(deviceInfo.deviceLevel));
        }
        extras.put(KEY_CHECKER_VERSION, String.valueOf(DEVICE_LEVEL_CHECKER_VERSION));

//        WebTrackManager wtm = new WebTrackManager();
//        wtm.trackMethodCall(TAG, extras);
    }

    /**
     * Enums of device level
     * <p>
     * We classify the device level into three grades, low, middle, and high,
     * In general, the device which is produced after 2019,
     * can be judged as a middle or high device.
     */
    public enum DeviceLevel {
        LOW(0) {
            @Override
            public boolean judge(float score) {
                return score < THRESHOLD_SCORE_LOW_LEVEL;
            }
        },

        MIDDLE(1) {
            @Override
            public boolean judge(float score) {
                return score >= THRESHOLD_SCORE_LOW_LEVEL && score < THRESHOLD_SCORE_MID_LEVEL;
            }
        },

        HIGH(2) {
            @Override
            public boolean judge(float score) {
                return score >= THRESHOLD_SCORE_MID_LEVEL;
            }
        };

        DeviceLevel(int value) {
        }

        public abstract boolean judge(float score);
    }
}
