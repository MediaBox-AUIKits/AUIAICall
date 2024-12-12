//
//  AUIAICallServiceInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit


@objc public protocol AUIAICallServiceInterface {
    
    @objc func startAIAgent(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: NSError?, _ reqId: String) -> Void)?)
    
    @objc func stopAIAgent(userId: String, instanceId: String, completed: ((_ error: NSError?) -> Void)?)
    
    @objc func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, voiceId: String, completed: ((_ error: NSError?) -> Void)?)
    
    @objc func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, enableVoiceInterrupt: Bool, completed: ((_ error: NSError?) -> Void)?)
    
    @objc func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, enablePushToTalk: Bool, completed: ((_ error: NSError?) -> Void)?)
    
    @objc func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, useVoiceprint: Bool, completed: ((_ error: NSError?) -> Void)?)
}
