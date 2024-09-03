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
    public var avatarId: String = ""

#if AICALL_INTEGRATION_STANDARD && AICALL_INTEGRATION_CUSTOM
    public enum IntegrationWay: Int32 {
        case Standard
        case Custom
    }
    public var currentIntegrationWay: IntegrationWay = .Standard
    
    // 通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AVDeviceAuth.checkMicAuth { auth in
            if auth == false {
                return
            }
            
            let topVC = viewController ?? UIViewController.av_top()
            if self.currentIntegrationWay == .Standard {
                let controller = AUIAICallStandardController(userId: self.userId!)
                controller.config.agentId = agentId
                controller.config.agentType = agentType
                controller.config.agentVoiceId = agentType == .VoiceAgent ? "zhixiaoxia" : ""
                controller.config.agentAvatarId = self.avatarId
                controller.config.limitSecond = limitSecond
                let vc = AUIAICallViewController(controller)
                topVC.av_presentFullScreenViewController(vc, animated: true)
            }
            else {
                let controller = AUIAICallCustomController(userId: self.userId!)
                controller.config.agentId = agentId
                controller.config.agentType = agentType
                controller.config.agentVoiceId = agentType == .VoiceAgent ? "zhixiaoxia" : ""
                controller.config.agentAvatarId = self.avatarId
                controller.config.limitSecond = limitSecond
                let vc = AUIAICallViewController(controller)
                topVC.av_presentFullScreenViewController(vc, animated: true)
            }
        }
    }
#endif
    
#if AICALL_INTEGRATION_STANDARD && !AICALL_INTEGRATION_CUSTOM
    // 通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AVDeviceAuth.checkMicAuth { auth in
            if auth == false {
                return
            }
            
            let topVC = viewController ?? UIViewController.av_top()
            let controller = AUIAICallStandardController(userId: self.userId!)
            controller.config.agentId = agentId
            controller.config.agentType = agentType
            controller.config.agentVoiceId = agentType == .VoiceAgent ? "zhixiaoxia" : ""
            controller.config.agentAvatarId = self.avatarId
            controller.config.limitSecond = limitSecond
            let vc = AUIAICallViewController(controller)
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
#endif
    
#if !AICALL_INTEGRATION_STANDARD && AICALL_INTEGRATION_CUSTOM
    // 通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AVDeviceAuth.checkMicAuth { auth in
            if auth == false {
                return
            }
            
            let topVC = viewController ?? UIViewController.av_top()
            let controller = AUIAICallCustomController(userId: self.userId!)
            controller.config.agentId = agentId
            controller.config.agentType = agentType
            controller.config.agentVoiceId = agentType == .VoiceAgent ? "zhixiaoxia" : ""
            controller.config.agentAvatarId = self.avatarId
            controller.config.limitSecond = limitSecond
            let vc = AUIAICallViewController(controller)
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
#endif
}
