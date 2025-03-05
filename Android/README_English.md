[中文](README.md)

# AUIAICall
Alibaba Cloud · AUI Kits AI Agent Integration Tool

## Introduction
The AUI Kits AI Agent Integration Tool is suitable for various application scenarios such as online customer service, AI assistants, matchmaking assistants, and digital human live streaming. It enables users to quickly build AI real-time interaction capabilities in a short period of time.

## Source Code Description

### Source Code Download
Download link: [Please refer to](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/Android)

### Source Code Structure
```
├── Android               // Root directory of the Android platform project structure
│   ├── AUIBaseKits     // AUI Basic Components
│   ├── AUIAICall       // UI Components
│   ├── README.md
│   ├── app             // Demo Entry Point
│   ├── build.gradle  
│   └── settings.gradle
```

### Environment Requirements
- Android Studio Plugin Version 4.1.3
- Gradle 7.0.2
- Android Studio bundled jdk11

### Prerequisites
You need to create an AI agent and develop relevant interfaces on your server or directly deploy the provided Server source code. For details, please refer to the official documentation.


## Running the Demo
- After downloading the source code, open the Android directory using Android Studio.
- Open the project file "build.gradle" and modify the package ID.
- After completing the prerequisites, go to the AppServiceConst.java file and modify the server domain name.
```java
// AppServiceConst.java
String HOST = "Your application server domain";
```
- Configure the message conversation agent ID and region. Go to the AUIAICallAgentIdConfig.java file, modify ChatBot_AGENT_ID to the agent ID generated in the console, and configure the Region.
```java
// AUIAICallAgentIdConfig.java
// Configure the message conversation agent ID
private static String ChatBot_AGENT_ID = "<Console Agent ID>";
// Configure the region
private static String Region = "cn-shanghai";
```

## Rapid Development of Your Own AI Call Functionality
You can quickly integrate AUIAICall into your APP through the following steps, enabling your APP with AI call functionality & message conversation capability.
### Integration of Source Code
1. Import AUIAICall: After downloading the repository code, select File -> New -> Import Module from the Android Studio menu, and choose the folder to import.
2. Modify the third-party library dependencies in the build.gradle file under the folder.
``` Groovy
dependencies {
    implementation 'androidx.appcompat:appcompat:x.x.x'                     // Modify x.x.x to the version compatible with your project
    implementation 'com.google.android.material:material:x.x.x'             // Modify x.x.x to the version compatible with your project
    androidTestImplementation 'androidx.test.espresso:espresso-core:x.x.x'  // Modify x.x.x to the version compatible with your project
    implementation 'com.aliyun.aio:AliVCSDK_ARTC:x.x.x'                  // Modify x.x.x to the version compatible with your project
    implementation 'com.aliyun.auikits.android:ARTCAICallKit:2.1.0'
    // If your business also needs to support message conversations, you also need to integrate AliVCInteractionMessage, with a minimum version of 1.5.0
    implementation 'com.aliyun.sdk.android:AliVCInteractionMessage:1.5.0'
}
```
3. Wait for gradle synchronization to complete, and finish the source code integration.

### Source Code Configuration
- After completing the prerequisites, go to the AppServiceConst.java file and modify the server domain name.
```java
// AppServiceConst.java
String HOST = "Your application server domain";
```
- Configure the message conversation agent ID and region. Go to the AUIAICallAgentIdConfig.java file, modify ChatBot_AGENT_ID to the agent ID generated in the console, and configure the Region.
```java
// AUIAICallAgentIdConfig.java
// Configure the message conversation agent ID
private static String ChatBot_AGENT_ID = "<Console Agent ID>";
// Configure the region
private static String Region = "cn-shanghai";
```

### Calling APIs
After completing the previous steps, you can start the AI call according to your own business scenarios and interactions. You can start the AI call through component interfaces on other modules or the main page of your APP, or modify the source code according to your needs.
- Start AI Call
```java
/** Ensure microphone and camera permissions are granted before starting */

// AI Agent Type
ARTCAICallEngine.ARTCAICallAgentType aiCallAgentType =
        ARTCAICallEngine.ARTCAICallAgentType.VoiceAgent;
// AI Agent ID
String aiAgentId = "";
Context currentActivity = AUIAICallEntranceActivity.this;
Intent intent = new Intent(currentActivity, AUIAICallInCallActivity.class);

// The user ID entering RTC; it is recommended to use the login user ID of your business
String userId = "123";
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, userId);
// AI Agent Type
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, aiCallAgentType);
// AI Agent ID
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, aiAgentId);

currentActivity.startActivity(intent);
```
- Start Message Conversation
```java
/** Ensure microphone and camera permissions are granted before starting */

// AI Agent Type
ARTCAICallEngine.ARTCAICallAgentType aiCallAgentType =
        ARTCAICallEngine.ARTCAICallAgentType.ChatBot;
// AI Agent ID; the agent ID must not be empty in message conversations
String aiAgentId = "XXXXXX";
Context currentActivity = AUIAICallEntranceActivity.this;
Intent intent = new Intent(currentActivity, AUIAIChatInChatActivity.class);

// The user ID entering the message conversation; it is recommended to use the login user ID of your business
String userId = "123";
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_LOGIN_USER_ID, userId);
// AI Agent Type
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_TYPE, aiCallAgentType);
// AI Agent ID
intent.putExtra(AUIAIConstStrKey.BUNDLE_KEY_AI_AGENT_ID, aiAgentId);

currentActivity.startActivity(intent);
```

### Quick Start of AI Calls Using Tokens Provided by the Console (Optional)
If you don't have time or don't know how to integrate the Server source code and deploy the server, you can use this method to test and experience the created agent. This mode is only for testing and experience purposes and is not suitable for production use.

- Prerequisite: Obtain the token for starting the call from the console.
  * Open the console and enter the agent management.
  * Find your agent and click "Demo Experience QR Code".
  * Select the expiration time, click generate, and then click the "Copy" button for the experience token.

- The following code can start an AI agent call and message conversation. You can add the following code to your button click event.
```java
/** Ensure microphone and camera permissions are granted before starting */

Context currentActivity = AUIAICallEntranceActivity.this;
// The user ID entering RTC; it is recommended to use the login user ID of your business
String loginUserId = "123";
// shareToken is the result obtained from scanning the QR code in step 1
String shareToken = "xxxxx";
ARTCAICallController.launchCallActivity(currentActivity, 
                                        shareToken, loginUserId, "");

```

## Common Issues
For more questions about AUIKits and usage instructions, please search for DingTalk group (35685013712) to join the AUI customer support group and contact us.
