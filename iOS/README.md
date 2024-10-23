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
│   ├── AICallKit                                 // AICallKit组件（使用自定义实现） 
│   ├── README.md                                 // Readme  

```

### 环境要求
- Xcode 15.4 及以上版本，推荐使用最新正式版本
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

- 选择”Example“Target 进行编译运行

## 快速开发自己的AI通话功能
可通过以下几个步骤快速集成AUIAICall到你的APP中，让你的APP具备语AI通话功能

### 集成源码
- 导入AUIAICall：仓库代码下载后，拷贝iOS文件夹到你的APP代码目录下，改名为AUIAICall，与你的Podfile文件在同一层级，可以删除Example和AICallKit目录
- 修改你的Podfile，引入：
  - AliVCSDK_ARTC：适用于实时互动的音视频终端SDK，也可以使用：AliVCSDK_Standard或AliVCSDK_InteractiveLive，参考[快速集成](https://help.aliyun.com/document_detail/2412571.htm)
  - ARTCAICallKit：AI实时互动通话场景SDK
  - AUIFoundation：基础UI组件
  - AUIAICall：AI通话场景UI组件源码
```ruby

#需要iOS10.0及以上才能支持
platform :ios, '10.0'

target '你的App target' do
    # 根据自己的业务场景，集成合适的音视频终端SDK，支持：AliVCSDK_ARTC、AliVCSDK_Standard、AliVCSDK_InteractiveLive
    pod 'AliVCSDK_ARTC', '~> 6.11.3'

    # AI实时互动通话场景SDK
    pod "ARTCAICallKit", '~> 1.2.0'

    # 基础UI组件源码
    pod 'AUIFoundation', :path => "./AUIAICall/AUIBaseKits/AUIFoundation/", :modular_headers => true

    # AI通话场景UI组件源码
    pod 'AUIAICall',  :path => "./AUIAICall/"
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

``` Swift

// 引入组件
import AUIAICall
import AUIFoundation


// 检查是否开启麦克风权限
AVDeviceAuth.checkMicAuth { auth in
    if auth == false {
        return
    }
    
    // 通过userId构建controller
    let controller = AUIAICallStandardController(userId: userId)
    // 设置通话的类型（语音或数字人通话），appserver根据agentType选择对应的agentId启动通话
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


## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
