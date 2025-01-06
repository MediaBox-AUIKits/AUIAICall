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
    
    private func handlerCallError(error: NSError?, data: [AnyHashable: Any]?) -> NSError? {
        guard let error = error else { return nil }
        if error.code == 403 {
            return NSError.aicall_create(code: .TokenExpired)
        }
        if let ret = data?["error_code"] as? String {
            if ret == "Forbidden.SubscriptionRequired" {
                return NSError.aicall_create(code: .AgentSubscriptionRequired)
            }
            else if ret == "AgentNotFound" {
                return NSError.aicall_create(code: .AgentNotFound)
            }
        }
        return NSError.aicall_create(code: .BeginCallFailed)
    }
    
    public func startAIAgent(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: NSError?, _ reqId: String) -> Void)?) {

        let template_config = config.getTemplateConfigString()
        let workflow_type = config.getWorkflowType()

        var body: [String : Any] = [
            "user_id": userId,
            "workflow_type": workflow_type,
            "template_config": template_config
        ]
        if let userData = config.userData {
            body.updateValue(userData.aicall_jsonString, forKey: "user_data")
        }
        
        self.appserver.request(path: "/api/v2/aiagent/startAIAgentInstance", body: body) {[weak self] response, data, error in
            let reqId = (data?["request_id"] as? String) ?? "unknow"
            if error == nil {
                debugPrint("startAIAgentInstance response: success")
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                
                var mutableData = data as? [String: Any]
                mutableData?.updateValue(workflow_type, forKey: "workflow_type")
                let info = ARTCAICallAgentInfo(data: mutableData)
                completed?(info, rtc_auth_token, nil, reqId)
            }
            else {
                debugPrint("startAIAgentInstance response: failed, error:\(error!)")
                completed?(nil, nil, self?.handlerCallError(error: error, data: data), reqId)
            }
        }
    }
    
    public func stopAIAgent(userId: String, instanceId: String, completed: ((_ error: NSError?) -> Void)?) {
        self.stopAIAgentInstance(userId: userId, instanceId: instanceId, completed: completed)
    }
    
    private func stopAIAgentInstance(userId: String, instanceId: String, completed: ((_ error: NSError?) -> Void)?) {
        
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
    
    public func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, voiceId: String, completed: ((_ error: NSError?) -> Void)?) {
        
        let workflow_type = ARTCAICallTemplateConfig.getTemplateConfigKey(agentType)
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
    
    public func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, enableVoiceInterrupt: Bool, completed: ((_ error: NSError?) -> Void)?) {
        
        let key = ARTCAICallTemplateConfig.getTemplateConfigKey(agentType)
        let configDict: [String : Any] = [
            key: [
                "EnableVoiceInterrupt":enableVoiceInterrupt,
            ]
        ]
        let body = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId,
            "template_config": configDict.aicall_jsonString
        ]
        self.updateAIAgentInstance(body: body, completed: completed)
    }
    
    public func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, enablePushToTalk: Bool, completed: ((_ error: NSError?) -> Void)?) {
        
        let key = ARTCAICallTemplateConfig.getTemplateConfigKey(agentType)
        let configDict: [String : Any] = [
            key: [
                "EnablePushToTalk":enablePushToTalk,
            ]
        ]
        let body = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId,
            "template_config": configDict.aicall_jsonString
        ]
        self.updateAIAgentInstance(body: body, completed: completed)
    }
    
    public func updateAIAgent(userId: String, instanceId: String, agentType: ARTCAICallAgentType, useVoiceprint: Bool, completed: ((_ error: NSError?) -> Void)?) {
        
        let key = ARTCAICallTemplateConfig.getTemplateConfigKey(agentType)
        let configDict: [String : Any] = [
            key: [
                "UseVoiceprint": useVoiceprint,
            ]
        ]
        let body = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId,
            "template_config": configDict.aicall_jsonString
        ]
        self.updateAIAgentInstance(body: body, completed: completed)
    }
    
    private func updateAIAgentInstance(body: [String: Any], completed: ((_ error: NSError?) -> Void)?) {
        
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
    
    public func describeAIAgentInstance(userId: String, instanceId: String, agentType: ARTCAICallAgentType, completed: ((String?, [String]?, NSError?) -> Void)?) {
        
        var body: [String: Any] = [
            "user_id": userId,
            "ai_agent_instance_id": instanceId
        ]
        
        self.appserver.request(path: "/api/v2/aiagent/describeAIAgentInstance", body: body) { response, data, error in
            if let template_config = data?["template_config"] as? String, let dict = template_config.aicall_jsonObj() {
                if let agent_dict = dict[ARTCAICallTemplateConfig.getTemplateConfigKey(agentType)] as? Dictionary<String, Any> {
                    if let voiceId  = agent_dict["VoiceId"] as? String, let voiceIdList  = agent_dict["VoiceIdList"] as? [String] {
                        completed?(voiceId, voiceIdList, error)
                        return
                    }
                }
            }
            completed?(nil, nil, error)
        }
        
    }

}
