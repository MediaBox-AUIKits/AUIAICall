package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.CosyVoiceCloneRequestDto;
import com.aliyuncs.aui.dto.res.CosyVoiceCloneResponse;

public interface VoiceService {
    CosyVoiceCloneResponse cosyVoiceClone(CosyVoiceCloneRequestDto request);
}
