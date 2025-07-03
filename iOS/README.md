[English](README_English.md)

# AUIAICall
阿里云 · AUI Kits AI智能体集成工具

## 介绍
AUI Kits AI智能体集成工具适用于网络客服、AI助理、撮合助手、数字人直播等多种应用场景，使用户能够在短时间内快速构建AI实时互动能力。


## 源码说明

### 源码下载
下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/iOS)

### 源码结构
```
├── iOS  // iOS平台的根目录
│   ├── AUIAICall.podspec                // pod描述文件
│   ├── Source                                    // 源代码文件
│   ├── Resources                                 // 资源文件
│   ├── Example                                   // Demo代码
│   ├── AUIBaseKits                               // 基础UI组件 
│   ├── README.md                                 // Readme  

```

### 环境要求
- Xcode 16 及以上版本，推荐使用最新正式版本
- CocoaPods 1.9.3 及以上版本
- 准备 iOS 10.0 及以上版本的真机

### 前提条件
开通及创建智能体，详情参考官网文档


## 跑通demo

- 源码下载后，进入Example目录
- 在Example目录里执行命令“pod install  --repo-update”，自动安装依赖SDK
- 打开工程文件`AUIAICallExample.xcworkspace`，修改包Id
- 配置智能体Id及所在的区域，进入文件`AUIAICallAgentConfig.swift`
```swift
// AUIAICallAgentConfig.swift

// 配置智能体id 
let VoiceAgentId = "你的语音通话智能体Id"
let AvatarAgentId = "你的数字人通话智能体Id"
let VisionAgentId = "你的视觉理解通话智能体Id"
let VideoAgentId = "你的视频通话智能体Id"
let ChatAgentId = "你的消息对话智能体Id"

// 配置区域
let Region = "cn-shanghai"
```

- 智能体的配置后，有2种方案来启动智能体
    * **方案1：** 如果你已经在你的服务端上部署了我们提供的AppServer源码，进入文件`AUIAICallAppServer.swift`，修改服务端域名
    ```swift
    // AUIAICallAppServer.swift
    public let AICallServerDomain = "你的应用服务器域名"
    ```

    * **方案2：** 如果你无法部署AppServer源码，需要快速跑通Demo并体验智能体，那么可以参考下面方法，在App端生成启动鉴权Token方式
    > 注意：该方法需要在本地填写AppKey等敏感信息，仅适用于体验及开发阶段， **不能用于线上发布** ，避免被盗取AppKey造成安全事故。线上发布请使用Server下发Token方式，参考方案1
    
    针对通话智能体，找到`AUIAICallAuthTokenHelper.swift`，打开`EnableDevelopToken`，并从控制台拷贝智能体使用的RTCAppId及Key
    ```swift
    // AUIAICallAuthTokenHelper.swift
    @objcMembers public class AUIAICallAuthTokenHelper: NSObject {
    
        // 设置为true，启动Develop模式
        private static let EnableDevelopToken: Bool = true     
        // 从控制台拷贝RTCAppId
        private static let RTCDevelopAppId: String = "智能体使用的RTC的AppId"
        // 从控制台拷贝RTCAppKey
        private static let RTCDevelopAppKey: String = "智能体使用的RTC的AppKey"
    
        ...
    }
    ```
    
    针对消息对话智能体，找到`AUIAIChatAuthTokenHelper.swift`，打开`EnableDevelopToken`，并从控制台拷贝智能体使用的IMAppId、Key及Sign
    ```swift
    // AUIAIChatAuthTokenHelper.swift
    @objcMembers public class AUIAIChatAuthTokenHelper: NSObject {
    
        // 设置为true，启动Develop模式
        private static let EnableDevelopToken: Bool = true     
        // 从控制台拷贝的互动消息的AppId
        private static let IMDevelopAppId: String = "智能体使用的互动消息的AppId"
        // 从控制台拷贝互动消息的AppKey
        private static let IMDevelopAppKey: String = "智能体使用的互动消息的AppKey"
        // 从控制台拷贝互动消息的AppSign
        private static let IMDevelopAppSign: String = "智能体使用的互动消息的AppSign"
        ...
    }
    ```

- 选择”Example“Target 进行编译运行

## 快速开发自己的AI通话功能
可通过以下几个步骤快速集成AUIAICall到你的APP中，让你的APP具备语AI通话&消息对话功能

### 集成源码
- 导入AUIAICall：仓库代码下载后，拷贝iOS文件夹到你的APP代码目录下，改名为AUIAICall，与你的Podfile文件在同一层级，可以删除Example和AICallKit目录
- 修改你的Podfile，引入：
  * AliVCSDK_ARTC：适用于AI实时互动通话的音视频终端SDK，也可以使用：AliVCSDK_Standard或AliVCSDK_InteractiveLive，参考[快速集成](https://help.aliyun.com/document_detail/2412571.htm)
  * AliVCInteractionMessage：适用于消息对话的音互动消息SDK，如果你已经集成，请使用1.6.0版本及以上，参考[快速集成](https://help.aliyun.com/zh/live/user-guide/live-interactive-messages-new)
  * ARTCAICallKit：AI实时互动通话场景&消息对话场景的SDK
  * AUIFoundation：基础UI组件
  * AUIAICall：AI通话场景&消息对话场景的UI组件源码
```ruby

#需要iOS10.0及以上才能支持
platform :ios, '10.0'

target '你的App target' do
    # 根据自己的业务场景，集成合适的音视频终端SDK，支持：AliVCSDK_ARTC、AliVCSDK_Standard、AliVCSDK_InteractiveLive
    pod 'AliVCSDK_ARTC', '~> 7.3.0'

    # AI实时互动通话场景SDK
    # 如果你的业务还需要支持消息对话，则使用“ARTCAICallKit/Chatbot”进行集成，把下面一行改为：pod 'ARTCAICallKit/Chatbot', '~> 2.6.0'
    pod 'ARTCAICallKit', '~> 2.6.0'

    # 基础UI组件源码
    pod 'AUIFoundation', :path => "./AUIAICall/AUIBaseKits/AUIFoundation/", :modular_headers => true

    # AI通话场景UI组件源码
    # 如果你的业务还需要支持消息对话，则使用“AUIAICall/Chatbot”进行集成，把下面这一行改为：pod 'AUIAICall/Chatbot',  :path => "./AUIAICall/"
    pod 'AUIAICall',  :path => "./AUIAICall/"

    # 如果你的业务还需要支持消息对话，还需要集成AliVCInteractionMessage，版本最低是1.7.0
    pod 'AliVCInteractionMessage', '~> 1.8.0'

end
```
- 执行“pod install --repo-update”
- 源码集成完成

### 工程配置
- 打开工程info.Plist，添加麦克风权限，根据需要添加其他权限，例如摄像头权限（视觉理解/视频通话智能体会用到）、相册权限（消息对话多模态智能体会用到）。
- 打开工程设置，在”Signing & Capabilities“中开启“Background Modes”，如果不开启后台模式，则需要自行处理在进入后台时结束通话。


### 源码配置
- 完成前提条件后，进入文件`AUIAICallAppServer.swift`，修改服务端域名
```swift
// AUIAICallAppServer.swift
public let AICallServerDomain = "你的应用服务器域名"
```
> 在开发阶段可以使用App端生成鉴权Token方式，参考跑通Demo里的方案2

### 调用API
前面工作完成后，接下来可以根据自身的业务场景和交互，可以在你APP其他模块或主页上通过组件接口启动AI通话，也可以根据自身的需求修改源码。

- 启动AI通话
``` Swift

// 引入组件
import AUIAICall
import ARTCAICallKit
import AUIFoundation

// 检查是否开启麦克风权限，如果是视觉理解/视频通话智能体，还需要开启摄像头权限
AVDeviceAuth.checkMicAuth { auth in
    if auth == false {
        return
    }
    
    // userId推荐使用你的App登录后的用户id
    let userId = "xxx"
    // 通过userId构建controller
    let controller = AUIAICallController(userId: userId)
    // 设置智能体Id，不能为nil
    controller.config.agentId = "xxx"
    // 设置通话的类型（语音、数字人、视觉理解、视频通话），需要与AgentId的类型对应
    controller.config.agentType = agentType
    // agent所在的区域，不能为nil
    controller.config.region = "xx-xxx"
    // 创建通话ViewController
    let vc = AUIAICallViewController(controller)
    // 全屏方式打开通话界面
    vc.modalPresentationStyle = .fullScreen
    vc.modalTransitionStyle = .coverVertical
    vc.modalPresentationCapturesStatusBarAppearance = true
    self.present(vc, animated: true)
}

```

- 启动AI消息对话
``` Swift

// 引入组件
import AUIAICall
import ARTCAICallKit
import AUIFoundation

// userId推荐使用你的App登录后的用户id
let userId = "xxx"
// 设置deviceId
let deviceId = UIDevice.current.identifierForVendor?.uuidString
let userInfo = ARTCAIChatUserInfo(userId, deviceId)

// 设置智能体Id,不能为nil
let agentId = "xxxxx"
let agentInfo = ARTCAIChatAgentInfo(agentId: agentId)
// agent所在的区域，不能为nil
agentInfo.region = "xx-xxx"

// 创建消息对话的ViewController
let vc = AUIAIChatViewController(userInfo: userInfo, agentInfo: agentInfo)
// 打开通话界面
self.navigationController?.pushViewController(vc, animated: true)

```

### 通过控制台提供的Token快速启动AI通话（可选）
如果你来不及或者不会集成Server源码并部署服务端，那么可以通过这种方式来跑通创建的智能体，这种模式下仅限于测试与体验使用，不适用于上线。

- 前提条件：从控制台上获取启动通话的Token
  * 打开控制台，进入智能体管理
  * 找到自己的智能体，点击”Demo体验二维码“
  * 选择过期时间后，点击生成，点击体验Token”拷贝按钮“

- 下面代码可以启动一个智能体通话，可以把下面代码加入到你的按钮点击事件里
``` Swift

// 引入组件
import AUIAICall
import AUIFoundation

AUIAICallManager.defaultManager.checkDeviceAuth(agentType: .VisionAgent) {
    let topVC = viewController ?? UIViewController.av_top()
    let controller = AUIAICallStandardController(userId: "xxx")   // 参数为当前登录用户的UserId
    controller.agentShareInfo = "xxxxx"   // 从控制台上获取启动通话的Token
    let vc = AUIAICallViewController(controller)
    vc.enableVoiceIdSwitch = false
    topVC.av_presentFullScreenViewController(vc, animated: true)
}

```


## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
