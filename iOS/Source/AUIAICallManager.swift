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
    
    open func startCall(agentShareInfo: String, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
#if DEMO_FOR_DEBUG
        AUIAICallDebugManager.shared.startCall(agentShareInfo: agentShareInfo, viewController: viewController)
#elseif AICALL_INTEGRATION_STANDARD
        self.startCallWithStandard(agentShareInfo: agentShareInfo, viewController: viewController)
#elseif AICALL_INTEGRATION_CUSTOM
        // unsupport
#endif
    }

    // 通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
#if DEMO_FOR_DEBUG
        AUIAICallDebugManager.shared.startCall(agentType: agentType, agentId: agentId, region: region, limitSecond: limitSecond, viewController: viewController)
#elseif AICALL_INTEGRATION_STANDARD
        self.startCallWithStandard(agentType: agentType, agentId: agentId, region: region, limitSecond: limitSecond, viewController: viewController)
#elseif AICALL_INTEGRATION_CUSTOM
        self.startCallWithCustom(agentType: agentType, agentId: agentId, region: region, limitSecond: limitSecond, viewController: viewController)
#endif
    }
    
    
#if AICALL_INTEGRATION_STANDARD
    // 全托管方式发起通话，通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCallWithStandard(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        self.checkDeviceAuth(agentType: agentType) { [weak self] in
            guard let self = self else {return}
            
            let topVC = viewController ?? UIViewController.av_top()
            let controller = AUIAICallStandardController(userId: self.userId!)
            controller.config.agentId = agentId
            controller.config.agentType = agentType
            controller.config.agentVoiceId = ""
            controller.config.agentAvatarId = self.avatarId
            controller.config.voiceprintId = AUIAICallManager.defaultManager.voiceprintId
            controller.config.useVoiceprint = true
            controller.config.region = region
            controller.config.limitSecond = limitSecond
            let vc = AUIAICallViewController(controller)
            vc.enableVoiceIdSwitch = agentType != .AvatarAgent
            vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
    
    open func startCallWithStandard(agentShareInfo: String, viewController: UIViewController? = nil) {
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        self.checkDeviceAuth(agentType: .VisionAgent) { [weak self] in
            guard let self = self else {return}
            
            let topVC = viewController ?? UIViewController.av_top()
            let controller = AUIAICallStandardController(userId: self.userId!)
            controller.agentShareInfo = agentShareInfo
            let vc = AUIAICallViewController(controller)
            vc.enableVoiceIdSwitch = false
            vc.enableVoiceprintSwitch = false
            vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
#endif
    

    
#if AICALL_INTEGRATION_CUSTOM
    // 自集成方式发起通话，通过指定agentType（agentId为空时，由appserver配置的）发起通话，
    open func startCallWithCustom(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil, limitSecond: UInt32 = 0, viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        self.checkDeviceAuth(agentType: agentType) { [weak self] in
            guard let self = self else {return}
            
            let topVC = viewController ?? UIViewController.av_top()
            let controller = AUIAICallCustomController(userId: self.userId!)
            controller.config.agentId = agentId
            controller.config.agentType = agentType
            controller.config.agentVoiceId = ""
            controller.config.agentAvatarId = self.avatarId
            controller.config.voiceprintId = AUIAICallManager.defaultManager.voiceprintId
            controller.config.useVoiceprint = true
            controller.config.region = region
            controller.config.limitSecond = limitSecond
            let vc = AUIAICallViewController(controller)
            vc.enableVoiceIdSwitch = agentType != .AvatarAgent
            vc.onUserTokenExpiredBlcok = self.onUserTokenExpiredBlcok
            topVC.av_presentFullScreenViewController(vc, animated: true)
        }
    }
#endif
}
