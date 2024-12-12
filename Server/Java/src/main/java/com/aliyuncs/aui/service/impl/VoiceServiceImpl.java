package com.aliyuncs.aui.service.impl;

import com.alibaba.dashscope.audio.ttsv2.SpeechSynthesisParam;
import com.alibaba.dashscope.audio.ttsv2.SpeechSynthesizer;
import com.alibaba.dashscope.audio.ttsv2.enrollment.Voice;
import com.alibaba.dashscope.audio.ttsv2.enrollment.VoiceEnrollmentService;
import com.alibaba.dashscope.common.Status;
import com.alibaba.dashscope.exception.ApiException;
import com.alibaba.dashscope.exception.InputRequiredException;
import com.alibaba.dashscope.exception.NoApiKeyException;
import com.aliyuncs.aui.dto.req.CosyVoiceCloneRequestDto;
import com.aliyuncs.aui.dto.res.CosyVoiceCloneResponse;
import com.aliyuncs.aui.service.UploadService;
import com.aliyuncs.aui.service.VoiceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;


@Slf4j
@Service
public class VoiceServiceImpl implements VoiceService {

    @Resource
    private UploadService uploadService;

    @Value("${biz.voice.api_key}")
    private String apiKey;  // 如果您没有配置环境变量，请在此处用您的API-KEY进行替换

    private static final String targetModel = "cosyvoice-clone-v1";

    @Override
    public CosyVoiceCloneResponse cosyVoiceClone(CosyVoiceCloneRequestDto requestDto) {
        // 复刻声音
        VoiceEnrollmentService service = new VoiceEnrollmentService(apiKey);
        try {
            log.info("cosyVoiceClone start, userId:{}, voicePrefix:{}, url:{}", requestDto.getUserId(), requestDto.getVoicePrefix(), requestDto.getUrl());
            Voice myVoice = service.createVoice(targetModel, requestDto.getVoicePrefix(), requestDto.getUrl());
            log.info("cosyVoiceClone success, voiceId:{}, status:{}, resource_link:{}", myVoice.getVoiceId(), myVoice.getStatus(), myVoice.getResourceLink());
            return CosyVoiceCloneResponse.builder().code(200).voiceId(myVoice.getVoiceId()).build();
        } catch (ApiException e){
            log.error("ApiException, {}", e.getMessage());
            Status st = e.getStatus();
            if (st != null) {
                return CosyVoiceCloneResponse.builder().code(st.getStatusCode()).errorCode(st.getCode()).message(e.getMessage()).requestId(st.getRequestId()).build();
            } else {
                return CosyVoiceCloneResponse.builder().code(500).message(e.getMessage()).build();
            }
        }
        catch (Exception e) {
            log.error("cosyVoiceClone error", e);
            return CosyVoiceCloneResponse.builder().code(500).message(e.getMessage()).build();
        }
    }
}
