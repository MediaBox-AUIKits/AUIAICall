package com.alivc.auimessage.model.base;

public class InteractionError {

    public String code;
    public String msg;
    public String source;

    public InteractionError() {
    }

    public InteractionError(String msg) {
        this(null, msg);
    }

    public InteractionError(String code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public InteractionError(String code, String msg, String source) {
        this.code = code;
        this.msg = msg;
        this.source = source;
    }

    @Override
    public String toString() {
        return "InteractionError{" +
                "code='" + code + '\'' +
                ", msg='" + msg + '\'' +
                ", source='" + source + '\'' +
                '}';
    }
}
