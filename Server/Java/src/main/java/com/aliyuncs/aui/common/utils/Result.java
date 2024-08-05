package com.aliyuncs.aui.common.utils;

import java.util.HashMap;
import java.util.Map;

/**
 * 返回数据
 *
 */
public class Result extends HashMap<String, Object> {

	private static final long serialVersionUID = 1L;
	
	public Result() {
		put("code", 200);
	}
	
	public static Result error() {
		return error(500, "服务器异常，请稍后重试");
	}

	public static Result notFound() {
		return error(404, "未查询到");
	}

	public static Result invalidParam() {
		return error(401, "参数错误");
	}
	
	public static Result error(String msg) {
		return error(500, msg);
	}
	
	public static Result error(int code, String msg) {
		Result r = new Result();
		r.put("code", code);
		r.put("message", msg);
		return r;
	}

	public static Result ok(String msg) {
		Result r = new Result();
		r.put("message", msg);
		return r;
	}
	
	public static Result ok(Map<String, Object> map) {
		Result r = new Result();
		r.putAll(map);
		return r;
	}
	
	public static Result ok() {
		return new Result();
	}

	@Override
	public Result put(String key, Object value) {
		super.put(key, value);
		return this;
	}

}
