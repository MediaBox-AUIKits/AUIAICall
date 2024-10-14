# AUIAICall

阿里云 · AUI Kits AI 智能体集成工具

## 介绍

AUI Kits AI 智能体集成工具适用于网络客服、AI 助理、撮合助手、数字人直播等多种应用场景，使用户能够在短时间内快速构建 AI 实时互动能力。

## 源码说明

### 源码下载

下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/Web)

### 源码结构

```
├── Web                                             // Web平台的根目录
│   ├── React
│   │   ├── src                                       // Demo代码
│   │   ├── vite.config.ts                            // Vite 相关配置
│   │   ├── README.md                                 // Readme

```

### 前提条件

需要创建智能体，并且在你的服务端上开发相关接口或直接部署提供的 Server 源码，详情参考官网文档

## 跑通 demo

- 源码下载后，进入 React 目录
- 在 React 目录里执行命令 `npm intall` ，自动安装依赖
- 打开文件 src/controller/service/interface.ts，修改服务端域名

```typescript
// src/controller/service/interface.ts
export const APP_SERVER = '你的应用服务器域名';
```

- 根据业务情况，完善获取 UserId / Token（用于 AppServer 接口鉴权） 的逻辑
- 执行命令 `npm run dev` 启动本地服务

## 常见问题

更多 AUIKits 问题咨询及使用说明，请搜索钉钉群（35685013712）加入 AUI 客户支持群联系我们。
