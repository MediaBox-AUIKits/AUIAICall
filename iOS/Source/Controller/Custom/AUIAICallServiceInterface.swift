//
//  AUIAICallServiceInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit


@objc public protocol AUIAICallServiceInterface {
    
    @objc func startAIAgent(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: Error?) -> Void)?)
    
    @objc func stopAIAgent(instanceId: String, completed: ((_ error: Error?) -> Void)?)
    
    @objc func updateAIAgent(instanceId: String, agentType: ARTCAICallAgentType, voiceId: String, completed: ((_ error: Error?) -> Void)?)
    
    @objc func updateAIAgent(instanceId: String, agentType: ARTCAICallAgentType, enable: Bool, completed: ((_ error: Error?) -> Void)?)
}
