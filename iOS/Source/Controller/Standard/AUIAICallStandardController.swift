//
//  AUIAICallStandardController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallStandardController: AUIAICallController {
    
    // 创建&开始通话
    open override func start() {
        if self.state != .None {
            return
        }
        self.startTime = Date().timeIntervalSince1970
        self.state = .Connecting
        
        ARTCAICallEngineLog.StartLog(fileName: UUID().uuidString)
        ARTCAICallEngineLog.WriteLog("Start Call For Standard")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.config.agentId ?? "")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentType", value: self.config.getWorkflowType())
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "UserId", value: self.userId)
        
        self.generateAIAgentCall(userId: self.userId) {[weak self] agent, token, error, reqId in
            
            ARTCAICallEngineLog.WriteLog("Start Call Start Agent Result: \(error == nil ? "Success" : "Failed")")
            ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: reqId)

            guard let self = self else { return }
            
            if self.state != .Connecting {
                return
            }
            
            if let agent = agent, let token = token {
                
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "JoinToken", value: token)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "ChannelId", value: agent.channelId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentUserId", value: agent.uid)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "InstanceId", value: agent.instanceId)
                
                self.delegate?.onAICallAIAgentStarted?(agentInfo: agent, elapsedTime: Date().timeIntervalSince1970 - self.startTime)
                self.fetchVoiceIdList(instanceId: agent.instanceId)

                _ = self.engine.muteLocalCamera(mute: self.config.muteLocalCamera)
                _ = self.engine.muteMicrophone(mute: self.config.muteMicrophone)
                _ = self.engine.enablePushToTalk(enable: self.config.agentConfig.enablePushToTalk)
                
                // 这里frameRate设置为5，需要根据控制台上的智能体的抽帧帧率（一般为2）进行调整，最大不建议超过15fps
                // bitrate: frameRate超过10可以设置为512
                if self.config.agentType == .VisionAgent{
                    self.engine.videoConfig = ARTCAICallVideoConfig(frameRate: 5, bitrate: 340, useFrontCameraDefault: false)
                }
                if self.config.agentType == .VideoAgent {
                    self.engine.videoConfig = ARTCAICallVideoConfig(frameRate: 5, bitrate: 340, useFrontCameraDefault: true)
                }
                
                self.engine.call(userId: self.userId, token: token, agentInfo: agent) { [weak self] error in
                    ARTCAICallEngineLog.WriteLog("Start Call Engine Join Result: \(error == nil ? "Success" : "Failed")")
                    guard let self = self else { return }
                    if self.state != .Connecting {
                        return
                    }
                    
                    if let error = error {
                        self.errorCode = ARTCAICallErrorCode(rawValue: Int32(error.code)) ?? .BeginCallFailed
                        self.state = .Error
                    }
                }
            }
            else {
                var errorCode = ARTCAICallErrorCode.BeginCallFailed
                if let error = error {
                    if let ret = ARTCAICallErrorCode(rawValue: Int32(error.code)) {
                        errorCode = ret
                    }
                }
                self.errorCode = errorCode
                self.state = .Error
                if self.errorCode == .TokenExpired {
                    self.delegate?.onAICallUserTokenExpired?()
                }
            }
        }
    }
    
}


extension AUIAICallStandardController {
    
    private func handlerCallError(error: NSError?, data: [AnyHashable: Any]?) -> NSError? {
        if error?.code == 403 {
            return NSError.aicall_create(code: .TokenExpired)
        }
        return NSError.aicall_handlerErrorData(data: data) ?? NSError.aicall_create(code: .BeginCallFailed)
    }
    
    public func generateAIAgentCall(userId: String, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: NSError?, _ reqId: String) -> Void)?) {
        
        if let agentShareConfig = self.agentShareConfig {
            self.engine.generateShareAgentCall(shareConfig: agentShareConfig, userId: userId) { rsp, token, error, reqId in
                completed?(rsp, token, error, reqId)
            }
            return
        }
        
        let workflow_type = self.config.getWorkflowType()
        let agent_config = self.config.agentConfig.toData().aicall_jsonString

        var body: [String: Any] = [:]
        if let agentId = self.config.agentId {
            body = [
                "ai_agent_id": agentId,
                "user_id": userId,
                "expire": self.config.expireSecond,
                "template_config": "{}",
                "agent_config": agent_config
            ]
        }
        else {
            body = [
                "workflow_type": workflow_type,
                "user_id": userId,
                "expire": self.config.expireSecond,
                "template_config": "{}",
                "agent_config": agent_config
            ]
        }
        if let region = self.config.region {
            body.updateValue(region, forKey: "region")
        }
        if let userData = self.config.userData {
            body.updateValue(userData.aicall_jsonString, forKey: "user_data")
        }
        if let chatSyncConfig = self.config.chatSyncConfig {
            body.updateValue(chatSyncConfig.sessionId, forKey: "session_id")
            body.updateValue(chatSyncConfig.getConfigString(), forKey: "chat_sync_config")
        }

        self.appserver.request(path: "/api/v2/aiagent/generateAIAgentCall", body: body) { [weak self] response, data, error in
            let reqId = (data?["request_id"] as? String) ?? "unknow"
            if error == nil {
                debugPrint("generateAIAgentCall response: success")
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                let info = ARTCAICallAgentInfo(data: data)
                info.requestId = reqId
                info.region = self?.config.region
                completed?(info, rtc_auth_token, nil, reqId)
            }
            else {
                debugPrint("generateAIAgentCall response: failed, error:\(error!)")
                completed?(nil, nil, self?.handlerCallError(error: error, data: data), reqId)
            }
        }
    }
}
