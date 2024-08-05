package com.alivc.auimessage.model.message;

import java.io.Serializable;

/**
 * @author keria
 * @date 2023/11/9
 * @brief 被动离开群组
 */
public class ExitGroupMessage implements Serializable {

    /**
     * 群组ID
     */
    public String groupId;

    /**
     * 被动离开群组原因
     */
    public String reason;

}
