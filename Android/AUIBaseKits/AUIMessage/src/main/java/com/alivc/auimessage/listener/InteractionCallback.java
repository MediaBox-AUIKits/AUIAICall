package com.alivc.auimessage.listener;

import com.alivc.auimessage.model.base.InteractionError;

/**
 * @author puke
 * @version 2023/4/13
 */
public interface InteractionCallback<T> {

    void onSuccess(T data);

    void onError(InteractionError interactionError);
}
