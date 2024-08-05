package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author baorunchen
 * @date 2023/7/4
 * @brief
 */
public class SendLikeRequest implements Serializable {

    /**
     * 群组id
     */
    public String groupId;

    /**
     * 点赞数量
     */
    public int likeCount;

    @Override
    public String toString() {
        return "SendLikeRequest{" +
                "groupId='" + groupId + '\'' +
                ", likeCount=" + likeCount +
                '}';
    }

}
