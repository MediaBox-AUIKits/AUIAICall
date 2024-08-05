package com.aliyuncs.aui.common.utils;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 分页工具类
 */
@Data
public class PageUtils implements Serializable {

	private static final long serialVersionUID = 1L;

	/**
	 * 当前页数
	 */
	private int currPage;
	/**
	 * 每页记录数
	 */
	private int pageSize;

	/**
	 * 列表数据
	 */
	private List<?> list;

	/**
	 * 总记录数
	 */
	private int totalCount;
	
	/**
	 * 分页
	 * @param list        列表数据
	 * @param totalCount  总记录数
	 * @param pageSize    每页记录数
	 * @param currPage    当前页数
	 */
	public PageUtils(List<?> list, int totalCount, int pageSize, int currPage) {
		this.currPage = currPage;
		this.pageSize = pageSize;
		this.list = list;
		this.totalCount = totalCount;
	}
}
