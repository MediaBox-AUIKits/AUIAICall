# AUIAICall
阿里云 · AUI Kits AI智能体集成工具

## 介绍
AUI Kits AI智能体集成工具适用于网络客服、AI助理、撮合助手、数字人直播等多种应用场景，使用户能够在短时间内快速构建AI实时互动能力。


## 源码说明

### 源码下载
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/Android)

### 源码结构
```
├── Android       		//Android平台工程结构跟目录
│   ├── AUIBaseKits     //AUI基础组件
│   ├── AUIAICall       //UI组件
│   ├── AUIAICallEngine //场景基础接口与实现
│   ├── ARTCAICallKit   //场景全托管方案接口与实现
│   ├── README.md
│   ├── app             //Demo入口
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

## 快速开发自己的AI通话功能
可通过以下几个步骤快速集成AUIAICall到你的APP中，让你的APP具备语AI通话功能
### 集成源码
1. 导入AUIAICall：仓库代码下载后，Android Studio菜单选择: File -> New -> Import Module，导入选择文件夹。
2. 修改文件夹下的build.gradle的三方库依赖项。
``` Groovy
dependencies {
    implementation 'androidx.appcompat:appcompat:x.x.x'                     //修改x.x.x为你工程适配的版本
    implementation 'com.google.android.material:material:x.x.x'             //修改x.x.x为你工程适配的版本
    androidTestImplementation 'androidx.test.espresso:espresso-core:x.x.x'  //修改x.x.x为你工程适配的版本
    implementation 'com.aliyun.aio:AliVCSDK_Standard:x.x.x'                  //修改x.x.x为你工程适配的版本
    implementation 'com.aliyun.auikits.android:ARTCAICallKit:1.0.0'
}
```
3. 等待gradle同步完成，完成源码集成。

### 源码配置
- 完成前提条件后，进入文件AppServiceConst.java，修改服务端域名
```java
// AppServiceConst.java
String HOST = "你的应用服务器域名";
```

### 调用API
前面工作完成后，接下来可以根据自身的业务场景和交互，可以在你APP其他模块或主页上通过组件接口启动AI通话，也可以根据自身的需求修改源码。
```java
/** 启动之前保证麦克风、摄像头权限已授权 */

// 是否语音聊天：true则为语音智能体，false则为数字人
boolean isVoiceAgent = false;
// 智能体id，
String aiAgentId = "";
Context currentActivity = AUIAICallEntranceActivity.this;
Intent intent = new Intent(currentActivity, AUIAICallInCallActivity.class);

intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_AI_AGENT_TYPE, isVoiceAgent);
intent.putExtra(AUIAICallInCallActivity.BUNDLE_KEY_AI_AGENT_ID, aiAgentId);

currentActivity.startActivity(intent);
```

## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
