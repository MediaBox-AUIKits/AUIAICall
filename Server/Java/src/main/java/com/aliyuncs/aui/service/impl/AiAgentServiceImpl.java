package com.aliyuncs.aui.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.aliyun.teaopenapi.Client;
import com.aliyun.teaopenapi.models.Config;
import com.aliyun.teaopenapi.models.OpenApiRequest;
import com.aliyun.teaopenapi.models.Params;
import com.aliyun.teautil.models.RuntimeOptions;
import com.aliyuncs.aui.dto.res.GenerateAIAgentCallResponse;
import com.aliyuncs.aui.service.AiAgentService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Map;

/**
 * AiAgentServiceImpl
 *
 * @author chunlei.zcl
 */
@Service
@Slf4j
public class AiAgentServiceImpl implements AiAgentService {

    private static Client client;

    @Value("${biz.ai_aent.region}")
    private String imsRegion;

    @Value("${biz.ai_aent.voice_chat_ai_agent_id}")
    private String voiceChatAiAgentId;

    @Value("${biz.ai_aent.avatar_ai_chat_3d_agent_id}")
    private String avatarChat3DAiAgentId;

    @Value("${biz.ai_aent.vision_chat_ai_agent_id}")
    private String visionChatAiAgentId;

    @Value("${biz.openapi.access.key}")
    private String accessKeyId;
    @Value("${biz.openapi.access.secret}")
    private String accessKeySecret;

    @PostConstruct
    public void createClient() throws Exception {
        Config config = new Config()
                .setAccessKeyId(accessKeyId)
                .setAccessKeySecret(accessKeySecret);
        config.endpoint = "ice." + imsRegion + ".aliyuncs.com";
        client = new Client(config);
    }

    @Override
    public String startAiAgent(String ChannelId, String userId, String rtcAuthToken, String templateConfig, String workflowType) {
        Params params = new Params()
                // 接口名称
                .setAction("StartAIAgentInstance")
                // 接口版本
                .setVersion("2020-11-09")
                // 接口协议
                .setProtocol("HTTPS")
                // 接口 HTTP 方法
                .setMethod("POST")
                .setAuthType("AK")
                .setStyle("HTTPS")
                // 接口 PATH
                .setPathname("/")
                // 接口请求体内容格式
                .setReqBodyType("json")
                // 接口响应体内容格式
                .setBodyType("json");

        boolean isAvatarChat3D = isAvatarChat3D(workflowType);

        java.util.Map<String, Object> queries = new java.util.HashMap<>();
        if(isAvatarChat3D(workflowType)){
            queries.put("AIAgentId", avatarChat3DAiAgentId);
        } else if(isVoiceChat(workflowType)){
            queries.put("AIAgentId", voiceChatAiAgentId);
        } else if(isVisionChat(workflowType)){
            queries.put("AIAgentId", visionChatAiAgentId);
        } else {
            throw new RuntimeException("workflowType is not support");
        }

        JSONObject runtimeConfig = new JSONObject();
        JSONObject chatJsonObj = new JSONObject();
        chatJsonObj.put("AgentUserId", userId);
        chatJsonObj.put("ChannelId", ChannelId);
        chatJsonObj.put("AuthToken", rtcAuthToken);
        if (isAvatarChat3D(workflowType)) {
            runtimeConfig.put("AvatarChat3D", chatJsonObj.toJSONString());
        } else if (isVoiceChat(workflowType)) {
            runtimeConfig.put("VoiceChat", chatJsonObj.toJSONString());
        } else if (isVisionChat(workflowType)) {
            runtimeConfig.put("VisionChat", chatJsonObj.toJSONString());
        } else {
            throw new RuntimeException("workflowType is not support");
        }
        queries.put("RuntimeConfig", runtimeConfig.toJSONString());

        if (StringUtils.isNotEmpty(templateConfig)) {
            queries.put("TemplateConfig", templateConfig);
        }
        RuntimeOptions runtime = new RuntimeOptions();
        try {
            OpenApiRequest request = new OpenApiRequest().setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("startAiAgent, queries：{}", JSONObject.toJSONString(queries));
            // 复制代码运行请自行打印 API 的返回值
            // 返回值为 Map 类型，可从 Map 中获得三类数据：响应体 body、响应头 headers、HTTP 返回的状态码 statusCode。
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("startAiAgent, response:{}", JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        String instanceId = (String) body.get("InstanceId");
                        log.info("startAiAgent success. instanceId:{}, consume:{}ms", instanceId, (System.currentTimeMillis() - start));
                        return instanceId;
                    }
                }
            }
        } catch (Exception e) {
            log.error("startAiAgent error. e:{}", e.getMessage());
            throw new RuntimeException(e);
        }
        return null;
    }

    private static boolean isAvatarChat3D(String workflowType) {
        boolean isAvatarChat3D = "AvatarChat3D".equalsIgnoreCase(workflowType);
        return isAvatarChat3D;
    }

    private static boolean isVoiceChat(String workflowType){
        return "VoiceChat".equalsIgnoreCase(workflowType);
    }

    private static boolean isVisionChat(String workflowType) {
        return "VisionChat".equalsIgnoreCase(workflowType);
    }

    @Override
    public boolean stopAiAgent(String aiAgentInstanceId) {
        Params params = new Params()
                // 接口名称
                .setAction("StopAIAgentInstance")
                // 接口版本
                .setVersion("2020-11-09")
                // 接口协议
                .setProtocol("HTTPS")
                // 接口 HTTP 方法
                .setMethod("POST")
                .setAuthType("AK")
                .setStyle("HTTPS")
                // 接口 PATH
                .setPathname("/")
                // 接口请求体内容格式
                .setReqBodyType("json")
                // 接口响应体内容格式
                .setBodyType("json");
        // runtime options
        java.util.Map<String, Object> queries = new java.util.HashMap<>();
        queries.put("InstanceId", aiAgentInstanceId);
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();

        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("stopAiAgent, instanceId:{}", aiAgentInstanceId);
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("stopAiAgent, response:{}", JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        log.info("stopAiAgent success. instanceId:{}, consume:{}ms", aiAgentInstanceId, (System.currentTimeMillis() - start));
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            log.error("stopAiAgent error. e:{}", e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateAiAgent(String aiAgentInstanceId, String templateConfig) {
        Params params = new Params()
                // 接口名称
                .setAction("UpdateAIAgentInstance")
                // 接口版本
                .setVersion("2020-11-09")
                // 接口协议
                .setProtocol("HTTPS")
                // 接口 HTTP 方法
                .setMethod("POST")
                .setAuthType("AK")
                .setStyle("HTTPS")
                // 接口 PATH
                .setPathname("/")
                // 接口请求体内容格式
                .setReqBodyType("json")
                // 接口响应体内容格式
                .setBodyType("json");
        // runtime options
        java.util.Map<String, Object> queries = new java.util.HashMap<>();
        queries.put("InstanceId", aiAgentInstanceId);
        queries.put("TemplateConfig", templateConfig);
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("updateAiAgent, aiAgentInstanceId:{}", aiAgentInstanceId);
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("updateAiAgent, response:{}", JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        log.info("updateAiAgent success. instanceId:{}, consume:{}ms", aiAgentInstanceId, (System.currentTimeMillis() - start));
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            log.error("updateRobot error. e:{}", e.getMessage());
        }
        return false;
    }

    @Override
    public GenerateAIAgentCallResponse generateAIAgentCall(String aiAgentId, String userId, Integer expire, String templateConfig, String workflowType) {
        Params params = new Params()
                // 接口名称
                .setAction("GenerateAIAgentCall")
                // 接口版本
                .setVersion("2020-11-09")
                // 接口协议
                .setProtocol("HTTPS")
                // 接口 HTTP 方法
                .setMethod("POST")
                .setAuthType("AK")
                .setStyle("HTTPS")
                // 接口 PATH
                .setPathname("/")
                // 接口请求体内容格式
                .setReqBodyType("json")
                // 接口响应体内容格式
                .setBodyType("json");

        if (StringUtils.isEmpty(aiAgentId)) {
            if (isAvatarChat3D(workflowType)) {
                aiAgentId = avatarChat3DAiAgentId;
            } else if (isVisionChat(workflowType)) {
                aiAgentId = visionChatAiAgentId;
            } else if (isVoiceChat(workflowType)) {
                aiAgentId = voiceChatAiAgentId;
            } else{
                throw new RuntimeException("workflowType is not support");
            }
        }

        // runtime options
        java.util.Map<String, Object> queries = new java.util.HashMap<>();
        queries.put("AIAgentId", aiAgentId);
        queries.put("Expire", expire);
        queries.put("UserId", userId);
        queries.put("TemplateConfig", templateConfig);
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("generateAIAgentCall, aIAgentId:{}", aiAgentId);
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("generateAIAgentCall, response:{}", JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        String channelId = (String) body.get("ChannelId");
                        String aIAgentUserId = (String) body.get("AIAgentUserId");
                        String aiAgentInstanceUserId = (String) body.get("InstanceId");
                        workflowType = (String) body.get("WorkflowType");
                        String token = (String) body.get("Token");

                        return GenerateAIAgentCallResponse.builder()
                                .aiAgentId(aiAgentId)
                                .aiAgentInstanceId(aiAgentInstanceUserId)
                                .aiAgentUserId(aIAgentUserId)
                                .channelId(channelId)
                                .rtcAuthToken(token)
                                .WorkflowType(workflowType)
                                .build();
                    }
                }
            }
        } catch (Exception e) {
            log.error("generateAIAgentCall error. e:{}", e.getMessage());
        }
        return null;
    }
}
