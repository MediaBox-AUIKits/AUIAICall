//
//  AUIAICallController.swift
//  AUIAICall
//
//  Created by Bingo on 2025/3/5.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallController: NSObject, AUIAICallControllerInterface {
    
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

    internal var appserver: AUIAICallAppServer = {
        let appserver = AUIAICallAppServer()
        return appserver
    }()
    internal var engine: ARTCAICallEngineInterface = {
        return ARTCAICallEngineFactory.createEngine()
    }()
    internal var startTime: TimeInterval = 0
    
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
    public internal(set) var agentVoiceIdList: [String] = []
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
    
    public private(set) var agentShareConfig: ARTCAICallAgentShareConfig? = nil {
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
        
        self.startTime = Date().timeIntervalSince1970
        self.state = .Connecting
        
        ARTCAICallEngineLog.StartLog(fileName: UUID().uuidString)
        ARTCAICallEngineLog.WriteLog("Start Call For RoomServerProxy")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentId", value: self.config.agentId ?? "")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentType", value: self.config.getWorkflowType())
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "UserId", value: self.userId)
        
        
        AUIAICallAuthTokenHelper.shared.fetchAuthToken(userId: self.userId) {[weak self] authToken, error in
            guard let self = self else {
                return
            }
            
            if self.state != .Connecting {
                return
            }
            
            if let _ = error {
                self.errorCode = .TokenExpired
                self.state = .Error
                self.delegate?.onAICallUserTokenExpired?()
            }
            else {
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "JoinToken", value: authToken)
                
                let callConfig = ARTCAICallConfig()
                callConfig.agentId = self.config.agentId!
                callConfig.agentType = self.config.agentType
                callConfig.userId = self.userId
                callConfig.region = self.config.region!
                callConfig.userData = self.config.userData
                callConfig.agentConfig = self.config.agentConfig
                callConfig.chatSyncConfig = self.config.chatSyncConfig
                callConfig.userJoinToken = authToken
                
                // 这里frameRate设置为5，需要根据控制台上的智能体的抽帧帧率（一般为2）进行调整，最大不建议超过15fps
                // bitrate: frameRate超过10可以设置为512
                if self.config.agentType == .VisionAgent{
                    callConfig.videoConfig = ARTCAICallVideoConfig(frameRate: 5, bitrate: 340, useFrontCameraDefault: false)
                }
                if self.config.agentType == .VideoAgent {
                    callConfig.videoConfig = ARTCAICallVideoConfig(frameRate: 5, bitrate: 340, useFrontCameraDefault: true)
                }
                
                _ = self.engine.muteLocalCamera(mute: self.config.muteLocalCamera)
                _ = self.engine.muteMicrophone(mute: self.config.muteMicrophone)
                _ = self.engine.enablePushToTalk(enable: self.config.agentConfig.enablePushToTalk)
                if self.engine.call(config: callConfig) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                        AUIAICallAuthTokenHelper.shared.requestNewAuthToken() // Request for next call
                    }
                }
                else {
                    self.errorCode = .InvalidParames
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
    public func setAgentViewConfig(viewConfig: ARTCAICallViewConfig?) {
        self.engine.setAgentViewConfig(viewConfig: viewConfig)
    }
    
    // 打断智能体说话
    open func interruptSpeaking() {
        if self.state == .Connected {
            _ = self.engine.interruptSpeaking()
        }
    }
    
    // 给智能体发送文本消息
    public func sendTextToAgent(req: ARTCAICallSendTextToAgentRequest) -> Bool {
        if self.state == .Connected {
            return self.engine.sendTextToAgent(req: req)
        }
        return false
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

extension AUIAICallController: ARTCAICallEngineDelegate {
    
    public func onErrorOccurs(code: ARTCAICallErrorCode) {
        debugPrint("AUIAICallController onErrorOccurs:\(code)")

        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: self.engine.agentInfo?.requestId ?? "unknown")
        self.engine.handup(true)
        self.errorCode = code
        self.state = .Error
    }
    
    public func onCallBegin() {
        debugPrint("AUIAICallController onCallBegin")
        if self.state != .Connecting {
            return
        }
        self.state = .Connected
        _ = self.engine.enableSpeaker(enable: self.config.enableSpeaker)
        let elapsedTime = Date().timeIntervalSince1970 - self.startTime
        self.delegate?.onAICallBegin?(elapsedTime: elapsedTime)
        ARTCAICallEngineLog.WriteLog("Start Call Connected: \(elapsedTime)")
    }
    
    public func onCallEnd() {
        debugPrint("AUIAICallController onCallEnd")
    }
    
    public func onRTCEngineCreated() {
        debugPrint("AUIAICallController onRTCEngineCreated")
        self.delegate?.onAICallRTCEngineCreated?()
    }
    
    public func onAgentStarted() {
        debugPrint("AUIAICallController onAgentStarted")

        let agent = self.engine.agentInfo!
        ARTCAICallEngineLog.WriteLog("Start Call Start Agent Result: Success")
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: agent.requestId)
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "ChannelId", value: agent.channelId)
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "AgentUserId", value: agent.uid)
        ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "InstanceId", value: agent.instanceId)
        
        self.delegate?.onAICallAIAgentStarted?(agentInfo: agent, elapsedTime: Date().timeIntervalSince1970 - self.startTime)
        self.fetchVoiceIdList(instanceId: agent.instanceId)
    }
    
    public func onAgentDataChannelAvailable() {
        debugPrint("AUIAICallController onAgentDataChannelAvailable")
        
    }
    
    public func onAgentAvatarFirstFrameDrawn() {
        debugPrint("AUIAICallController onAgentAvatarFirstFrameDrawn")
        if self.config.agentType == .AvatarAgent {
            self.delegate?.onAICallAvatarFirstFrameDrawn?()
        }
    }
    
    public func onAgentVideoAvailable(available: Bool) {
        debugPrint("AUIAICallController onAgentVideoAvailable:\(available)")
    }
    
    public func onAgentAudioAvailable(available: Bool) {
        debugPrint("AUIAICallController onAgentAudioAvailable:\(available)")
    }
    
    public func onAgentStateChanged(state: ARTCAICallAgentState) {
        debugPrint("AUIAICallController onAgentStateChanged:\(state)")
        self.delegate?.onAICallAgentStateChanged?()
    }
    
    public func onNetworkStatusChanged(uid: String, quality: ARTCAICallNetworkQuality) {
        debugPrint("AUIAICallController onNetworkStatusChanged:\(uid)  quality:\(quality)")
    }
    
    public func onVoiceVolumeChanged(uid: String, volume: Int32) {
//        debugPrint("AUIAICallController onVoiceVolumeChanged:\(uid)  volume:\(volume)")
        self.delegate?.onAICallActiveSpeakerVolumeChanged?(userId: uid, volume: volume)
    }
    
    public func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult) {
//        debugPrint("AUIAICallController onUserSubtitleNotify:\(text)  isSentenceEnd:\(isSentenceEnd)  sentenceId:\(sentenceId) voiceprintResult:\(voiceprintResult)")
        if isSentenceEnd {
            self.isVoiceprintRegisted = voiceprintResult == .DetectedSpeaker || voiceprintResult == .UndetectedSpeaker
        }
        self.delegate?.onAICallUserSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, sentenceId: sentenceId, voiceprintResult: voiceprintResult)
    }
    
    public func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
//        debugPrint("AUIAICallController onVoiceAgentSubtitleNotify:\(text)  isSentenceEnd:\(isSentenceEnd)  userAsrSentenceId:\(userAsrSentenceId)")
        self.delegate?.onAICallAgentSubtitleNotify?(text: text, isSentenceEnd: isSentenceEnd, userAsrSentenceId: userAsrSentenceId)
    }
    
    public func onAgentEmotionNotify(emotion: String, userAsrSentenceId: Int) {
        debugPrint("AUIAICallController onAgentEmotionNotify:\(emotion)  sentenceId: \(userAsrSentenceId)")
        self.delegate?.onAICallAgentEmotionNotify?(emotion: emotion, userAsrSentenceId: userAsrSentenceId)
    }
    
    public func onVoiceIdChanged(voiceId: String) {
        debugPrint("AUIAICallController onVoiceIdChanged:\(voiceId)")
        if self.config.agentConfig.ttsConfig.agentVoiceId == voiceId {
            if let switchVoiceIdCompleted = self.switchVoiceIdCompleted {
                switchVoiceIdCompleted(NSError.aicall_create(code: .InvalidAction))
            }
        }
        else {
            self.config.agentConfig.ttsConfig.agentVoiceId = voiceId
            self.switchVoiceIdCompleted?(nil)
        }
        self.switchVoiceIdCompleted = nil
    }
    
    public func onVoiceInterrupted(enable: Bool) {
        debugPrint("AUIAICallController onVoiceInterrupted:\(enable)")
        if self.config.agentConfig.interruptConfig.enableVoiceInterrupt == enable {
            if let enableVoiceInterruptCompleted = self.enableVoiceInterruptCompleted {
                enableVoiceInterruptCompleted(NSError.aicall_create(code: .InvalidAction))
            }
        }
        else {
            self.config.agentConfig.interruptConfig.enableVoiceInterrupt = enable
            self.enableVoiceInterruptCompleted?(nil)
        }
        self.enableVoiceInterruptCompleted = nil
    }
    
    public func onPushToTalk(enable: Bool) {
        debugPrint("AUIAICallController onPushToTalk:\(enable)")
        
        self.config.agentConfig.enablePushToTalk = enable
        self.delegate?.onAICallAgentPushToTalkChanged?(enable: enable)
    }
    
    public func onVoiceprint(enable: Bool) {
        debugPrint("AUIAICallController onVoiceprint:\(enable)")
        if self.config.agentConfig.voiceprintConfig.useVoiceprint == enable {
            if let useVoiceprintCompleted = self.useVoiceprintCompleted {
                useVoiceprintCompleted(NSError.aicall_create(code: .InvalidAction))
            }
        }
        else {
            self.config.agentConfig.voiceprintConfig.useVoiceprint = enable
            self.useVoiceprintCompleted?(nil)
        }
        self.useVoiceprintCompleted = nil
    }
    
    public func onVoiceprintCleared() {
        debugPrint("AUIAICallController onVoiceprintCleared")
    }
    
    public func onAgentWillLeave(reason: Int32, message: String) {
        self.delegate?.onAICallAgentWillLeave?(reason: reason, message: message)
    }
    
    public func onReceivedAgentCustomMessage(data: [String : Any]?) {
        debugPrint("AUIAICallController onReceivedAgentCustomMessage:\(data ?? [:])")
    }
    
    public func onHumanTakeoverWillStart(takeoverUid: String, takeoverMode: Int) {
        debugPrint("AUIAICallController onHumanTakeoverWillStart:\(takeoverUid) , takeoverMode:\(takeoverMode)")
        self.delegate?.onAICallHumanTakeoverWillStart?(takeoverUid: takeoverUid, takeoverMode: takeoverMode)
    }
    
    public func onHumanTakeoverConnected(takeoverUid: String) {
        debugPrint("AUIAICallController onHumanTakeoverConnected:\(takeoverUid)")
        self.delegate?.onAICallHumanTakeoverConnected?(takeoverUid: takeoverUid)
    }
    
    public func onVisionCustomCapture(enable: Bool) {
        debugPrint("AUIAICallController onVisionCustomCapture:\(enable)")
        self.delegate?.onAICallVisionCustomCapture?(enable: enable)
    }
    
    public func onSpeakingInterrupted(reason: ARTCAICallSpeakingInterruptedReason) {
        debugPrint("AUIAICallController onSpeakingInterrupted:\(reason)")
        self.delegate?.onAICallSpeakingInterrupted?(reason: reason)
    }
    
    public func onLLMReplyCompleted(text: String, userAsrSentenceId: Int) {
        debugPrint("AUIAICallController onLLMReplyCompleted:\(text) userAsrSentenceId:\(userAsrSentenceId)")
    }
    
    public func onReceivedAgentVcrResult(result: ARTCAICallAgentVcrResult) {
        if let resultData = result.resultData {
            debugPrint("AUIAICallController onReceivedAgentVcrResult:\(resultData.aicall_jsonString)")
        }
        self.delegate?.onAICallReceivedAgentVcrResult?(result: result)
    }
    
    public func onAudioDelayInfo(sentenceId: Int32, delayMs: Int64) {
        debugPrint("AUIAICalController onAudioDelayInfo: sentenceId:\(sentenceId), delayMs: \(delayMs)")
        self.delegate?.onAudioDelayInfo?(sentenceId: sentenceId, delayMs: delayMs)
    }
}

// 获取音色列表
extension AUIAICallController {
    
    // 如果你的业务无需获取音色列表，请把这个开关关闭
    static let EnableVoiceIdList: Bool = false
    
    public func fetchVoiceIdList(instanceId: String) {
        
        guard AUIAICallController.EnableVoiceIdList else {
            return
        }
           
        let body: [String: Any] = [
            "user_id": self.userId,
            "ai_agent_instance_id": instanceId
        ]
        
        self.appserver.request(path: "/api/v2/aiagent/describeAIAgentInstance", body: body) { [weak self] response, data, error in
            guard let self = self else {
                return
            }
            
            if let agent_config = data?["agent_config"] as? String, let dict = agent_config.aicall_jsonObj() {
                if let tts_dict = dict["TtsConfig"] as? Dictionary<String, Any> {
                    if let voiceId  = tts_dict["VoiceId"] as? String {
                        self.config.agentConfig.ttsConfig.agentVoiceId = voiceId
                    }
                    if let voiceIdList  = tts_dict["VoiceIdList"] as? [String] {
                        self.agentVoiceIdList = voiceIdList
                    }
                }
            }
        }
    }
    
}
