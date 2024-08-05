package com.alivc.auimessage.model.base;

public class InteractionErrors {

    public static final InteractionError INVALID_PARAM = new InteractionError("invalid param");
    public static final InteractionError INNER_PARAM = new InteractionError("inner error");

    private InteractionErrors() {
    }
}
