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
        let appserver = AUIAICallAppServer()
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
    
    
    public var agentShareInfo: String? = nil {
        didSet {
            if let agentShareInfo = self.agentShareInfo {
                self.agentShareConfig = self.engine.parseShareAgentCall(shareInfo: agentShareInfo)
            }
        }
    }
    private var agentShareConfig: ARTCAICallAgentShareConfig? = nil {
        didSet {
            if let agentShareConfig = self.agentShareConfig {
                self.config.agentId = agentShareConfig.shareId
                self.config.agentType = agentShareConfig.agentType
                if agentShareConfig.agentType == .AvatarAgent {
                    self.config.limitSecond = 5 * 60
                }
            }
        }
    }

    
    // ****************************Func**************************
    
    // 创建&开始通话
    open func start() {
        if self.state != .None {
            return
        }
        self.state = .Connecting
        
        ARTCAICallEngineLog.StartLog(fileName: UUID().uuidString)
        ARTCAICallEngineLog.WriteLog("Start Call For Standard")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.config.agentId ?? "")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "UserId", value: self.userId)
        
        self.generateAIAgentCall(userId: self.userId, config: self.config) {[weak self] agent, token, error, reqId in
            
            ARTCAICallEngineLog.WriteLog("Start Call Result: \(error == nil ? "Success" : "Failed")")
            ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: reqId)

            guard let self = self else { return }
            
            if self.state == .Over {
                return
            }
            
            if let agent = agent, let token = token {
                
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "ChannelId", value: agent.channelId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentUserId", value: agent.uid)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "InstanceId", value: agent.instanceId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "JoinToken", value: token)

                self.config.agentType = agent.agentType
                self.delegate?.onAICallAIAgentStarted?(agentInfo: agent)

                _ = self.engine.muteLocalCamera(mute: self.config.muteLocalCamera)
                _ = self.engine.muteMicrophone(mute: self.config.muteMicrophone)
                _ = self.engine.enablePushToTalk(enable: self.config.enablePushToTalk)
                self.engine.call(userId: self.userId, token: token, agentInfo: agent) { [weak self] error in
                    guard let self = self else { return }
                    if self.state == .Over {
                        return
                    }
                    
                    if let error = error {
                        self.errorCode = ARTCAICallErrorCode(rawValue: Int32(error.code)) ?? .BeginCallFailed
                        self.state = .Error
                    }
                }
            }
            else {
                if (error as? NSError)?.code == 403 {
                    self.errorCode = .TokenExpired
                    self.state = .Error
                    self.delegate?.onAICallUserTokenExpired?()
                }
                else {
                    self.errorCode = .BeginCallFailed
                    self.state = .Error
                }
            }
        }
    }
    
    // 挂断
    open func handup() {
        if self.state != .None {
            self.engine.handup(true)
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
    open func muteMicrophone(mute: Bool) {
        if self.engine.muteMicrophone(mute: mute) {
            self.config.muteMicrophone = mute
        }
    }
    
    // 开启/关闭摄像头
    open func muteLocalCamera(mute: Bool) {
        if self.engine.muteLocalCamera(mute: mute) {
            self.config.muteLocalCamera = mute
        }
    }
    
    // 切换前后摄像头
    open func switchCamera() {
        _ = self.engine.switchCamera()
    }
    
    // 开启/关闭对讲机模式，对讲机模式下，只有在finishPushToTalk被调用后，智能体才会播报结果
    open func enablePushToTalk(enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if (self.engine.enablePushToTalk(enable: enable)) {
                completed?(nil)
                return
            }
        }
        completed?(NSError.aicall_create(code: .InvalidAction, message: nil))
    }
    
    open func startPushToTalk() -> Bool {
        if self.state == .Connected {
            return self.engine.startPushToTalk()
        }
        return false
    }
    
    open func finishPushToTalk() -> Bool {
        if self.state == .Connected {
            return self.engine.finishPushToTalk()
        }
        return false
    }
    
    open func cancelPushToTalk() -> Bool {
        if self.state == .Connected {
            return self.engine.cancelPushToTalk()
        }
        return false
    }
    
    open private(set) var isVoiceprintRegisted: Bool = false
    
    // 当前断句是否使用声纹降噪识别
    var useVoiceprintCompleted: ((_ error: Error?) -> Void)? = nil
    open func useVoiceprint(isUse: Bool, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if (self.engine.useVoiceprint(isUse: isUse)) {
                self.useVoiceprintCompleted = completed
                return
            }
        }
        completed?(NSError.aicall_create(code: .InvalidAction, message: nil))
    }
    
    // 删除当前声纹数据
    public func clearVoiceprint() -> Bool {
        if self.state == .Connected {
            if self.engine.clearVoiceprint() {
                self.isVoiceprintRegisted = false
                return true
            }
        }
        return false
    }
}

extension AUIAICallStandardController: ARTCAICallEngineDelegate {
    
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        self.engine.handup(true)
        self.errorCode = code
        self.state = .Error
    }
    
    public func onCallBegin() {
        debugPrint("AUIAICallStandardController onCallBegin")
        if self.state != .Connecting {
            return
        }
        self.state = .Connected
        _ = self.engine.enableSpeaker(enable: self.config.enableSpeaker)
        self.delegate?.onAICallBegin?()
    }
    
    public func onCallEnd() {
        debugPrint("AUIAICallStandardController onCallEnd")
    }
    
    public func onAgentAvatarFirstFrameDrawn() {
        debugPrint("AUIAICallStandardController onAgentAvatarFirstFrameDrawn")
        if self.config.agentType == .AvatarAgent {
            self.delegate?.onAICallAvatarFirstFrameDrawn?()
        }
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
    
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult) {
//        debugPrint("AUIAICallStandardController onUserSubtitleNotify:\(text)  isSentenceEnd:\(isSentenceEnd)  sentenceId:\(sentenceId) voiceprintResult:\(voiceprintResult)")
        if isSentenceEnd {
            self.isVoiceprintRegisted = voiceprintResult == .DetectedSpeaker || voiceprintResult == .UndetectedSpeaker
        }
        self.delegate?.onAICallUserSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, sentenceId: sentenceId, voiceprintResult: voiceprintResult)
    }
    
    public func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
//        debugPrint("AUIAICallStandardController onVoiceAgentSubtitleNotify:\(text)  isSentenceEnd:\(isSentenceEnd)  userAsrSentenceId:\(userAsrSentenceId)")
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
    
    public func onPushToTalk(enable: Bool) {
        debugPrint("AUIAICallStandardController onPushToTalk:\(enable)")
        
        self.config.enablePushToTalk = enable
        self.delegate?.onAICallAgentPushToTalkChanged?(enable: enable)
    }
    
    public func onVoiceprint(enable: Bool) {
        debugPrint("AUIAICallStandardController onVoiceprint:\(enable)")
        if self.config.useVoiceprint == enable {
            if let useVoiceprintCompleted = self.useVoiceprintCompleted {
                useVoiceprintCompleted(NSError.aicall_create(code: .InvalidAction))
            }
        }
        else {
            self.config.useVoiceprint = enable
            self.useVoiceprintCompleted?(nil)
        }
        self.useVoiceprintCompleted = nil
    }
    
    public func onVoiceprintCleared() {
        debugPrint("AUIAICallStandardController onVoiceprintCleared")
    }
    
    public func onAgentWillLeave(reason: Int32, message: String) {
        self.delegate?.onAICallAgentWillLeave?(reason: reason, message: message)
    }
    
    public func onReceivedAgentCustomMessage(data: [String : Any]?) {
        debugPrint("AUIAICallStandardController onReceivedAgentCustomMessage:\(data ?? [:])")
    }
}

extension AUIAICallStandardController {
    
    private func agentTypeToString(_ agentType: ARTCAICallAgentType) -> String {
        if agentType == .AvatarAgent {
            return "AvatarChat3D"
        }
        else if agentType == .VisionAgent {
            return "VisionChat"
        }
        return "VoiceChat"
    }
    
    public func generateAIAgentCall(userId: String, config: AUIAICallConfig, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: Error?, _ reqId: String) -> Void)?) {
        
        if let agentShareConfig = self.agentShareConfig {
            self.engine.generateShareAgentCall(shareConfig: agentShareConfig, userId: userId) { rsp, token, error, reqId in
                completed?(rsp, token, error, reqId)
            }
            return
        }
        
        var template_config: [String : Any] = [:]
        var configDict: [String : Any] = [
            "EnableVoiceInterrupt": config.enableVoiceInterrupt,
            "EnablePushToTalk": config.enablePushToTalk,
            "MaxIdleTime": config.agentMaxIdleTime,
        ]
        if let voiceprintId = config.voiceprintId {
            configDict.updateValue(voiceprintId, forKey: "VoiceprintId")
            configDict.updateValue(config.useVoiceprint, forKey: "UseVoiceprint")
        }
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
            body = [
                "workflow_type": workflow_type,
                "user_id": userId,
                "expire": expire,
                "template_config": template_config.aicall_jsonString
            ]
        }
        if let region = config.region {
            body.updateValue(region, forKey: "region")
        }

        self.appserver.request(path: "/api/v2/aiagent/generateAIAgentCall", body: body) { response, data, error in
            let reqId = (data?["request_id"] as? String) ?? "unknow"
            if error == nil {
                debugPrint("generateAIAgentCall response: success")
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                let info = ARTCAICallAgentInfo(data: data)
                completed?(info, rtc_auth_token, nil, reqId)
            }
            else {
                debugPrint("generateAIAgentCall response: failed, error:\(error!)")
                completed?(nil, nil, error, reqId)
            }
        }
    }
}
