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
You need to create an agent. For details, please refer to the official website documentation.

## Running the Demo
- After downloading the source code, navigate to the Example directory.
- Execute the command "pod install --repo-update" in the Example directory to automatically install the dependent SDKs.
- Open the project file "AUIAICallExample.xcworkspace" and modify the bundle ID.
- Configure the agent ID and its region by entering the file AUIAICallAgentConfig.swift.
```swift
// AUIAICallAgentConfig.swift

// Configure the agent ID 
let VoiceAgentId = "xxx"
let AvatarAgentId = "xxx"
let VisionAgentId = "xxx"
let VideoAgentId = "xxx"
let ChatAgentId = "xxx"

// Configure the region
let Region = "cn-shanghai"
```

- After configuring the agent, there are two methods to start the agent:
    * **Method 1:** If you have already deployed the provided AppServer source code on your server, go to the file `AUIAICallAppServer.swift` and modify the server domain name.
    ```swift
    // AUIAICallAppServer.swift
    public let AICallServerDomain = "Your application server domain"
    ```

    * **Method 2:** If you cannot deploy the AppServer source code and need to quickly run the demo and experience the agent, you can refer to the following method for generating a startup authentication token on the App side.
    > Note: This method requires entering sensitive information such as AppKey locally. It is only suitable for the trial and development phase, **not for online release**, to avoid security risks from stolen AppKeys. For online releases, use the Server-side token generation method (refer to Method 1).
    
    For the call agent, locate `AUIAICallAuthTokenHelper.swift`, enable `EnableDevelopToken`, and copy the RTC `AppId` and `Key` used by the agent from the console.
    ```swift
    // AUIAICallAuthTokenHelper.swift
    @objcMembers public class AUIAICallAuthTokenHelper: NSObject {
    
        // Set to true to enable Develop mode
        private static let EnableDevelopToken: Bool = true     
        // Copy the RTC AppId from the console
        private static let RTCDevelopAppId: String = "RTC AppId used by the agent"
        // Copy the RTC AppKey from the console
        private static let RTCDevelopAppKey: String = "RTC AppKey used by the agent"
    
        ...
    }
    ```
    
    For the messaging conversation agent, locate `AUIAIChatAuthTokenHelper.swift`, enable `EnableDevelopToken`, and copy the IM `AppId`, `Key`, and `Sign` used by the agent from the console.
    ```swift
    // AUIAIChatAuthTokenHelper.swift
    @objcMembers public class AUIAIChatAuthTokenHelper: NSObject {
    
        // Set to true to enable Develop mode
        private static let EnableDevelopToken: Bool = true     
        // Copy the interactive message AppId from the console
        private static let IMDevelopAppId: String = "Interactive message AppId used by the agent"
        // Copy the interactive message AppKey from the console
        private static let IMDevelopAppKey: String = "Interactive message AppKey used by the agent"
        // Copy the interactive message AppSign from the console
        private static let IMDevelopAppSign: String = "Interactive message AppSign used by the agent"
        ...
    }
    ```


- Select the "Example" Target for compilation and execution.

## Rapid Development of Your Own AI Call Functionality
You can quickly integrate AUIAICall into your APP through the following steps, enabling your APP to have AI call and message conversation functionality.

### Integrating Source Code
- Import AUIAICall: After downloading the repository code, copy the iOS folder to your APP code directory and rename it to AUIAICall, at the same level as your Podfile file. You can delete the Example and AICallKit directories.
- Modify your Podfile to include:
    * AliVCSDK_ARTC: Audio and video terminal SDK suitable for AI real-time interactive calls. You can also use AliVCSDK_Standard or AliVCSDK_InteractiveLive. 
    * AliVCInteractionMessage: Interactive messaging SDK suitable for message conversations.
    * ARTCAICallKit: SDK for AI real-time interactive call scenarios and message conversation scenarios.
    * AUIFoundation: Basic UI component.
    * AUIAICall: UI component source code for AI call scenarios and message conversation scenarios.
```ruby

# Requires iOS 10.0 or above
platform :ios, '10.0'

target 'Your App target' do
    # Integrate the appropriate audio and video terminal SDK based on your business scenario. Supports: AliVCSDK_ARTC, AliVCSDK_Standard, AliVCSDK_InteractiveLive
    pod 'AliVCSDK_ARTC', '~> 7.3.0'

    # AI real-time interactive call scenario SDK
    # If your business also needs to support message conversations, use "ARTCAICallKit/Chatbot" for integration, change the line below to: pod 'ARTCAICallKit/Chatbot', '~> 2.6.0'
    pod 'ARTCAICallKit', '~> 2.6.0'

    # Basic UI component source code
    pod 'AUIFoundation', :path => "./AUIAICall/AUIBaseKits/AUIFoundation/", :modular_headers => true

    # AI call scenario UI component source code
    # If your business also needs to support message conversations, use "AUIAICall/Chatbot" for integration, change the line below to: pod 'AUIAICall/Chatbot',  :path => "./AUIAICall/"
    pod 'AUIAICall',  :path => "./AUIAICall/"

    # If your business also needs to support message conversations, you also need to integrate AliVCInteractionMessage, minimum version is 1.7.0
    pod 'AliVCInteractionMessage', '~> 1.8.0'

end
```
- Execute "pod install --repo-update".
- Source code integration completed.


### Project Configuration
- Open the project's info.plist, add microphone permissions, and include other permissions as needed, such as camera permissions (used by the vision/video agent) and photo library permissions (used by the multi-modal messaging conversation agent).
- Open the project settings, enable "Background Modes" in "Signing & Capabilities". If background mode is not enabled, you need to handle ending the call when entering the background yourself.

### Source Code Configuration
- After completing the prerequisites, enter the file AUIAICallAppServer.swift and modify the server domain name.
```swift
// AUIAICallAppServer.swift
public let AICallServerDomain = "Your application server domain"
```
> During the development phase, you can use the method of generating authentication tokens on the App side. Refer to Method 2 above for guidance.




### Calling APIs
After completing the previous steps, you can start AI calls through component interfaces on other modules or the homepage of your APP according to your business scenario and interactions. You can also modify the source code according to your own needs.

- Start AI Call
```Swift

// Import components
import AUIAICall
import ARTCAICallKit
import AUIFoundation

// Check if microphone permission is enabled. Check the camera permission if using the vision or video agent.
AVDeviceAuth.checkMicAuth { auth in
    if auth == false {
        return
    }
    
    // userId is recommended to use your App's logged-in user id
    let userId = "xxx"
    let controller = AUIAICallController(userId: userId)

    controller.config.agentId = "xxx"
    controller.config.agentType = agentType
    controller.config.region = "xx-xxx"

    let vc = AUIAICallViewController(controller)

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
let userId = "xxx"
// Set deviceId
let deviceId = UIDevice.current.identifierForVendor?.uuidString
let userInfo = ARTCAIChatUserInfo(userId, deviceId)

let agentId = "xxxxx"
let region = "xx-xxx"
let agentInfo = ARTCAIChatAgentInfo(agentId: agentId)
agentInfo.region = region

let vc = AUIAIChatViewController(userInfo: userInfo, agentInfo: agentInfo)
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
    let controller = AUIAICallStandardController(userId: "xxx")   // Parameter is the UserId of the currently logged-in user
    controller.agentShareInfo = "xxxxx"   // Obtain the token to start the call from the console
    let vc = AUIAICallViewController(controller)
    vc.enableVoiceIdSwitch = false
    topVC.av_presentFullScreenViewController(vc, animated: true)
}
```

## Common Issues
For more AUIKits questions and usage instructions, search for DingTalk group (35685013712) to join the AUI customer support group and contact us.
