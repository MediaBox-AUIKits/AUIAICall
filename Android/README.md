# AUIAICall
阿里云 · AUI Kits AI智能体集成工具

## 介绍
AUI Kits AI智能体集成工具适用于网络客服、AI助理、撮合助手、数字人直播等多种应用场景，使用户能够在短时间内快速构建AI实时互动能力。


## 源码说明

### 源码下载
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/Android)

### 源码结构
```
├── Android       //Android平台工程结构跟目录
│   ├── AUIBaseKits    //AUI基础组件
│   ├── AUIAICall   //UI组件
│   ├── AUIAICallEngine //场景接口与实现
│   ├── README.md
│   ├── app           //Demo
│   ├── build.gradle  
│   └── settings.gradle

```

### 环境要求
- Android Studio 插件版本4.1.3
- Gradle 7.0.2
- Android Studio自带 jdk11

### 前提条件
需要创建智能体，并且在你的服务端上开发相关接口或直接部署提供的Server源码，详情参考官网文档


## 跑通demo
- 源码下载后，使用Android Studio打开Android目录
- 打开工程文件“build.gradle”，修改包Id
- 完成前提条件后，进入文件AppServiceConst.java，修改服务端域名
```java
// AppServiceConst.java
String HOST = "你的应用服务器域名";
```

## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
