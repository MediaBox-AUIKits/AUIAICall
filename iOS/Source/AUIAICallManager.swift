//
//  AUIAICallManager.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallManager: NSObject {
    
    public static let defaultManager = AUIAICallManager()
    
    public override init() {
        super.init()
    }
    
    public var userId: String? = nil
    public var userToken: String? = nil {
        didSet {
            AUIAICallAppServer.serverAuth = self.userToken
        }
    }
    
    public var voiceprintId: String? {
        get {
            return self.userId
        }
    }
    
    public var onUserTokenExpiredBlcok: (()->Void)? = nil
    
    public func checkDeviceAuth(agentType: ARTCAICallAgentType, success: @escaping () -> Void) {
        
        AVDeviceAuth.checkMicAuth { micAuth in
            if micAuth {
                if agentType == .VisionAgent {
                    AVDeviceAuth.checkCameraAuth { cameraAuth in
                        if cameraAuth {
                            success()
                        }
                    }
                }
                else {
                    success()
                }
            }
        }
    }
    
    private func getDefaultTemplateConfig() -> ARTCAICallTemplateConfig {
        let templateConfig = ARTCAICallTemplateConfig()
        templateConfig.voiceprintId = self.voiceprintId
        templateConfig.useVoiceprint = true
        return templateConfig
    }
    
#if !DEMO_FOR_DEBUG
    // 通过分享智能体Token，发起通话
    open func startCall(agentShareInfo: String, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        self.startCallWithStandard(agentShareInfo: agentShareInfo, viewController: viewController)
    }

    // 通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        self.startCallWithStandard(agentType: agentType, agentId: agentId, region: region, limitSecond: limitSecond, viewController: viewController)
    }
    
    // 全托管方式发起通话，通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    private func startCallWithStandard(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        self.checkDeviceAuth(agentType: agentType) { [weak self] in
            guard let self = self else {return}
            
            let topVC = viewController ?? UIViewController.av_top()
            // userId推荐使用你的App登录后的用户id
            let userId = self.userId!
            let controller = AUIAICallStandardController(userId: userId)
            
            // 设置智能体Id，如果为nil，则使用在AppServer上配置的智能体id
            controller.config.agentId = agentId ?? AUIAICallAgentConfig.shared.getAgentID(agentType: agentType)
            // 设置通话的类型（语音、数字人或视觉理解），如果设置AgentId则需要与AgentId的类型对应，否则appserver根据agentType选择对应的agentId启动通话
            controller.config.agentType = agentType
            // 通话配置
            controller.config.templateConfig = self.getDefaultTemplateConfig()
            // agent所在的区域
            controller.config.region = region
            // 通话时长限制，如无限制则无需设置
            controller.config.limitSecond = limitSecond
            
            // 创建通话ViewController
            let vc = AUIAICallViewController(controller)
            // AppServer的Token失效回调
            vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
            
            // 全屏方式打开通话界面
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
    
    private func startCallWithStandard(agentShareInfo: String, viewController: UIViewController? = nil) {
        
        self.checkDeviceAuth(agentType: .VisionAgent) { [weak self] in
            guard let self = self else {return}
            
            let topVC = viewController ?? UIViewController.av_top()
            let controller = AUIAICallStandardController(userId: self.userId!)
            controller.agentShareInfo = agentShareInfo
            let vc = AUIAICallViewController(controller)
            vc.enableVoiceprintSwitch = false
            vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
    
    // 通过指定智能体Id，发起通话
    open func startChat(agentId: String?, viewController: UIViewController? = nil) {
        
#if AICALL_ENABLE_CHATBOT
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        let topVC = viewController ?? UIViewController.av_top()
        // userId推荐使用你的App登录后的用户id
        let userId = self.userId!
        // 设置deviceId
        let deviceId = UIDevice.current.identifierForVendor?.uuidString
        let userInfo = ARTCAIChatUserInfo(userId, deviceId)
        
        // 设置智能体，智能体Id不能为nil
        let agentInfo = ARTCAIChatAgentInfo(agentId: agentId ?? AUIAICallAgentConfig.shared.getChatAgentId())
        
        // 创建消息对话的ViewController
        let vc = AUIAIChatViewController(userInfo: userInfo, agentInfo: agentInfo)
        // AppServer的Token失效回调
        vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
        // 打开通话界面
        topVC.navigationController?.pushViewController(vc, animated: true)
#endif  // define AICALL_ENABLE_CHATBOT
    }
    
    // 通过分享智能体Token，发起消息对话
    open func startChat(agentShareInfo: String, viewController: UIViewController? = nil) {
#if AICALL_ENABLE_CHATBOT
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        let topVC = viewController ?? UIViewController.av_top()
        let userInfo = ARTCAIChatUserInfo(self.userId!, UIDevice.current.identifierForVendor?.uuidString)
        let vc = AUIAIChatViewController(userInfo: userInfo, shareInfo: agentShareInfo)
        vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
        topVC.navigationController?.pushViewController(vc, animated: true)
#endif  // define AICALL_ENABLE_CHATBOT
    }
    
    
#endif  // undefine DEMO_FOR_DEBUG
}





#if DEMO_FOR_DEBUG
extension AUIAICallManager {
    
    // 通过分享智能体Token，发起通话
    open func startCall(agentShareInfo: String, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AUIAICallDebugManager.shared.startCall(agentShareInfo: agentShareInfo, viewController: viewController)
    }

    // 通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AUIAICallDebugManager.shared.startCall(agentType: agentType, agentId: agentId, region: region, limitSecond: limitSecond, viewController: viewController)
    }
    
    // 通过指定智能体Id，发起通话
    open func startChat(agentId: String?, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AUIAICallDebugManager.shared.startChat(agentId: agentId, viewController: viewController)
    }
    
    
    
    // 通过分享智能体Token，发起消息对话
    open func startChat(agentShareInfo: String, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AUIAICallDebugManager.shared.startChat(agentShareInfo: agentShareInfo, viewController: viewController)
    }
}
#endif
