package com.alivc.auicommon.common.base.error;

/**
 * @author puke
 * @version 2021/6/21
 */
public enum Errors implements ErrorMessage {

    PARAM_ERROR("param error"),
    INNER_STATE_ERROR("inner state error"),
    LIVE_NOT_EXISTS("live not exists"),
    LIVE_END("live already end"),
    BIZ_PERMISSION_DENIED("biz permission denied"),
    OS_PERMISSION_DENIED("os permission denied"),
    NOT_LOGIN("not login"),
    ROLE_NOT_MATCH("role not match"),
    MAX_LENGTH_LIMIT("max length limit"),
    TOO_MUCH_FREQUENT("too much frequent"),
    CLASS_CREATOR_UID_NOT_MATCH(MSG_STR_CLASS_CREATOR_UID_NOT_MATCH),
    NETWORK_DOWN(MSG_STR_NETWORK_DOWN),
    ;

    private final String message;

    Errors(String message) {
        this.message = message;
    }

    @Override
    public String getMessage() {
        return message;
    }
}
