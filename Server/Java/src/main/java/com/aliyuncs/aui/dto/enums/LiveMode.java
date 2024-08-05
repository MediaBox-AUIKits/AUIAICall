package com.aliyuncs.aui.dto.enums;

/**
 * 直播模式
 *
 * @author chunlei.zcl
 */
public enum LiveMode {

    LiveModeNormal(0L),

    LiveModeLink(1L);
    private long val;

    public static LiveMode of(long val) {

        for (LiveMode value : LiveMode.values()) {
            if (val == value.getVal()) {
                return value;
            }
        }
        return null;
    }

    LiveMode(long val) {
        this.val = val;
    }

    public long getVal() {
        return val;
    }
}
