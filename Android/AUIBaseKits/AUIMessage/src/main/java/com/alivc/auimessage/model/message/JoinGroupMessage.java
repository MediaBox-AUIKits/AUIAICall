package com.alivc.auimessage.model.message;

import java.io.Serializable;

/**
 * @author puke
 * @version 2023/4/23
 */
public class JoinGroupMessage implements Serializable {

    public String userId;

    public String userNick;

    public int likeCount;

    public int pv;

    public int uv;

    public int onlineCount;

    public boolean isMuteAll;
}
