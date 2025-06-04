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

    private final Map<String, Client> clientByRegion = new ConcurrentHashMap<>();

    @Value("${biz.openapi.access.key}")
    private String accessKeyId;
    @Value("${biz.openapi.access.secret}")
    private String accessKeySecret;


    public Client getClient(String region) {
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
            log.info("generateMessageChatToken, queries:{}, region:{}", JSONObject.toJSONString(queries), region);
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
        } catch (NullPointerException e) {
            message = e.getMessage();
            log.error("generateMessageChatToken NullPointerException error, region:{}", region);
        } catch (Exception e) {
            message = e.getMessage();
            log.error("generateMessageChatToken error. e:{}", e.getMessage());
        }
        return GenerateMessageChatTokenResponse.builder().code(code).message(message).requestId(requestId).errorCode(errCode).build();
    }

    @Override
    public AiAgentInstanceDescribeResponse describeAiAgentInstance(String aiAgentInstanceId, String region) {
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
            Client localClient = getClient(region);
            long start = System.currentTimeMillis();
            log.info("describeAiAgentInstance, queries:{}, region:{}", JSONObject.toJSONString(queries), region);
            Map<String, ?> response = localClient.callApi(params, request, runtime);
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
        } catch (NullPointerException e) {
            message = e.getMessage();
            log.error("describeAiAgentInstance NullPointerException error, region:{}", region);
        } catch (Exception e) {
            message = e.getMessage();
            log.error("describeAiAgentInstance error. e:{}", e.getMessage());
        }
        return AiAgentInstanceDescribeResponse.builder().code(code).message(message).requestId(requestId).errorCode(errCode).build();

    }
}
