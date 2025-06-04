# aui-ims-robot 帮助文档

<p align="center" class="flex justify-center">
    <a href="https://www.serverless-devs.com" class="ml-1">
    <img src="http://editor.devsapp.cn/icon?package=start-springboot&type=packageType">
  </a>
  <a href="http://www.devsapp.cn/details.html?name=start-springboot" class="ml-1">
    <img src="http://editor.devsapp.cn/icon?package=start-springboot&type=packageVersion">
  </a>
  <a href="http://www.devsapp.cn/details.html?name=start-springboot" class="ml-1">
    <img src="http://editor.devsapp.cn/icon?package=start-springboot&type=packageDownload">
  </a>
</p>

<appdetail id="flushContent">

# 应用详情

- 关于技术选型
  - 基于主流的Java8 + Springboot2搭建框架
- 关于部署
  - 理论上只要安装了Java8即可运行在各个ECS或容器上

</appdetail>

# 工程配置说明
见下描述
```yaml
server:
  port: 8080

spring:
  jackson:
    time-zone: GMT+8
    date-format: yyyy-MM-dd'T'HH:mm:ss
    default-property-inclusion: non_null

biz:
  # 阿里云AK、SK，参考 https://help.aliyun.com/zh/ram/user-guide/create-an-accesskey-pair。 创建RAM用户时，最小权限为AliyunICEFullAccess
  openapi:
    # 调用generateMessageToken 获取chatBot token时需要配置
    # 调用describeAIAgentInstance 获取智能体信息时需要配置
    access:
      key: "*******"
      secret: "*******"

  # 实时音视频应用ID和AppKey，通话场景下需要配置
  live_mic:
    app_id: "*******"
    app_key: "*******"

# 配置允许跨域的请求域名
http:
  cors:
    host: "*"
```

# 打包&启动
以监听9000为示例，见下
```shell
#!/usr/bin/env bash

mvn package -DskipTests
cp target/*.jar target/webframework.jar
java -Dserver.port=9000 -jar target/webframework.jar
```


