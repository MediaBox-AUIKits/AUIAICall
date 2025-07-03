# AUIAICall

阿里云 · AUI Kits AI 智能体集成工具

## 介绍

AUI Kits AI 智能体集成工具适用于网络客服、AI 助理、撮合助手、数字人直播等多种应用场景，使用户能够在短时间内快速构建 AI 实时互动能力。

## 源码说明

### 源码下载

下载地址[请参见](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/Web)

### 源码结构

```
.
└── React
    ├── README.md
    ├── eslint.config.js
    ├── index.html     // 入口
    ├── package.json
    ├── src
    │   ├── view     // UI实现
    │   ├── common     // 公共业务方法
    │   ├── controller
    │   ├── interface.ts
    │   ├── runConfig.ts  // 运行时配置
    │   ├── service
    │   └── vite-env.d.ts
    ├── tsconfig.app.json
    ├── tsconfig.json
    └── vite.config.ts
```

### 前提条件

需要创建智能体，并且在你的服务端上开发相关接口或直接部署提供的 Server 源码，详情参考官网文档

## 跑通 demo

- 源码下载后，进入 React 目录
- 在 React 目录里执行命令 `npm install` ，自动安装依赖
- 打开文件 `src/runConfig.ts`，修改服务端域名和 AgentId (可以只修改会用到的智能体类型的 id)

```typescript
// src/runConfig.ts
const runConfig: AICallRunConfig = {
  appServer: '您的应用服务器地址',
  voiceAgentId: '您的语音通话智能体id',
  avatarAgentId: '您的数字人智能体id',
  visionAgentId: '您的视觉智能体id',
  chatAgentId: '您的消息通话智能体id',
};
```

- 根据业务情况，完善获取 UserId / Token（用于 AppServer 接口鉴权） 的逻辑
- 执行命令 `npm run dev` 启动本地服务
  - 访问 http://localhost:5173 即可查看 Demo

## 常见问题

更多 AUIKits 问题咨询及使用说明，请搜索钉钉群（35685013712）加入 AUI 客户支持群联系我们。
