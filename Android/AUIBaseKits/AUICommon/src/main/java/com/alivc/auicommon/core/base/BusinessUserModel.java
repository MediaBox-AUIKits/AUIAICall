package com.alivc.auicommon.core.base;

import com.alivc.auicommon.core.utils.ColorUtil;

import java.io.Serializable;

/**
 * @author puke
 * @version 2021/5/21
 */
public class BusinessUserModel implements Serializable {

    public final int color = ColorUtil.randomColor();
    public String id;
    public String nick;

    public BusinessUserModel(String id, String nick) {
        this.id = id;
        this.nick = nick;
    }

    public BusinessUserModel() {
    }
}
