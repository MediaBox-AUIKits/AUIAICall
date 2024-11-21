package com.aliyuncs.aui.dto.res;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * STS 数据
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UploadSTSInfoResponse {

    /**
     * 临时 ak
     */
    private String accessKeyId;
    /**
     * 临时 sk
     */
    private String accessKeySecret;
    /**
     * 临时 STS token
     */
    private String stsToken;
    /**
     * oss bucket
     */
    private String bucket;
    /**
     * oss region
     */
    private String region;
    /**
     * oss basePath
     */
    private String basePath;
    /**
     * 过期时间
     */
    private String expiration;

    private int code;

    private String errorCode;

    private String message;

    private String requestId;
}
