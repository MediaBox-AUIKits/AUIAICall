package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author baorunchen
 * @date 2023/7/4
 * @brief
 */
public class GroupMuteStatusRequest implements Serializable {

    /**
     * 群组id
     */
    public String groupId;

    @Override
    public String toString() {
        return "GroupMuteStatusRequest{" +
                "groupId='" + groupId + '\'' +
                '}';
    }

}
