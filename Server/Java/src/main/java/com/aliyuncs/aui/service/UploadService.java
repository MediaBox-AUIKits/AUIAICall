package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.UploadConfigGetRequestDto;
import com.aliyuncs.aui.dto.res.UploadSTSInfoResponse;

/**
 *  上传 OSS 服务
 */
public interface UploadService {

  UploadSTSInfoResponse get(UploadConfigGetRequestDto uploadConfigGetRequestDto);
}

