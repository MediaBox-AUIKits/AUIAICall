package com.aliyuncs.aui.service.impl;

import com.alibaba.fastjson.JSONObject;
import com.aliyun.teaopenapi.Client;
import com.aliyun.teaopenapi.models.Config;
import com.aliyun.teaopenapi.models.OpenApiRequest;
import com.aliyun.teaopenapi.models.Params;
import com.aliyun.teautil.models.RuntimeOptions;
import com.aliyuncs.aui.service.AiRobotService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Map;

/**
 * AiRobotServiceImpl
 *
 * @author chunlei.zcl
 */
@Service
@Slf4j
public class AiRobotServiceImpl implements AiRobotService {

    private static Client client;

    @Value("${biz.ims.robot_id}")
    private String imsRobotId;

    @Value("${biz.ims.region}")
    private String imsRegion;

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
        //config.endpoint = "ice-pre.cn-hangzhou.aliyuncs.com";
        client = new Client(config);
    }

    @Override
    public String startRobot(String ChannelId, String userId, String rtcAuthToken, String config, String robotId) {

        Params params = new Params()
                // 接口名称
                .setAction("StartRtcRobotInstance")
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

        java.util.Map<String, Object> queries = new java.util.HashMap<>();
        if (StringUtils.isNotEmpty(robotId)) {
            queries.put("RobotId", robotId);
        } else {
            queries.put("RobotId", imsRobotId);
        }
        queries.put("ChannelId", ChannelId);

        //queries.put("WelcomeWords", "xx");
        if (StringUtils.isNotEmpty(config)) {
            queries.put("Config", config);
        }
        queries.put("AuthToken", rtcAuthToken);
        queries.put("UserId", userId);
        // 复制代码运行请自行打印 API 的返回值
        // 返回值为 Map 类型，可从 Map 中获得三类数据：响应体 body、响应头 headers、HTTP 返回的状态码 statusCode。
        RuntimeOptions runtime = new RuntimeOptions();
        try {
            OpenApiRequest request = new OpenApiRequest().setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            // 复制代码运行请自行打印 API 的返回值
            // 返回值为 Map 类型，可从 Map 中获得三类数据：响应体 body、响应头 headers、HTTP 返回的状态码 statusCode。
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("startRobot, queries：{}， response:{}", JSONObject.toJSONString(queries), JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        Map<String, Object> body = (Map<String, Object>) response.get("body");
                        String instanceId = (String) body.get("InstanceId");
                        log.info("StartRtcRobotInstance success. instanceId:{}, consume:{}ms", instanceId, (System.currentTimeMillis() - start));
                        return instanceId;
                    }
                }
            }
        } catch (Exception e) {
            log.error("startRobot error. e:{}", e.getMessage());
            throw new RuntimeException(e);
        }
        return null;
    }

    @Override
    public boolean stopRobot(String robotInstanceId) {

        Params params = new Params()
                // 接口名称
                .setAction("StopRtcRobotInstance")
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
        queries.put("InstanceId", robotInstanceId);
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();

        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("stopRobot, instanceId:{}, response:{}", robotInstanceId, JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        log.info("StopRtcRobotInstance success. instanceId:{}, consume:{}ms", robotInstanceId, (System.currentTimeMillis() - start));
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            log.error("stopRobot error. e:{}", e.getMessage());
        }
        return false;
    }

    @Override
    public boolean updateRobot(String robotInstanceId, String config) {

        Params params = new Params()
                // 接口名称
                .setAction("UpdateRtcRobotInstance")
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
        queries.put("InstanceId", robotInstanceId);
        queries.put("Config", config);
        com.aliyun.teautil.models.RuntimeOptions runtime = new com.aliyun.teautil.models.RuntimeOptions();

        try {
            com.aliyun.teaopenapi.models.OpenApiRequest request = new com.aliyun.teaopenapi.models.OpenApiRequest()
                    .setQuery(com.aliyun.openapiutil.Client.query(queries));
            long start = System.currentTimeMillis();
            Map<String, ?> response = client.callApi(params, request, runtime);
            log.info("updateRobot, robotInstanceId:{}, response:{}", robotInstanceId, JSONObject.toJSONString(response));
            if (response != null) {
                if (response.containsKey("statusCode")) {
                    Integer statusCode = (Integer)response.get("statusCode");
                    if (200 == statusCode) {
                        log.info("UpdateRtcRobotInstance success. instanceId:{}, consume:{}ms", robotInstanceId, (System.currentTimeMillis() - start));
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            log.error("updateRobot error. e:{}", e.getMessage());
        }
        return false;
    }
}
