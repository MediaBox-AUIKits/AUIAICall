[English](README_English.md)

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


## 跑通demo源码
- 源码下载后，使用Android Studio打开Android目录
- 打开工程文件“build.gradle”，修改包Id

- 配置音视频通话智能体及所在区域,进入AUIAICallAgentIdConfig.java文件，修改各类型智能体为控制台生成的智能体ID，修改Region配置区域
```java
// AUIAICallAgentIdConfig.java
// 你的语音通话智能体ID
private static String VOICE_AGENT_ID = "<控制台语音通话智能体ID>";
// 你的数字人通话智能体ID
private static String Avatar_AGENT_ID = "<控制台数字人通话智能体ID>";
// 你的视觉理解通话智能体ID
private static String VISION_AGENT_ID = "<控制台视觉理解通话智能体ID>";
// 你的视频通话智能体ID
private static String VIDEO_AGENT_ID = "<控制台视频通话智能体ID>";
//配置区域
private static String Region = "cn-shanghai";
```

- 配置消息对话智能体Id及所在区域,进入AUIAICallAgentIdConfig.java文件，修改ChatBot_AGENT_ID为控制台生成的智能体ID，修改Region配置区域
```java
// AUIAICallAgentIdConfig.java
// 配置消息对话智能体ID
private static String ChatBot_AGENT_ID = "<控制台智能体ID>";
//配置区域
private static String Region = "cn-shanghai";
```
- 智能体的配置后，有2种方案来启动智能体
  * **方案1：** 如果你已经在你的服务端上部署了我们提供的AppServer源码，进入文件`AppServiceConst.java`，修改服务端域名
  ```java
  // AppServiceConst.java
  String HOST = "你的应用服务器域名";
  ```

  * **方案2：** 如果你无法部署AppServer源码，需要快速跑通Demo并体验智能体，那么可以参考下面方法，在App端生成启动鉴权Token方式
  >   注意：该方法需要在本地填写AppKey等敏感信息，仅适用于体验及开发阶段， **不能用于线上发布** ，避免被盗取AppKey造成安全事故。线上发布请使用Server下发Token方式，参考方案1

  针对通话智能体，找到`AUIAICallAuthTokenHelper.java`，打开`EnableDevelopToken`，并从控制台拷贝智能体使用的RTCAppId及Key
  ```
  // AUIAICallAuthTokenHelper.java
  public class AUIAICallAuthTokenHelper {
    // 设置为true，启动Develop模式
    private static final boolean EnableDevelopToken = true;

    //从控制台拷贝音视频通话RTCAppId
    private static final String AICallRTCDevelopAppId = "智能体使用的RTC的AppId";
    // 从控制台拷贝音视频通话RTCAppKey
    private static final String AICallRTCDevelopAppKey = "智能体使用的RTC的AppKey";
  }
  ```
  
  针对消息对话智能体，找到`AUIAIChatAuthTokenHelper.java`，打开`EnableDevelopToken`，并从控制台拷贝智能体使用的IMAppId、Key及Sign
    ```
    // AUIAIChatAuthTokenHelper.java
    public class AUIAIChatAuthTokenHelper {

    // 设置为true，启动Develop模式
    private static final boolean EnableDevelopToken = true;

    //从控制台拷贝的互动消息的AppId
    private static final String AIChatIMDevelopAppId = "智能体使用的互动消息的AppId";
    //从控制台拷贝互动消息的AppKey
    private static final String AIChatIMDevelopAppKey = "智能体使用的互动消息的AppKey";
    //从控制台拷贝互动消息的AppKey
    private static final String AIChatIMDevelopAppSign = "智能体使用的互动消息的AppSign";
    }
    ```
- 运行App，即可体验AI智能体通话及消息对话功能

## 快速开发自己的AI通话功能
可通过以下几个步骤快速集成AUIAICall到你的APP中，让你的APP具备语AI通话功能&消息对话功能
### 集成源码
1. 导入AUIAICall：仓库代码下载后，Android Studio菜单选择: File -> New -> Import Module，导入选择文件夹。
2. 修改文件夹下的build.gradle的三方库依赖项。
``` Groovy
dependencies {
    implementation 'androidx.appcompat:appcompat:x.x.x'                     //修改x.x.x为你工程适配的版本
    implementation 'com.google.android.material:material:x.x.x'             //修改x.x.x为你工程适配的版本
    androidTestImplementation 'androidx.test.espresso:espresso-core:x.x.x'  //修改x.x.x为你工程适配的版本
    implementation 'com.aliyun.aio:AliVCSDK_ARTC:7.5.0'                  //修改x.x.x为你工程适配的版本
    implementation 'com.aliyun.auikits.android:ARTCAICallKit:2.8.0'
    implementation 'com.alivc.live.component:PluginAEC:1.0.0'
    //如果你的业务还需要支持消息对话，还需要集成AliVCInteractionMessage，版本最低是1.7.0
    implementation 'com.aliyun.sdk.android:AliVCInteractionMessage:1.7.0'
}
```
3. 等待gradle同步完成，完成源码集成。

### 源码配置
- 完成前提条件后，进入文件AppServiceConst.java，修改服务端域名
```java
// AppServiceConst.java
String HOST = "你的应用服务器域名";
```

- 配置音视频通话智能体及所在区域,进入AUIAICallAgentIdConfig.java文件，修改各类型智能体为控制台生成的智能体ID，修改Region配置区域
```java
// AUIAICallAgentIdConfig.java
// 你的语音通话智能体ID
private static String VOICE_AGENT_ID = "<控制台语音通话智能体ID>";
// 你的数字人通话智能体ID
private static String Avatar_AGENT_ID = "<控制台数字人通话智能体ID>";
// 你的视觉理解通话智能体ID
private static String VISION_AGENT_ID = "<控制台视觉理解通话智能体ID>";
// 你的视频通话智能体ID
private static String VIDEO_AGENT_ID = "<控制台视频通话智能体ID>";

//配置区域
private static String Region = "cn-shanghai";
```

- 配置消息对话智能体Id及所在区域,进入AUIAICallAgentIdConfig.java文件，修改ChatBot_AGENT_ID为控制台生成的智能体ID，修改Region配置区域
```java
// AUIAICallAgentIdConfig.java
// 配置消息对话智能体ID
private static String ChatBot_AGENT_ID = "<控制台智能体ID>";
//配置区域
private static String Region = "cn-shanghai";
```

### 调用API
前面工作完成后，接下来可以根据自身的业务场景和交互，可以在你APP其他模块或主页上通过组件接口启动AI通话，也可以根据自身的需求修改源码。
- 启动AI通话
```java
/** 启动之前保证麦克风、摄像头权限已授权 */

// 智能体类型
ARTCAICallEngine.ARTCAICallAgentType aiCallAgentType =
        ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
// 智能体ID
String aiAgentId = "";
Context currentActivity = AUIAICallEntranceActivity.this;
Intent intent = new Intent(currentActivity, AUIAICallInCallActivity.class);

// 进入rtc的用户id，建议使用业务的登录用户id
String userId = "123";
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, userId);
// 智能体类型
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, aiCallAgentType);
// 智能体ID
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, aiAgentId);

currentActivity.startActivity(intent);
```
- 启动消息对话
```java
/** 启动之前保证麦克风、摄像头权限已授权 */

// 智能体类型
ARTCAICallEngine.ARTCAICallAgentType aiCallAgentType =
        ARTCAICallEngine.ARTCAICallAgentType.ChatBot;
// 智能体ID,消息对话中智能体ID不能为空
String aiAgentId = "XXXXXX";
Context currentActivity = AUIAICallEntranceActivity.this;
Intent intent = new Intent(currentActivity, AUIAIChatInChatActivity.class);

// 进入消息对话的用户id，建议使用业务的登录用户id
String userId = "123";
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, userId);
// 智能体类型
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, aiCallAgentType);
// 智能体ID
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, aiAgentId);

currentActivity.startActivity(intent);
```

### 通过控制台提供的Token快速启动AI通话（可选）
如果你来不及或者不会集成Server源码并部署服务端，那么可以通过这种方式来跑通创建的智能体，这种模式下仅限于测试与体验使用，不适用于上线。

- 前提条件：从控制台上获取启动通话的Token
  * 打开控制台，进入智能体管理
  * 找到自己的智能体，点击”Demo体验二维码“
  * 选择过期时间后，点击生成，点击体验Token”拷贝按钮“

- 下面代码可以启动一个智能体通话及消息对话，可以把下面代码加入到你的按钮点击事件里
```java
/** 启动之前保证麦克风、摄像头权限已授权 */

Context currentActivity = AUIAICallEntranceActivity.this;
// 进入rtc的用户id，建议使用业务的登录用户id
String loginUserId = "123";
// shareToken是从步骤1中解二维码出来的结果
String shareToken = "xxxxx";
ARTCAICallController.launchCallActivity(currentActivity, 
                                        shareToken, loginUserId, "");

```

## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
