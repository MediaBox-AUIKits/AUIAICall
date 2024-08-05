package com.alivc.auimessage.model.lwp;

import java.io.Serializable;

/**
 * Created by baorunchen on 2023/6/21.
 */
public class CreateGroupRequest implements Serializable {

    /**
     * 群组id，在Alivc无效，一般情况下无需传入
     */
    public String groupId;

    /**
     * 群组名称
     */
    public String groupName;

    /**
     * 扩展信息
     */
    public String groupExtension;

    @Override
    public String toString() {
        return "CreateGroupRequest{" +
                "groupId='" + groupId + '\'' +
                ", groupName='" + groupName + '\'' +
                ", groupExtension='" + groupExtension + '\'' +
                '}';
    }

}
