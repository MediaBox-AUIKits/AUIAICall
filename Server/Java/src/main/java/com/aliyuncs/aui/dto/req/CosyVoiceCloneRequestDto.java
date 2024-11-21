package com.aliyuncs.aui.dto.req;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import javax.validation.constraints.NotBlank;

@Data
public class CosyVoiceCloneRequestDto {

    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("voice_prefix")
    private String VoicePrefix;

    @NotBlank
    @JsonProperty("url")
    private String url;
}
