# AUIAICall
阿里云 · AUI Kits AI智能体集成工具

## 介绍
AUI Kits AI智能体集成工具适用于网络客服、AI助理、撮合助手、数字人直播等多种应用场景，使用户能够在短时间内快速构建AI实时互动能力。


## 源码说明

### 源码下载
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/Harmony)

### 源码结构
```
├── Harmony  // Harmony平台的根目录
│   ├── AUIAICall                                    // Demo源代码
│   ├── README.md                                    // Readme  

```

### 环境要求
- 获取 DevEco Studio 5.0.3.900 Release 或以上版本。
- 获取配套 API Version 12 的 HarmonyOS NEXT SDK 或以上版本。
- 鸿蒙设备，配套 API Version 12的 HarmonyOS NEXT 5.0.0.102 操作系统或以上版本，且已开启“允许调试”选项。
- 已注册华为开发者账号并完成实名认证。

### 前提条件
开通及创建智能体，详情参考官网文档


## 跑通demo

- 源码下载后，使用DevEco Studio打开AUIAICall目录
- 配置智能体Id及所在的区域，进入文件`AgentConstants.ets`
```typescript
// AgentConstants.ets

// 配置智能体id 
static readonly AGENT_ID_VOICE: string = '你的语音通话智能体Id';
static readonly AGENT_ID_AVATAR: string = '你的数字人通话智能体Id';
static readonly AGENT_ID_VISION: string = '你的视觉理解通话智能体Id';
static readonly AGENT_ID_VIDEO: string = '你的视频通话智能体Id';
static readonly AGENT_ID_OUTBOUND: string = '你的电话呼出智能体Id';
static readonly AGENT_ID_INBOUND: string = '你的电话呼入智能体Id';

// 配置区域
static readonly AGENT_REGION: string = "智能体所在的区域，详情参考官网文档";
```

- 智能体的配置后，有2种方案来启动智能体
    * **方案1：** 如果你已经在你的服务端上部署了我们提供的AppServer源码，进入文件`AppServer.ets`，修改服务端域名
    ```typescript
    // AppServer.ets
      static readonly BASE_URL: string = '你的应用服务器域名';
    ```

    * **方案2：** 如果你无法部署AppServer源码，需要快速跑通Demo并体验智能体，那么可以参考下面方法，在App端生成启动鉴权Token方式
    > 注意：该方法需要在本地填写AppKey等敏感信息，仅适用于体验及开发阶段， **不能用于线上发布** ，避免被盗取AppKey造成安全事故。线上发布请使用Server下发Token方式，参考方案1
    
    针对通话智能体，找到`TokenHelper.ets`，打开`DEVELOP_MODE`，并从控制台拷贝智能体使用的RTCAppId及Key
    ```typescript
    // TokenHelper.ets
      // 开启开发模式的话，需要填入ARTC_APP_ID、ARTC_APP_KEY
      // NOTE: 开发模式不可以用于发布
      private static readonly DEVELOP_MODE: boolean = true;
      private static readonly ARTC_APP_ID: string = 'ARTC_APP_ID';
      private static readonly ARTC_APP_KEY: string = 'ARTC_APP_KEY';
    ```
    
- 为项目设置自动签名。
依次点击File -> Project Structure -> Signing Configs，在窗口中点击 Automatically generate signature。等待自动签名结束后，点击 OK 即可。
如果之前没有登录，请点击界面提示的Sign In使用您的华为账号登录。

- 连接真机，进行编译运行


## 常见问题
更多问题咨询及使用说明，请搜索钉钉群（106730016696）加入AI实时互动项目咨询群联系我们。
