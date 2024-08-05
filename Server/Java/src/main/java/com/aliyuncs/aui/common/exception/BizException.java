package com.aliyuncs.aui.common.exception;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 自定义异常
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BizException extends RuntimeException {
	private static final long serialVersionUID = 1L;

	@Builder.Default
	private int code = 500;

    private String msg;

	public BizException(String msg, Throwable e) {
		super(msg, e);
		this.msg = msg;
	}

    public BizException(String msg) {
		super(msg);
		this.msg = msg;
	}

	public BizException(String msg, int code) {
		super(msg);
		this.msg = msg;
		this.code = code;
	}
	
	public BizException(String msg, int code, Throwable e) {
		super(msg, e);
		this.msg = msg;
		this.code = code;
	}
	
}
