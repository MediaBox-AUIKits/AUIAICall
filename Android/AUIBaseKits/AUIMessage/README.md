# **AUIMessage**

## **一、模块介绍**

### **模块职责**

**AUIMessage**模块，为消息信令模块，主要负责对各个IM SDK的消息、信令的封装，一站式使用消息、信令。

## **二、前置条件**

**1、配置APP Server**

参考项目的README.md，或者AUIKits官网文档，完成服务端集成。

**2、按需申请使用IM SDK的相关配置**

* 如果使用融云的IM SDK（RongCloud），需要在[融云后台](https://www.rongcloud.cn/product/im)申请APP Key，并填写到项目中；

```java
interface RongCloudConsts {
    String APP_KEY = "xxx";
}
```

## **三、模块实现**

### **实现逻辑**

* **MessageService**：抽象统一了**AUIMessage**模块的对外接口，用户通过直接调用MessageService接口，即可屏蔽具体的实现逻辑。
* **MessageServiceImpl**：继承自抽象接口MessageService，对不同IM解决方案进行封装，为MessageService的核心实现。AUIMessage工程目录下，提供不同IM解决方案的实现模块，因此每个模块里面都有一个实现类MessageServiceImpl。

**注意：核心逻辑在MessageServiceImpl中。**

* **MessageServiceFactory**：由于模块实现了插件化，因此message service实例是通过反射进行实例化，即：

MessageService类，负责抽象出一套统一的对外接口；

```java
messageService = (MessageService) implType.newInstance();
```

MessageServiceFactory类，通过反射创建实例；

* **MessageUnImplListener**：由于不同IM解决方案的能力存在差异化，当该方案无法实现AUIMessage抽象接口的能力时，需要使用APPServer完成相应能力的实现，即：通过该回调到业务上层RoomService，再通过服务端接口的能力来实现。

* **AUIMessageServiceImplType**：该类中，定义了当前**AUIMessage**模块所有支持的IM解决方案，如下：

| Module Name              | 模块含义                | IM 类型                         |
| ------------------------ | ----------------------- | ------------------------------- |
| AUIMessageImpl-Internal  | 视频云互动消息SDK（旧） | 视频云互动消息SDK（旧）         |
| AUIMessageImpl-RongCloud | 融云IM实现              | 融云IM                          |
| AUIMessageImpl-AliVCIM   | 视频云互动消息SDK（新） | 视频云互动消息SDK（新）（推荐） |

**注意：不同IM解决方案，消息信令不互通。**

```java
public enum AUIMessageServiceImplType {

    /**
     * 阿里视频云旧版互动消息SDK
     *
     * @implNote 对应`AUIMessageImpl-Internal`模块
     */
    ALIVC(ALIVC_NAME, ALIVC_IMPL),

    /**
     * 阿里视频云新版互动消息SDK
     *
     * @implNote 对应`AUIMessageImpl-AliVCIM`模块
     */
    ALIVC_IM(ALIVC_IM_NAME, ALIVC_IM_IMPL),

    /**
     * 融云聊天室SDK
     *
     * @implNote 对应`AUIMessageImpl-RongCloud`模块
     */
    RC_CHAT_ROOM(RC_CHAT_ROOM_NAME, RC_CHAT_ROOM_IMPL),

    ;
}
```

**注意：**

* 如果MessageServiceImpl的包名被修改，请注意同步在代码中修改包名，否则在实例化失败，导致消息信令调用无效！
* 当前项目提供了基于不同IM SDK的模块实现，可以选其一使用，其它IM SDK的模块实现可以从项目中剔除；
* 当前项目中，通过BUILD_IM_TYPE编译配置，实现工程IM SDK类型的可配置，动态使用不同的IM SDK实现；

```groovy
// 定义BUILD IM TYPE，以决定使用哪种类型的IM方案，对应`AUIMessageServiceImplType`
//internal->内部IM
def BUILD_IM_TYPE_INTERNAL = "internal"
//rongcloud->融云IM
def BUILD_IM_TYPE_RONGCLOUD = "rongcloud"
//alivcim->ALIVC_IM
def BUILD_IM_TYPE_ALIVC_IM = "alivcim"

// 默认切换到Aliyun IM SDK v3.0
//ext.BUILD_IM_TYPE = getEnvValue("BUILD_IM_TYPE", BUILD_IM_TYPE_INTERNAL)
ext.BUILD_IM_TYPE = getEnvValue("BUILD_IM_TYPE", BUILD_IM_TYPE_ALIVC_IM)
```

### **依赖关系**

```groovy
dependencies {
    api project(':AUIBaseKits:AUIMessage')
  
    implementation '${each own im sdk dependencies}'
}
```

其它模块可直接依赖对应的IM SDK实现模块，无需直接引用到AUIMessage模块：

```groovy
// 切换消息SDK引擎
if (BUILD_IM_TYPE_INTERNAL.equals(BUILD_IM_TYPE)) {
    implementation project(':AUIBaseKits:AUIMessage:AUIMessageImpl-Internal')
} else if (BUILD_IM_TYPE_RONGCLOUD.equals(BUILD_IM_TYPE)) {
    implementation project(':AUIBaseKits:AUIMessage:AUIMessageImpl-RongCloud')
} else {
    implementation project(':AUIBaseKits:AUIMessage:AUIMessageImpl-AliVCIM')
}
```

### **可扩展**

MessageService为抽象化的消息服务接口类，客户可以基于该接口类，对接其它IM SDK，实现一套基于其它IM SDK的实现（参考MessageServiceImpl）。步骤如下：

* 在枚举AUIMessageServiceImplType里面，定义IM SDK类型，以及实现类的包路径；
* 定义IM解决方案的实现模块，基于MessageService接口完成相应实现；
* 通过implementation引入该IM解决方案的实现模块；
* 通过MessageServiceFactory完成反射实例化；

## 四、用户指引

### **文档**

[AUI Kits低代码应用方案](https://help.aliyun.com/document_detail/2391314.html)

[音视频终端SDK](https://help.aliyun.com/product/261167.html)

[融云IM](https://www.rongcloud.cn/product/im)

### **FAQ**

如果您在使用AUI Kits有任何问题或建议，欢迎通过钉钉搜索群号35685013712加入AUI客户支持群。

