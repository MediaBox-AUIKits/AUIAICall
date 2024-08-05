package com.alivc.auicommon.common.base.model;

import java.io.Serializable;
import java.util.List;

/**
 * 统一的分页数据格式
 *
 * @author puke
 * @version 2021/5/31
 */
public class PageModel<T> implements Serializable {

    /**
     * 数据结果
     */
    public List<T> list;

    /**
     * 总数据量
     */
    public int total;

    /**
     * 是否还有更多数据
     */
    public boolean hasMore;
}
