package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 获取上传 OSS 所需的 STS 数据
 */
@Data
public class UploadConfigGetRequestDto {
    @NotBlank
    @JsonProperty("user_id")
    private String userId;
}