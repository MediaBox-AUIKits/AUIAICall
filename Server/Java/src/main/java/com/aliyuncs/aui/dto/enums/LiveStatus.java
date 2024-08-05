package com.aliyuncs.aui.dto.enums;

/**
 * 直播状态
 *
 * @author chunlei.zcl
 */
public enum LiveStatus {

    /**
    * 准备中或暂停中
    * @author chunlei.zcl
    */
    LiveStatusPrepare(0),

    /**
     * 已开始
     * @author chunlei.zcl
     */
    LiveStatusOn(1),

    /**
     * 已结束
     * @author chunlei.zcl
     */
    LiveStatusOff(2);

    private int val;

    public static LiveStatus of(int val) {

        for (LiveStatus value : LiveStatus.values()) {
            if (val == value.getVal()) {
                return value;
            }
        }
        return null;
    }

    LiveStatus(int val) {
        this.val = val;
    }

    public int getVal() {
        return val;
    }

}
