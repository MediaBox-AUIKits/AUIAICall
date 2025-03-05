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
需要创建智能体，并且在你的服务端上开发相关接口或直接部署提供的Server源码，详情参考官网文档


## 跑通demo

- 源码下载后，进入Example目录
- 在Example目录里执行命令“pod install  --repo-update”，自动安装依赖SDK
- 打开工程文件“AUIAICallExample.xcworkspace”，修改包Id
- 完成前提条件后，进入文件AUIAICallAppServer.swift，修改服务端域名
```swift
// AUIAICallAppServer.swift
public let AICallServerDomain = "你的应用服务器域名"
```
- 配置消息对话智能体Id及所在的区域，进入文件AUIAICallAgentConfig.swift
```swift
// AUIAICallAgentConfig.swift

// 配置智能体id 
let ChatAgentId = "你的消息对话智能体Id"

// 配置区域
let Region = "cn-shanghai"
```
- 选择”Example“Target 进行编译运行

## 快速开发自己的AI通话功能
可通过以下几个步骤快速集成AUIAICall到你的APP中，让你的APP具备语AI通话&消息对话功能

### 集成源码
- 导入AUIAICall：仓库代码下载后，拷贝iOS文件夹到你的APP代码目录下，改名为AUIAICall，与你的Podfile文件在同一层级，可以删除Example和AICallKit目录
- 修改你的Podfile，引入：
  * AliVCSDK_ARTC：适用于AI实时互动通话的音视频终端SDK，也可以使用：AliVCSDK_Standard或AliVCSDK_InteractiveLive，参考[快速集成](https://help.aliyun.com/document_detail/2412571.htm)
  * AliVCInteractionMessage：适用于消息对话的音互动消息SDK，如果你已经集成，请使用1.5.0版本及以上，参考[快速集成](https://help.aliyun.com/zh/live/user-guide/live-interactive-messages-new)
  * ARTCAICallKit：AI实时互动通话场景&消息对话场景的SDK
  * AUIFoundation：基础UI组件
  * AUIAICall：AI通话场景&消息对话场景的UI组件源码
```ruby

#需要iOS10.0及以上才能支持
platform :ios, '10.0'

target '你的App target' do
    # 根据自己的业务场景，集成合适的音视频终端SDK，支持：AliVCSDK_ARTC、AliVCSDK_Standard、AliVCSDK_InteractiveLive
    pod 'AliVCSDK_ARTC', '~> 6.21.0'

    # AI实时互动通话场景SDK
    # 如果你的业务还需要支持消息对话，则使用“ARTCAICallKit/Chatbot”进行集成，把下面一行改为：pod 'ARTCAICallKit/Chatbot', '~> 2.1.0'
    pod 'ARTCAICallKit', '~> 2.1.0'

    # 基础UI组件源码
    pod 'AUIFoundation', :path => "./AUIAICall/AUIBaseKits/AUIFoundation/", :modular_headers => true

    # AI通话场景UI组件源码
    # 如果你的业务还需要支持消息对话，则使用“AUIAICall/Chatbot”进行集成，把下面这一行改为：pod 'AUIAICall/Chatbot',  :path => "./AUIAICall/"
    pod 'AUIAICall',  :path => "./AUIAICall/"

    # 如果你的业务还需要支持消息对话，还需要集成AliVCInteractionMessage，版本最低是1.5.0
    pod 'AliVCInteractionMessage', '~> 1.5.0'

end
```
- 执行“pod install --repo-update”
- 源码集成完成

### 工程配置
- 打开工程info.Plist，添加NSMicrophoneUsageDescription权限。
- 打开工程设置，在”Signing & Capabilities“中开启“Background Modes”，如果不开启后台模式，则需要自行处理在进入后台时结束通话。


### 源码配置
- 完成前提条件后，进入文件AUIAICallAppServer.swift，修改服务端域名
```swift
// AUIAICallAppServer.swift
public let AICallServerDomain = "你的应用服务器域名"
```

### 调用API
前面工作完成后，接下来可以根据自身的业务场景和交互，可以在你APP其他模块或主页上通过组件接口启动AI通话，也可以根据自身的需求修改源码。

- 启动AI通话
``` Swift

// 引入组件
import AUIAICall
import ARTCAICallKit
import AUIFoundation

// 检查是否开启麦克风权限
AVDeviceAuth.checkMicAuth { auth in
    if auth == false {
        return
    }
    
    // userId推荐使用你的App登录后的用户id
    let userId = "123"
    // 通过userId构建controller，建议userId为当前登录的用户
    let controller = AUIAICallStandardController(userId: userId)
    // 设置智能体Id，如果为nil，则使用在AppServer上配置的智能体id
    controller.config.agentId = nil
    // 设置通话的类型（语音、数字人或视觉理解），如果设置AgentId则需要与AgentId的类型对应，否则appserver根据agentType选择对应的agentId启动通话
    controller.config.agentType = agentType
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
let userId = "123"
// 设置deviceId
let deviceId = UIDevice.current.identifierForVendor?.uuidString
let userInfo = ARTCAIChatUserInfo(userId, deviceId)

// 设置智能体，智能体Id不能为nil，region是智能体所在的区域
let agentId = "xxxxx"
let region = "xx-xxx"
let agentInfo = ARTCAIChatAgentInfo(agentId: agentId)
agentInfo.region = region

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
    let controller = AUIAICallStandardController(userId: "123")   // 参数为当前登录用户的UserId
    controller.agentShareInfo = "xxxxx"   // 从控制台上获取启动通话的Token
    let vc = AUIAICallViewController(controller)
    vc.enableVoiceIdSwitch = false
    topVC.av_presentFullScreenViewController(vc, animated: true)
}

```


## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
