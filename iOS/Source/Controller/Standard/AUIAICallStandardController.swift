//
//  AUIAICallStandardController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallStandardController: NSObject, AUIAICallControllerInterface {
    
    public init(userId: String) {
        super.init()
        
        self.userId = userId
        self.engine.delegate = self
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        self.engine.destroy()
    }
    
    // ****************************Private members**************************

    private var appserver: AUIAICallAppServer = {
        let appserver = AUIAICallAppServer(serverDomain: AICallServerDomain)
        return appserver
    }()
    private var engine: ARTCAICallEngineInterface = {
        return ARTCAICallEngineFactory.createEngine()
    }()

    
    // ****************************Public members**************************
    
    public var currentEngine: ARTCAICallEngineInterface {
        get {
            return self.engine
        }
    }
    
    public internal(set) var userId: String = ""
    public internal(set) var config: AUIAICallConfig = AUIAICallConfig()
    public internal(set) var state: AUIAICallState = .None {
        didSet {
            self.delegate?.onAICallStateChanged?()
        }
    }
    public internal(set) var errorCode: ARTCAICallErrorCode = .None
    public var agentInfo: ARTCAICallAgentInfo? {
        get {
            return self.engine.agentInfo
        }
    }
    public var agentState: ARTCAICallAgentState {
        get {
            return self.engine.agentState
        }
    }
    public weak var delegate: AUIAICallControllerDelegate?
    
    // ****************************Func**************************
    
    // 创建&开始通话
    open func start() {
        if self.state != .None {
            return
        }
        self.state = .Connecting
        
        ARTCAICallEngineDebuger.PrintLog("Start Call")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.config.agentId ?? "")
        
        self.generateAIAgentCall(userId: self.userId, config: self.config) {[weak self] agent, token, error in
            
            ARTCAICallEngineDebuger.PrintLog("Start Call Result: \(error == nil ? "Success" : "Failed")")
            guard let self = self else { return }
            
            if self.state == .Over {
                return
            }
            
            if let agent = agent, let token = token {
                
                self.config.agentType = agent.agentType
                self.delegate?.onAICallAIAgentStarted?()

                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "ChannelId", value: agent.channelId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "UserId", value: agent.uid)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "InstanceId", value: agent.instanceId)

                self.engine.call(userId: self.userId, token: token, agentInfo: agent) { [weak self] error in
                    guard let self = self else { return }
                    if self.state == .Over {
                        return
                    }
                    
                    if let error = error {
                        self.errorCode = ARTCAICallErrorCode(rawValue: Int32(error.code)) ?? .BeginCallFailed
                        self.state = .Error
                    }
                    else {
                        _ = self.engine.muteMicrophone(mute: true)
                    }
                }
            }
            else {
                self.errorCode = .BeginCallFailed
                self.state = .Error
            }
        }
    }
    
    // 挂断
    open func handup() {
        if self.state != .None {
            self.engine.handup()
            self.state = .Over
        }
    }
    
    // 设置智能体渲染视图，及缩放模式
    public func setAgentView(view: UIView?, mode: ARTCAICallAgentViewMode) {
        self.engine.setAgentView(view: view, mode: mode)
    }
    
    // 打断智能体说话
    open func interruptSpeaking() {
        if self.state == .Connected {
            _ = self.engine.interruptSpeaking()
        }
    }
    
    // 开启/关闭智能打断
    var enableVoiceInterruptCompleted: ((_ error: Error?) -> Void)? = nil
    open func enableVoiceInterrupt(enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if (self.engine.enableVoiceInterrupt(enable: enable)) {
                self.enableVoiceInterruptCompleted = completed
                return
            }
        }
        completed?(NSError.aicall_create(code: .InvalidAction, message: nil))
    }
    
    // 切换音色
    var switchVoiceIdCompleted: ((_ error: Error?) -> Void)? = nil
    open func switchVoiceId(voiceId: String, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if (self.engine.switchVoiceId(voiceId: voiceId)) {
                self.switchVoiceIdCompleted = completed
                return
            }
        }
        completed?(NSError.aicall_create(code: .InvalidAction, message: nil))
    }
    
    // 开启/关闭扬声器
    open func enableSpeaker(enable: Bool) {
        self.config.enableSpeaker = enable
        _ = self.engine.enableSpeaker(enable: enable)
    }
    
    // 开启/关闭麦克风
    open func switchMicrophone(off: Bool) {
        self.config.muteMicrophone = off
        if self.state == .Connected {
            _ = self.engine.muteMicrophone(mute: off)
        }
    }
    
}

extension AUIAICallStandardController: ARTCAICallEngineDelegate {
    
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        self.engine.handup()
        self.errorCode = code
        self.state = .Error
    }
    
    public func onCallBegin() {
        debugPrint("AUIAICallStandardController onCallBegin")
        if self.state != .Connecting {
            return
        }
        self.state = .Connected
        _ = self.engine.muteMicrophone(mute: self.config.muteMicrophone)
        _ = self.engine.enableSpeaker(enable: self.config.enableSpeaker)
        self.delegate?.onAICallBegin?()
    }
    
    public func onCallEnd() {
        debugPrint("AUIAICallStandardController onCallEnd")
    }
    
    public func onAgentVideoAvailable(available: Bool) {
        debugPrint("AUIAICallStandardController onAgentVideoAvailable:\(available)")
    }
    
    public func onAgentAudioAvailable(available: Bool) {
        debugPrint("AUIAICallStandardController onAgentAudioAvailable:\(available)")
    }
    
    public func onAgentStateChanged(state: ARTCAICallAgentState) {
        debugPrint("AUIAICallStandardController onAgentStateChanged:\(state)")
        self.delegate?.onAICallAgentStateChanged?()
    }
    
    public func onNetworkStatusChanged(uid: String, quality: ARTCAICallNetworkQuality) {
        debugPrint("AUIAICallStandardController onNetworkStatusChanged:\(uid)  quality:\(quality)")
    }
    
    public func onVoiceVolumeChanged(uid: String, volume: Int32) {
//        debugPrint("AUIAICallStandardController onVoiceVolumeChanged:\(uid)  volume:\(volume)")
        self.delegate?.onAICallActiveSpeakerVolumeChanged?(userId: uid, volume: volume)
    }
    
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int) {
        debugPrint("AUIAICallStandardController onUserSubtitleNotify:\(text)  isSentenceEnd:\(isSentenceEnd)  sentenceId:\(sentenceId)")
        self.delegate?.onAICallUserSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, sentenceId: sentenceId)
    }
    
    public func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        debugPrint("AUIAICallStandardController onVoiceAgentSubtitleNotify:\(text)  isSentenceEnd:\(isSentenceEnd)  userAsrSentenceId:\(userAsrSentenceId)")
        self.delegate?.onAICallAgentSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, userAsrSentenceId: userAsrSentenceId)
    }
    
    public func onVoiceIdChanged(voiceId: String) {
        debugPrint("AUIAICallStandardController onVoiceIdChanged:\(voiceId)")
        if self.config.agentVoiceId == voiceId {
            if let switchVoiceIdCompleted = self.switchVoiceIdCompleted {
                switchVoiceIdCompleted(NSError.aicall_create(code: .InvalidAction))
            }
        }
        else {
            self.config.agentVoiceId = voiceId
            self.switchVoiceIdCompleted?(nil)
        }
        self.switchVoiceIdCompleted = nil
    }
    
    public func onVoiceInterrupted(enable: Bool) {
        debugPrint("AUIAICallStandardController onVoiceInterrupted:\(enable)")
        if self.config.enableVoiceInterrupt == enable {
            if let enableVoiceInterruptCompleted = self.enableVoiceInterruptCompleted {
                enableVoiceInterruptCompleted(NSError.aicall_create(code: .InvalidAction))
            }
        }
        else {
            self.config.enableVoiceInterrupt = enable
            self.enableVoiceInterruptCompleted?(nil)
        }
        self.enableVoiceInterruptCompleted = nil
    }
}

extension AUIAICallStandardController {
    
    public func generateAIAgentCall(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: Error?) -> Void)?) {
        
//        if !AUIAICallAppServer.serverAuthValid() {
//            completed?(nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
//            return
//        }
        
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
            template_config.updateValue(configDict, forKey: "AvatarChat3D")
        }
        else {
            template_config.updateValue(configDict, forKey: "VoiceChat")
        }
        
        var body: [String: Any] = [:]
        let expire: Int = 24 * 60 * 60
        if let agentId = config.agentId {
            body = [
                "ai_agent_id": agentId,
                "user_id": userId,
                "expire": expire,
                "template_config": template_config.aicall_jsonString
            ]
        }
        else {
            let workflow_type = config.agentType == .AvatarAgent ? "AvatarChat3D" : "VoiceChat"
            body = [
                "workflow_type": workflow_type,
                "user_id": userId,
                "expire": expire,
                "template_config": template_config.aicall_jsonString
            ]
        }

        self.appserver.request(path: "/api/v1/aiagent/generateAIAgentCall", body: body) { response, data, error in
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
}
