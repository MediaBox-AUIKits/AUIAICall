package com.aliyuncs.aui.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.aliyun.tea.TeaException;
import com.aliyun.teaopenapi.Client;
import com.aliyun.teaopenapi.models.Config;
import com.aliyun.teaopenapi.models.OpenApiRequest;
import com.aliyun.teaopenapi.models.Params;
import com.aliyun.teautil.models.RuntimeOptions;
import com.aliyuncs.aui.dto.req.GenerateMessageChatTokenRequestDto;
import com.aliyuncs.aui.dto.res.*;
import com.aliyuncs.aui.service.AiAgentService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * AiAgentServiceImpl
 *
 * @author chunlei.zcl
 */
@Service
@Slf4j
public class AiAgentServiceImpl implements AiAgentService {

    private static Client client;

    private final Map<String, Client> clientByRegion = new ConcurrentHashMap<>();

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
    public AiAgentStartResponse startAiAgent(String ChannelId, String userId, String rtcAuthToken, String templateConfig, String workflowType, String userData, String sessionId, String chatSyncConfig, String aiAgentId, String region) {
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
        if (StringUtils.isEmpty(aiAgentId)) {
            if (isAvatarChat3D(workflowType)) {
                queries.put("AIAgentId", avatarChat3DAiAgentId);
            } else if (isVoiceChat(workflowType)) {
                queries.put("AIAgentId", voiceChatAiAgentId);
            } else if (isVisionChat(workflowType)) {
                queries.put("AIAgentId", visionChatAiAgentId);
            } else {
                String errMessage = String.format("workflowType %s is not support", workflowType);
                return AiAgentStartResponse.builder().result(false).requestId("").message(errMessage).build();
            }
        } else {
            queries.put("AIAgentId", aiAgentId);
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
            String errMessage = String.format("workflowType %s is not support", workflowType);
            return AiAgentStartResponse.builder().result(false).requestId("").message(errMessage).build();
        }
        queries.put("RuntimeConfig", runtimeConfig.toJSONString());

        if (StringUtils.isNotEmpty(templateConfig)) {
            queries.put("TemplateConfig", templateConfig);
        }
        if (StringUtils.isNotEmpty(userData)) {
            queries.put("UserData", userData);
        }
        if(StringUtils.isNotEmpty(sessionId)) {
            queries.put("SessionId", sessionId);
        }
        if(StringUtils.isNotEmpty(chatSyncConfig)) {
            queries.put("ChatSyncConfig", chatSyncConfig);
        }
        RuntimeOptions runtime = new RuntimeOptions();
        String requestId = StringUtils.EMPTY;
        String message = StringUtils.EMPTY;
        int code = 500;
        String errCode = StringUtils.EMPTY;
        try {
            OpenApiRequest request = new OpenApiRequest().setQuery(com.aliyun.openapiutil.Client.query(queries));
            Client localClient = getClient(region);
            long start = System.currentTimeMillis();
            log.info("startAiAgent, queries：{}", JSONObject.toJSONString(queries));
            // 复制代码运行请自行打印 API 的返回值
            // 返回值为 Map 类型，可从 Map 中获得三类数据：响应体 body、响应头 headers、HTTP 返回的状态码 statusCode。
            Map<String, ?> response = localClient.callApi(params, request, runtime);
            log.info("startAiAgent, response:{}, cost:{}ms", JSONObject.toJSONString(response), (System.currentTimeMillis() - start));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer) response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        String instanceId = (String) body.get("InstanceId");
                        requestId = (String) body.get("RequestId");
                        log.info("startAiAgent success. instanceId:{}, consume:{}ms", instanceId, (System.currentTimeMillis() - start));
                        return AiAgentStartResponse.builder().aiAgentInstanceId(instanceId).requestId(requestId).result(true).code(200).build();
                    }
                }
            }
        } catch (TeaException e) {
            log.error("startAiAgent Tea error. e:{}", e.getMessage());
            requestId = e.getData().get("RequestId").toString();
            code = e.getStatusCode();
            errCode = e.getCode();
            message = e.getMessage();
            return AiAgentStartResponse.builder().result(false).code(code).errorCode(errCode).requestId(requestId).message(message).build();
        } catch (Exception e) {
            log.error("startAiAgent error. e:{}", e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
        return AiAgentStartResponse.builder().result(false).code(code).message(message).build();
    }

    private static boolean isAvatarChat3D(String workflowType) {
        boolean isAvatarChat3D = "AvatarChat3D".equalsIgnoreCase(workflowType);
        return isAvatarChat3D;
    }

    private static boolean isVoiceChat(String workflowType) {
        return "VoiceChat".equalsIgnoreCase(workflowType);
    }

    private static boolean isVisionChat(String workflowType) {
        return "VisionChat".equalsIgnoreCase(workflowType);
    }

    @Override
    public CommonResponse stopAiAgent(String aiAgentInstanceId) {
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

        String requestId = StringUtils.EMPTY;
        String message = StringUtils.EMPTY;
        String errCode = StringUtils.EMPTY;
        int code = 500;
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("stopAiAgent, queries:{}", JSONObject.toJSONString(queries));
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("stopAiAgent, response:{}, cost:{}ms", JSONObject.toJSONString(response), (System.currentTimeMillis() - start));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer) response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        requestId = (String) body.get("RequestId");
                        log.info("stopAiAgent success. instanceId:{}, consume:{}ms", aiAgentInstanceId, (System.currentTimeMillis() - start));
                        return CommonResponse.builder().result(true).code(200).requestId(requestId).build();
                    }
                }
            }
        } catch (TeaException e) {
            log.error("stopAiAgent Tea error. e:{}", e.getMessage());
            requestId = e.getData().get("RequestId").toString();
            message = e.getMessage();
            code = e.getStatusCode();
            errCode = e.getCode();
            return CommonResponse.builder().result(false).requestId(requestId).message(message).code(code).errorCode(errCode).build();
        } catch (Exception e) {
            log.error("stopAiAgent error. e:{}", e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
        return CommonResponse.builder().result(false).message(message).code(code).build();
    }

    @Override
    public CommonResponse updateAiAgent(String aiAgentInstanceId, String templateConfig) {
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

        String requestId = StringUtils.EMPTY;
        String message = StringUtils.EMPTY;
        String errCode = StringUtils.EMPTY;
        int code = 500;
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("updateAiAgent, queries:{}", JSONObject.toJSONString(queries));
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("updateAiAgent, response:{}, cost:{}ms", JSONObject.toJSONString(response), (System.currentTimeMillis() - start));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer) response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        requestId = (String) body.get("RequestId");
                        log.info("updateAiAgent success. instanceId:{}, consume:{}ms", aiAgentInstanceId, (System.currentTimeMillis() - start));
                        return CommonResponse.builder().result(true).requestId(requestId).code(200).build();
                    }
                }
            }
        } catch (TeaException e) {
            log.error("updateRobot Tea error. e:{}", e.getMessage());
            requestId = e.getData().get("RequestId").toString();
            code = e.getStatusCode();
            errCode = e.getCode();
            message = e.getMessage();
        } catch (Exception e) {
            log.error("updateRobot error. e:{}", e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
        return CommonResponse.builder().result(false).requestId(requestId).message(message).code(code).errorCode(errCode).build();
    }

    @Override
    public GenerateAIAgentCallResponse generateAIAgentCall(String aiAgentId, String userId, Integer expire, String templateConfig, String workflowType, String region, String userData, String sessionId, String chatSyncConfig) {
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
            } else {
                String errMessage = String.format("workflowType %s is not support", workflowType);
                return GenerateAIAgentCallResponse.builder().result(false).requestId("").message(errMessage).build();
            }
        }

        // runtime options
        java.util.Map<String, Object> queries = new java.util.HashMap<>();
        queries.put("AIAgentId", aiAgentId);
        queries.put("Expire", expire);
        queries.put("UserId", userId);
        queries.put("TemplateConfig", templateConfig);
        if (StringUtils.isNotEmpty(userData)) {
            queries.put("UserData", userData);
        }
        if(StringUtils.isNotEmpty(sessionId)) {
            queries.put("SessionId", sessionId);
        }
        if(StringUtils.isNotEmpty(chatSyncConfig)) {
            queries.put("ChatSyncConfig", chatSyncConfig);
        }
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();
        String requestId = StringUtils.EMPTY;
        String message = StringUtils.EMPTY;
        String errCode = StringUtils.EMPTY;
        int code = 500;
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            Client localClient = getClient(region);
            long start = System.currentTimeMillis();
            log.info("generateAIAgentCall, queries:{}, region:{}", JSONObject.toJSONString(queries), region);
            Map<String, ?> response = localClient.callApi(params, request, runtime);
            log.info("generateAIAgentCall, response:{}, cost:{}ms", JSONObject.toJSONString(response), (System.currentTimeMillis() - start));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer) response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        String channelId = (String) body.get("ChannelId");
                        String aIAgentUserId = (String) body.get("AIAgentUserId");
                        String aiAgentInstanceUserId = (String) body.get("InstanceId");
                        workflowType = (String) body.get("WorkflowType");
                        String token = (String) body.get("Token");
                        requestId = (String) body.get("RequestId");

                        return GenerateAIAgentCallResponse.builder()
                                .aiAgentId(aiAgentId)
                                .aiAgentInstanceId(aiAgentInstanceUserId)
                                .aiAgentUserId(aIAgentUserId)
                                .channelId(channelId)
                                .rtcAuthToken(token)
                                .WorkflowType(workflowType)
                                .requestId(requestId)
                                .code(200)
                                .result(true)
                                .build();
                    }
                }
            }
        } catch (TeaException e) {
            log.error("generateAIAgentCall Tea error. e:{}", e.getMessage());
            requestId = e.getData().get("RequestId").toString();
            message = e.getMessage();
            code = e.getStatusCode();
            errCode = e.getCode();
        } catch (Exception e) {
            log.error("generateAIAgentCall error. e:{}", e.getMessage());
            throw new RuntimeException(e.getMessage());
        }
        return GenerateAIAgentCallResponse.builder().result(false).code(code).errorCode(errCode).requestId(requestId).message(message).build();
    }

    public Client getClient(String region) {
        // 如果区域为空或空白，设置默认区域为 imsRegion
        if (StringUtils.isBlank(region)) {
            region = imsRegion;
        }
        if (clientByRegion.containsKey(region)) {
            return clientByRegion.get(region);
        }
        // 使用 computeIfAbsent 方法在并发环境下安全地获取或创建 Client
        return clientByRegion.computeIfAbsent(region, this::createClient);
    }

    private Client createClient(String region) {
        try {
            Config config = new Config()
                    // 您的 AccessKey ID
                    .setAccessKeyId(accessKeyId)
                    // 您的 AccessKey Secret
                    .setAccessKeySecret(accessKeySecret);
            // 访问的域名
            config.endpoint = String.format("ice.%s.aliyuncs.com", region);
            return new Client(config);
        } catch (Exception e) {
            log.error("createClient error. e:{}", e.getMessage());
            throw new RuntimeException(e);
        }
    }

    @Override
    public AiAgentInstanceDescribeResponse describeAiAgentInstance(String aiAgentInstanceId) {
        Params params = new Params()
                // 接口名称
                .setAction("DescribeAIAgentInstance")
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
        String requestId = StringUtils.EMPTY;
        String message = StringUtils.EMPTY;
        String errCode = StringUtils.EMPTY;
        int code = 500;
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            log.info("describeAiAgentInstance, queries:{}", JSONObject.toJSONString(queries));
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("describeAiAgentInstance, response:{}, cost:{}ms", JSONObject.toJSONString(response), (System.currentTimeMillis() - start));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer) response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        Map<String, Object> instance = (Map<String, Object>) body.get("Instance");

                        String callLogUrl = (String) instance.get("CallLogUrl");
                        String runtimeConfig = JSONObject.toJSONString(instance.get("RuntimeConfig"));
                        String status = (String) instance.get("Status");
                        String template_config = JSONObject.toJSONString(instance.get("TemplateConfig"));
                        String user_data = (String) instance.get("UserData");
                        requestId = (String) body.get("RequestId");

                        return AiAgentInstanceDescribeResponse.builder()
                                .callLogUrl(callLogUrl)
                                .runtimeConfig(runtimeConfig)
                                .status(status)
                                .templateConfig(template_config)
                                .userData(user_data)
                                .code(200)
                                .message("success")
                                .requestId(requestId)
                                .build();
                    }
                }
            }
        } catch (TeaException e) {
            log.error("describeAiAgentInstance Tea error. e:{}", e.getMessage());
            requestId = e.getData().get("RequestId").toString();
            message = e.getMessage();
            code = e.getStatusCode();
            errCode = e.getCode();
        } catch (Exception e) {
            message = e.getMessage();
            log.error("describeAiAgentInstance error. e:{}", e.getMessage());
        }
        return AiAgentInstanceDescribeResponse.builder().code(code).message(message).requestId(requestId).errorCode(errCode).build();

    }

    @Override
    public GenerateMessageChatTokenResponse generateMessageChatToken(String aiAgentId, String role, String userId, Integer expire, String region) {
        Params params = new Params()
                // 接口名称
                .setAction("GenerateMessageChatToken")
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
        queries.put("AIAgentId", aiAgentId);
        queries.put("Role", role);
        queries.put("UserId", userId);
        queries.put("Expire", expire);
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();
        String requestId = StringUtils.EMPTY;
        String message = StringUtils.EMPTY;
        String errCode = StringUtils.EMPTY;

        int code = 500;
        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            Client localClient = getClient(region);
            long start = System.currentTimeMillis();
            log.info("generateMessageChatToken, queries:{}", JSONObject.toJSONString(queries));
            Map<String, ?> response = localClient.callApi(params, request, runtime);
            log.info("generateMessageChatToken, response:{}, cost:{}ms", JSONObject.toJSONString(response), (System.currentTimeMillis() - start));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer) response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        String appId = (String) body.get("AppId");
                        String token = (String) body.get("Token");
                        String userIdResponse = (String) body.get("UserId");
                        String nonce = (String) body.get("Nonce");
                        String roleResponse = (String) body.get("Role");
                        long timestamp = (Long) body.get("TimeStamp");
                        String appSign = (String) body.get("AppSign");

                        requestId = (String) body.get("RequestId");

                        return GenerateMessageChatTokenResponse.builder()
                                .appId(appId)
                                .token(token)
                                .userId(userIdResponse)
                                .nonce(nonce)
                                .role(roleResponse)
                                .timestamp(timestamp)
                                .appSign(appSign)
                                .code(200)
                                .message("success")
                                .requestId(requestId)
                                .build();
                    }
                }
            }
        } catch (TeaException e) {
            log.error("generateMessageChatToken Tea error. e:{}", e.getMessage());
            requestId = e.getData().get("RequestId").toString();
            message = e.getMessage();
            code = e.getStatusCode();
            errCode = e.getCode();
        } catch (Exception e) {
            message = e.getMessage();
            log.error("generateMessageChatToken error. e:{}", e.getMessage());
        }
        return GenerateMessageChatTokenResponse.builder().code(code).message(message).requestId(requestId).errorCode(errCode).build();
    }
}
