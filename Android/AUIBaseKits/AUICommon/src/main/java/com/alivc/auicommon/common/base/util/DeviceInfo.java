package com.alivc.auicommon.common.base.util;

import androidx.annotation.NonNull;

/**
 * Created by baorunchen on 2022/4/30.
 * <p>
 * Device info
 */
public class DeviceInfo {
    /**
     * The count of cpu core.
     */
    public int cpuCount = 0;

    /**
     * The maximum MHz of cpu
     */
    public int cpuMHz = 0;

    /**
     * Memory of device
     */
    public long memory = 0L;

    /**
     * Device level
     * range: low, middle, high
     */
    public DeviceLevelChecker.DeviceLevel deviceLevel = null;

    /**
     * Device core
     * range: 0.0-10.0
     */
    public float deviceScore = 0.f;

    @NonNull
    @Override
    public String toString() {
        return "DeviceInfo{" +
                "cpuCount=" + cpuCount +
                ", cpuMHz=" + cpuMHz +
                ", memory=" + memory +
                ", deviceLevel=" + deviceLevel +
                ", score=" + deviceScore +
                '}';
    }
}
