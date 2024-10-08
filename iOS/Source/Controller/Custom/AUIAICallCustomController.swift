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
        
        ARTCAICallEngineDebuger.PrintLog("Start Call")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.config.agentId ?? "")

        self.callService.startAIAgent(userId: self.userId, config: self.config) {[weak self] agent, token, error in
            
            ARTCAICallEngineDebuger.PrintLog("Start Call Result: \(error == nil ? "Success" : "Failed")")
            guard let self = self else { return }
            
            if self.state == .Over {
                if let instanceId = agent?.instanceId {
                    self.callService.stopAIAgent(instanceId: instanceId, completed: nil)
                }
                return
            }
            
            if let agent = agent, let token = token {
                
                self.config.agentType = agent.agentType // 修改为最终的agentType
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
                        self.callService.stopAIAgent(instanceId: agent.instanceId, completed: nil)
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
            if let agent = self.engine.agentInfo {
                self.callService.stopAIAgent(instanceId: agent.instanceId, completed: nil)
            }
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
    open func enableVoiceInterrupt(enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if let agent = self.engine.agentInfo {
                self.callService.updateAIAgent(instanceId: agent.instanceId, agentType: self.config.agentType, enable: enable) { [weak self] error in
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
                self.callService.updateAIAgent(instanceId: agent.instanceId, agentType: self.config.agentType, voiceId: voiceId) { [weak self] error in
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
    open func switchMicrophone(off: Bool) {
        self.config.muteMicrophone = off
        if self.state == .Connected {
            _ = self.engine.muteMicrophone(mute: off)
        }
    }
    
}


extension AUIAICallCustomController: ARTCAICallEngineDelegate {
    
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        self.engine.handup()
        self.errorCode = code
        self.state = .Error
    }
    
    public func onCallBegin() {
        ARTCAICallEngineDebuger.PrintLog("onCallBegin")
        if self.state != .Connecting {
            return
        }
        self.state = .Connected
        _ = self.engine.muteMicrophone(mute: self.config.muteMicrophone)
        _ = self.engine.enableSpeaker(enable: self.config.enableSpeaker)
        self.delegate?.onAICallBegin?()
    }
    
    public func onCallEnd() {
        ARTCAICallEngineDebuger.PrintLog("onCallEnd")
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
    
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int) {
        self.delegate?.onAICallUserSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, sentenceId: sentenceId)
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
}
