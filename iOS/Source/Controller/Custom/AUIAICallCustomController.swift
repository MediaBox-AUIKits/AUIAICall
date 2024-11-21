//
//  AUIAICallCustomController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallCustomController: NSObject, AUIAICallControllerInterface {
    
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
    
    private var callService: AUIAICallServiceInterface = {
        return AUIAICallServiceImpl()
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
        
        ARTCAICallEngineLog.StartLog(fileName: UUID().uuidString)
        ARTCAICallEngineLog.WriteLog("Start Call")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.config.agentId ?? "")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "UserId", value: self.userId)
        
        self.callService.startAIAgent(userId: self.userId, config: self.config) {[weak self] agent, token, error, reqId in
            
            ARTCAICallEngineLog.WriteLog("Start Call Result: \(error == nil ? "Success" : "Failed")")
            ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: reqId)

            guard let self = self else { return }
            
            if self.state == .Over {
                if let instanceId = agent?.instanceId {
                    self.callService.stopAIAgent(userId: self.userId, instanceId: instanceId, completed: nil)
                }
                return
            }
            
            if let agent = agent, let token = token {
                
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "ChannelId", value: agent.channelId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentUserId", value: agent.uid)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "InstanceId", value: agent.instanceId)
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "JoinToken", value: token)

                self.config.agentType = agent.agentType // 修改为最终的agentType
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
                        self.callService.stopAIAgent(userId: self.userId, instanceId: agent.instanceId, completed: nil)
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
            if let agent = self.engine.agentInfo {
                self.callService.stopAIAgent(userId: self.userId, instanceId: agent.instanceId, completed: nil)
            }
            self.engine.handup(false)
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
    open func enableVoiceInterrupt(enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if let agent = self.engine.agentInfo {
                self.callService.updateAIAgent(userId: self.userId, instanceId: agent.instanceId, agentType: self.config.agentType, enableVoiceInterrupt: enable) { [weak self] error in
                    if error == nil {
                        self?.config.enableVoiceInterrupt = enable
                    }
                    completed?(error)
                }
                return
            }
        }
        completed?(NSError.aicall_create(code: .InvalidAction))
    }
    
    // 切换音色
    open func switchVoiceId(voiceId: String, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if let agent = self.engine.agentInfo {
                self.callService.updateAIAgent(userId: self.userId, instanceId: agent.instanceId, agentType: self.config.agentType, voiceId: voiceId) { [weak self] error in
                    if error == nil {
                        self?.config.agentVoiceId = voiceId
                    }
                    completed?(error)
                }
                return
            }
        }
        completed?(NSError.aicall_create(code: .InvalidAction))
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

extension AUIAICallCustomController: ARTCAICallEngineDelegate {
    
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        self.engine.handup(false)
        self.errorCode = code
        self.state = .Error
    }
    
    public func onCallBegin() {
        ARTCAICallEngineLog.WriteLog("onCallBegin")
        if self.state != .Connecting {
            return
        }
        self.state = .Connected
        _ = self.engine.enableSpeaker(enable: self.config.enableSpeaker)
        self.delegate?.onAICallBegin?()
    }
    
    public func onCallEnd() {
        ARTCAICallEngineLog.WriteLog("onCallEnd")
    }
    
    public func onAgentAvatarFirstFrameDrawn() {
        if self.config.agentType == .AvatarAgent {
            self.delegate?.onAICallAvatarFirstFrameDrawn?()
        }
    }
    
    public func onAgentVideoAvailable(availab: Bool) {
        
    }
    
    public func onAgentAudioAvailable(available: Bool) {
        
    }
    
    public func onAgentStateChanged(state: ARTCAICallAgentState) {
        self.delegate?.onAICallAgentStateChanged?()
    }
    
    public func onNetworkStatusChanged(uid: String, quality: ARTCAICallNetworkQuality) {
        
    }
    
    public func onVoiceVolumeChanged(uid: String, volume: Int32) {
        self.delegate?.onAICallActiveSpeakerVolumeChanged?(userId: uid, volume: volume)
    }
    
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult) {
        if isSentenceEnd {
            self.isVoiceprintRegisted = voiceprintResult == .DetectedSpeaker || voiceprintResult == .UndetectedSpeaker
        }
        self.delegate?.onAICallUserSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, sentenceId: sentenceId, voiceprintResult: voiceprintResult)
    }
    
    public func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        self.delegate?.onAICallAgentSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, userAsrSentenceId: userAsrSentenceId)
    }
    
    public func onVoiceIdChanged(voiceId: String) {
        self.config.agentVoiceId = voiceId
    }
    
    public func onVoiceInterrupted(enable: Bool) {
        self.config.enableVoiceInterrupt = enable
    }
    
    public func onPushToTalk(enable: Bool) {
        self.config.enablePushToTalk = enable
        self.delegate?.onAICallAgentPushToTalkChanged?(enable: enable)
    }
    
    public func onVoiceprint(enable: Bool) {
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
        
    }
    
    public func onAgentWillLeave(reason: Int32, message: String) {
        self.delegate?.onAICallAgentWillLeave?(reason: reason, message: message)
    }
    
    public func onReceivedAgentCustomMessage(data: [String : Any]?) {
        
    }
}
