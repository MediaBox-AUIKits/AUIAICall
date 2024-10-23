//
//  AUIAICallServiceImpl.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallServiceImpl: AUIAICallServiceInterface {
    
    var appserver = AUIAICallAppServer()
    
    private func agentTypeToString(_ agentType: ARTCAICallAgentType) -> String {
        if agentType == .AvatarAgent {
            return "AvatarChat3D"
        }
        else if agentType == .VisionAgent {
            return "VisionChat"
        }
        return "VoiceChat"
    }
    
    public func startAIAgent(userId: String, config: AUIAICallConfig, completed: ((ARTCAICallAgentInfo?, String?, Error?) -> Void)?) {
        if config.agentId == nil {
            self.startAIAgentInstance(userId: userId, config: config, completed: completed)
        }
        else {
            self.generateAIAgentCall(userId: userId, config: config, completed: completed)
        }
    }
    
    private func generateAIAgentCall(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: Error?) -> Void)?) {
        
        guard let agentId = config.agentId else {
            completed?(nil, nil, NSError.aicall_create(code: .InvalidParames, message: "lack off agentId"))
            return
        }
        
        var template_config: [String : Any] = [:]
        var configDict: [String : Any] = [
            "EnableVoiceInterrupt": config.enableVoiceInterrupt,
        ]
        if !config.agentVoiceId.isEmpty {
            configDict.updateValue(config.agentVoiceId, forKey: "VoiceId")
        }
        
        if config.agentType == .AvatarAgent {
            if config.agentAvatarId.isEmpty == false {
                configDict.updateValue(config.agentAvatarId, forKey: "AvatarId")
            }
        }
        let workflow_type = self.agentTypeToString(config.agentType)
        template_config.updateValue(configDict, forKey: workflow_type)

        
        let expire: Int = 24 * 60 * 60
        let body: [String: Any] = [
            "ai_agent_id": agentId,
            "user_id": userId,
            "expire": expire,
            "template_config": template_config.aicall_jsonString
        ]

        self.appserver.request(path: "/api/v2/aiagent/generateAIAgentCall", body: body) { response, data, error in
            if error == nil {
                debugPrint("generateAIAgentCall response: success")
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                let info = ARTCAICallAgentInfo(data: data)
                completed?(info, rtc_auth_token, nil)
            }
            else {
                debugPrint("generateAIAgentCall response: failed, error:\(error!)")
                completed?(nil, nil, error)
            }
        }
    }
    
    private func startAIAgentInstance(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: Error?) -> Void)?) {

        var template_config: [String : Any] = [:]
        var configDict: [String : Any] = [
            "EnableVoiceInterrupt": config.enableVoiceInterrupt,
        ]
        if !config.agentVoiceId.isEmpty {
            configDict.updateValue(config.agentVoiceId, forKey: "VoiceId")
        }
        if config.agentType == .AvatarAgent {
            if config.agentAvatarId.isEmpty == false {
                configDict.updateValue(config.agentAvatarId, forKey: "AvatarId")
            }
        }
        let workflow_type = self.agentTypeToString(config.agentType)
        template_config.updateValue(configDict, forKey: workflow_type)

        let body: [String : Any] = [
            "user_id": userId,
            "workflow_type": workflow_type,
            "template_config": template_config.aicall_jsonString
        ]
        
        self.appserver.request(path: "/api/v2/aiagent/startAIAgentInstance", body: body) { response, data, error in
            if error == nil {
                debugPrint("startAIAgentInstance response: success")
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                
                var mutableData = data as? [String: Any]
                mutableData?.updateValue(workflow_type, forKey: "workflow_type")
                let info = ARTCAICallAgentInfo(data: mutableData)
                completed?(info, rtc_auth_token, nil)
            }
            else {
                debugPrint("startAIAgentInstance response: failed, error:\(error!)")
                completed?(nil, nil, error)
            }
        }
    }
    
    public func stopAIAgent(userId: String, instanceId: String, completed: ((_ error: Error?) -> Void)?) {
        self.stopAIAgentInstance(userId: userId, instanceId: instanceId, completed: completed)
    }
    
    private func stopAIAgentInstance(userId: String, instanceId: String, completed: ((_ error: Error?) -> Void)?) {
        
        let body = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId
        ]
        self.appserver.request(path: "/api/v2/aiagent/stopAIAgentInstance", body: body) { response, data, error in
            if error == nil {
                if data?["result"] as? Bool == true {
                    debugPrint("stopAIAgentInstance response: success")
                    completed?(nil)
                }
                else {
                    debugPrint("stopAIAgentInstance response: result, failed")
                    completed?(NSError.aicall_create(code: -1, message: "api failed"))
                }
            }
            else {
                debugPrint("stopAIAgentInstance response: failed, error:\(error!)")
                completed?(error)
            }
        }
    }
    
    public func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, voiceId: String, completed: ((_ error: Error?) -> Void)?) {
        
        let workflow_type = self.agentTypeToString(agentType)
        let configDict: [String : Any] = [
            workflow_type: [
                "VoiceId": voiceId,
            ]
        ]
        let body = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId,
            "template_config": configDict.aicall_jsonString
        ]
        self.updateAIAgentInstance(body: body, completed: completed)
    }
    
    public func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        
        let key = self.agentTypeToString(agentType)
        let configDict: [String : Any] = [
            key: [
                "EnableVoiceInterrupt":enable,
            ]
        ]
        let body = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId,
            "template_config": configDict.aicall_jsonString
        ]
        self.updateAIAgentInstance(body: body, completed: completed)
    }
    
    private func updateAIAgentInstance(body: [String: Any], completed: ((_ error: Error?) -> Void)?) {
        
        self.appserver.request(path: "/api/v2/aiagent/updateAIAgentInstance", body: body) { response, data, error in
            if error == nil {
                if data?["result"] as? Bool == true {
                    debugPrint("updateAIAgentInstance response: success")
                    completed?(nil)
                }
                else {
                    debugPrint("updateAIAgentInstance response: result, failed")
                    completed?(NSError.aicall_create(code: -1, message: "api failed"))
                }
            }
            else {
                debugPrint("updateAIAgentInstance changedVoice response: failed, error:\(error!)")
                completed?(error)
            }
        }
    }

}
