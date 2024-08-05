package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * @author baorunchen
 * @date 2023/7/4
 * @brief
 */
public class SendLikeResponse implements Serializable {

    /**
     * 间隔时间
     */
    public int intervalSecond;

    /**
     * 点赞数
     */
    public int likeCount;
}
