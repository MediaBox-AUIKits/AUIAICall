[中文](README.md)

# AUIAICall
Alibaba Cloud · AUI Kits AI Agent Integration Tool

## Introduction
The AUI Kits AI Agent Integration Tool is suitable for various application scenarios such as online customer service, AI assistants, matchmaking assistants, and digital human live streaming. It enables users to quickly build AI real-time interaction capabilities in a short period of time.

## Source Code Description

### Source Code Download
Download [address](https://github.com/MediaBox-AUIKits/AUIAICall/tree/main/iOS)

### Source Code Structure
```
├── iOS  // Root directory for the iOS platform
│   ├── AUIAICall.podspec                // Pod description file
│   ├── Source                                    // Source code files
│   ├── Resources                                 // Resource files
│   ├── Example                                   // Demo code
│   ├── AUIBaseKits                               // Basic UI components 
│   ├── README.md                                 // Readme  
```

### Environment Requirements
- Xcode 16 or above, the latest official version is recommended
- CocoaPods 1.9.3 or above
- Prepare a real device with iOS 10.0 or above

### Prerequisites
You need to create an agent and develop relevant interfaces on your server or directly deploy the provided server source code. For details, please refer to the official website documentation.

## Running the Demo
- After downloading the source code, navigate to the Example directory.
- Execute the command "pod install --repo-update" in the Example directory to automatically install the dependent SDKs.
- Open the project file "AUIAICallExample.xcworkspace" and modify the bundle ID.
- After completing the prerequisites, go to the file AUIAICallAppServer.swift and modify the server domain name.
```swift
// AUIAICallAppServer.swift
public let AICallServerDomain = "Your application server domain"
```
- Configure the message conversation agent ID and its region by entering the file AUIAICallAgentConfig.swift.
```swift
// AUIAICallAgentConfig.swift

// Configure the agent ID 
let ChatAgentId = "Your message conversation agent ID"

// Configure the region
let Region = "cn-shanghai"
```

- Select the "Example" Target for compilation and execution.

## Rapid Development of Your Own AI Call Functionality
You can quickly integrate AUIAICall into your APP through the following steps, enabling your APP to have AI call and message conversation functionality.

### Integrating Source Code
- Import AUIAICall: After downloading the repository code, copy the iOS folder to your APP code directory and rename it to AUIAICall, at the same level as your Podfile file. You can delete the Example and AICallKit directories.
- Modify your Podfile to include:
    * AliVCSDK_ARTC: Audio and video terminal SDK suitable for AI real-time interactive calls. You can also use AliVCSDK_Standard or AliVCSDK_InteractiveLive. Refer to Quick Integration.
    * AliVCInteractionMessage: Interactive messaging SDK suitable for message conversations. If you have already integrated, please use version 1.5.0 or above. Refer to Quick Integration.
    * ARTCAICallKit: SDK for AI real-time interactive call scenarios and message conversation scenarios.
    * AUIFoundation: Basic UI component.
    * AUIAICall: UI component source code for AI call scenarios and message conversation scenarios.
```ruby

# Requires iOS 10.0 or above
platform :ios, '10.0'

target 'Your App target' do
    # Integrate the appropriate audio and video terminal SDK based on your business scenario. Supports: AliVCSDK_ARTC, AliVCSDK_Standard, AliVCSDK_InteractiveLive
    pod 'AliVCSDK_ARTC', '~> 6.21.0'

    # AI real-time interactive call scenario SDK
    # If your business also needs to support message conversations, use "ARTCAICallKit/Chatbot" for integration, change the line below to: pod 'ARTCAICallKit/Chatbot', '~> 2.1.0'
    pod 'ARTCAICallKit', '~> 2.1.0'

    # Basic UI component source code
    pod 'AUIFoundation', :path => "./AUIAICall/AUIBaseKits/AUIFoundation/", :modular_headers => true

    # AI call scenario UI component source code
    # If your business also needs to support message conversations, use "AUIAICall/Chatbot" for integration, change the line below to: pod 'AUIAICall/Chatbot',  :path => "./AUIAICall/"
    pod 'AUIAICall',  :path => "./AUIAICall/"

    # If your business also needs to support message conversations, you also need to integrate AliVCInteractionMessage, minimum version is 1.5.0
    pod 'AliVCInteractionMessage', '~> 1.5.0'

end
```
- Execute "pod install --repo-update".
- Source code integration completed.


### Project Configuration
- Open the project info.Plist and add NSMicrophoneUsageDescription permissions.
- Open the project settings, enable "Background Modes" in "Signing & Capabilities". If background mode is not enabled, you need to handle ending the call when entering the background yourself.

### Source Code Configuration
- After completing the prerequisites, enter the file AUIAICallAppServer.swift and modify the server domain name.
```swift
// AUIAICallAppServer.swift
public let AICallServerDomain = "Your application server domain"
```

### Calling APIs
After completing the previous steps, you can start AI calls through component interfaces on other modules or the homepage of your APP according to your business scenario and interactions. You can also modify the source code according to your own needs.

- Start AI Call
```Swift

// Import components
import AUIAICall
import ARTCAICallKit
import AUIFoundation

// Check if microphone permission is enabled
AVDeviceAuth.checkMicAuth { auth in
    if auth == false {
        return
    }
    
    // userId is recommended to use your App's logged-in user id
    let userId = "123"
    // Build controller with userId, it is recommended that userId be the currently logged-in user
    let controller = AUIAICallStandardController(userId: userId)
    // Set agent ID, if nil, the agent ID configured on AppServer will be used
    controller.config.agentId = nil
    // Set the type of call (voice, digital human, or visual understanding). If setting AgentId, it needs to correspond to the type of AgentId, otherwise appserver selects the corresponding agentId to start the call based on agentType
    controller.config.agentType = agentType
    // Create call ViewController
    let vc = AUIAICallViewController(controller)
    // Open the call interface in full screen mode
    vc.modalPresentationStyle = .fullScreen
    vc.modalTransitionStyle = .coverVertical
    vc.modalPresentationCapturesStatusBarAppearance = true
    self.present(vc, animated: true)
}
```

- Start AI Message Conversation
```Swift

// Import components
import AUIAICall
import ARTCAICallKit
import AUIFoundation

// userId is recommended to use your App's logged-in user id
let userId = "123"
// Set deviceId
let deviceId = UIDevice.current.identifierForVendor?.uuidString
let userInfo = ARTCAIChatUserInfo(userId, deviceId)

// Set agent, agentId cannot be nil, region is the area where the agent is located
let agentId = "xxxxx"
let region = "xx-xxx"
let agentInfo = ARTCAIChatAgentInfo(agentId: agentId)
agentInfo.region = region

// Create message conversation ViewController
let vc = AUIAIChatViewController(userInfo: userInfo, agentInfo: agentInfo)
// Open the call interface
self.navigationController?.pushViewController(vc, animated: true)
```

### Quickly Start AI Calls Using Tokens Provided by the Console (Optional)
If you don't have time or don't know how to integrate Server source code and deploy the server side, you can use this method to run the created agent. This mode is only for testing and experience purposes and is not suitable for going live.

- Prerequisites: Obtain the token to start the call from the console.
    * Open the console and enter agent management.
    * Find your agent and click "Demo Experience QR Code".
    * Select the expiration time and click generate, then click the copy button for the experience Token.
- The following code can start an agent call, you can add the following code to your button click event.

```Swift

// Import components
import AUIAICall
import AUIFoundation

AUIAICallManager.defaultManager.checkDeviceAuth(agentType: .VisionAgent) {
    let topVC = viewController ?? UIViewController.av_top()
    let controller = AUIAICallStandardController(userId: "123")   // Parameter is the UserId of the currently logged-in user
    controller.agentShareInfo = "xxxxx"   // Obtain the token to start the call from the console
    let vc = AUIAICallViewController(controller)
    vc.enableVoiceIdSwitch = false
    topVC.av_presentFullScreenViewController(vc, animated: true)
}
```

## Common Issues
For more AUIKits questions and usage instructions, search for DingTalk group (35685013712) to join the AUI customer support group and contact us.