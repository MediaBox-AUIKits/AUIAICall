package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * AigcServiceRequestDto
 *
 * @author chunlei.zcl
 */
@Data
public class AigcServiceRequestDto {

    @ApiModelProperty(value = "任务id")
    @NotBlank(message="jobId不能为空")
    @JsonProperty("job_id")
    private String jobId;

}
