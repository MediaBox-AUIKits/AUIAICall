package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author keria
 * @date 2023/7/4
 * @brief
 */
public class GroupMuteStatusResponse implements Serializable {
    /**
     * 群组id
     */
    public String groupId;

    /**
     * 群组禁言状态
     */
    public boolean isMuteAll;
}
