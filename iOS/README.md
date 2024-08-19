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
- Xcode 14.0 及以上版本，推荐使用最新正式版本
- CocoaPods 1.9.3 及以上版本
- 准备 iOS 10.0 及以上版本的真机

### 前提条件
需要创建智能体，并且在你的服务端上开发相关接口或直接部署提供的Server源码，详情参考官网文档


## 跑通demo

- 源码下载后，进入Example目录
- 在Example目录里执行命令“pod install  --repo-update”，自动安装依赖SDK
- 打开工程文件“AUIAICallExample.xcworkspace”，修改包Id
- 完成前提条件后，进入文件ARTCAICallAppServer.swift，修改服务端域名
```swift
// ARTCAICallAppServer.swift
public class AUIAICallAppServer: NSObject {
    public static let AICallServerDomain = "你的应用服务器域名"
    ...
}
```

- 选择”Example“Target 进行编译运行


## 常见问题
更多AUIKits问题咨询及使用说明，请搜索钉钉群（35685013712）加入AUI客户支持群联系我们。
