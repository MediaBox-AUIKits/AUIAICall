package com.aliyuncs.aui.dto.enums;

/**
 * 推流状态
 *
 * @author chunlei.zcl
 */
public enum PushStreamStatus {

    // 表示推流
    PUBLIC("publish"),

    // 表示断流
    PUBLIC_DONE("publish_done");

    private String status;

    public static PushStreamStatus of(String val) {

        for (PushStreamStatus value : PushStreamStatus.values()) {
            if (val.equals(value.getStatus())) {
                return value;
            }
        }
        return null;
    }

    PushStreamStatus(String status) {
        this.status = status;
    }

    public String getStatus() {
        return status;
    }
}
