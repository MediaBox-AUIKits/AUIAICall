//
//  AUIAICallStandardController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

#if canImport(AliVCSDK_ARTC)
@_implementationOnly import AliVCSDK_ARTC
#elseif canImport(AliVCSDK_InteractiveLive)
@_implementationOnly import AliVCSDK_InteractiveLive
#elseif canImport(AliVCSDK_Standard)
@_implementationOnly import AliVCSDK_Standard
#elseif canImport(AliRTCSdk)
@_implementationOnly import AliRTCSdk
#endif

@objcMembers class ARTCAICallEngine: NSObject, ARTCAICallEngineInterface {
    
    deinit {
        debugPrint("deinit: \(self)")
    }
        
    public private(set) var agentState: ARTCAICallAgentState = .Listening
    
    public private(set) var isOnCall: Bool = false
    
    public var userId: String? = nil
    public var agentInfo: ARTCAICallAgentInfo? = nil
    
    private var visionConfigPrivate: ARTCAICallVisionConfig = ARTCAICallVisionConfig()
    public var visionConfig: ARTCAICallVisionConfig {
        set {
            if !(self.isJoined || self.isJoining) {
                self.visionConfigPrivate = newValue
            }
        }
        get {
            return self.visionConfigPrivate
        }
    }

    public weak var delegate: ARTCAICallEngineDelegate? = nil
    
    public func call(userId: String, token: String, agentInfo: ARTCAICallAgentInfo, completed: ((NSError?) -> Void)?) {
        if self.isJoined || self.isJoining {
            completed?(NSError.aicall_create(code: .InvalidAction, message: "Current isJoined or isJoining"))
            return
        }
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Init RTCEngine")
        self.isJoining = true
        self.userId = userId
        self.agentInfo = agentInfo
        self.agentState = .Listening
        self.setupRtcEngine()
        // 开启低延迟
        self.rtcEngine?.setParameter("{\"net\":{\"enable_ai_low_latency_channel_mode\":true}}")
        if self.enableAIDelayDetection {
            self.rtcEngine?.setParameter("{\"audio\":{\"user_specified_loop_delay\":true}}")
        }
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine joinChannel begin")
        self.rtcEngine?.joinChannel(token, channelId: nil, userId: nil, name: nil) { [weak self] errCode, channel, userId, elapsed in
            var err : NSError? = nil
            if errCode != 0 {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine joinChannel failed:\(errCode)")
                err = NSError.aicall_create(code: .BeginCallFailed, message: "Join channel failed(\(errCode)")
            }
            else {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine joinChannel success")
                self?.isJoined = true
            }
            self?.isJoining = false
            completed?(err)
        }
    }
    
    public func handup(_ stopAIAgent: Bool) {
        if stopAIAgent {
            let model = ARTCAICallMessageSendModel()
            model.type = .StopAIAgent
            model.senderId = self.userId
            model.receiverId = self.agentInfo?.uid
            model.data = nil
            _ = self.sendMsgToDataChannel(model: model)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.handup(false)
            }
            return
        }
        
        self.resetPullAgentVideo()
        self.stopPublish()
        self.stopPreview()
        if self.isJoined || self.isJoining {
            if self.enableAIDelayDetection {
                let delay = self.rtcEngine?.getParameter("{\"audio\":{\"user_specified_loop_delay\":0}}")
                print("get aigc delay: \(delay ?? "null")")
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine get aigc delay: \(delay ?? "null")")
            }
            self.rtcEngine?.leaveChannel()
        }
        self.isJoining = false
        self.isJoined = false
        self.isOnCall = false
    }
    
    public func setAgentView(view: UIView?, mode: ARTCAICallAgentViewMode) {
        
        self.stopPullAgentVideo()
        
        if let view = view {
            let renderMode = AliRtcRenderMode(rawValue: UInt(mode.rawValue)) ?? .auto
            let canvas = AliVideoCanvas()
            canvas.view = view
            canvas.renderMode = renderMode
            self.agentCanvas = canvas
            
            self.startPullAgentVideo()
        }
        else {
            self.agentCanvas = nil
        }
    }

    public func interruptSpeaking() -> Bool {
        if self.isJoined == false {
            return false
        }
        let model = ARTCAICallMessageSendModel()
        model.type = .InterruptSpeaking
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        model.data = nil
        return self.sendMsgToDataChannel(model: model)
    }
    
    public func enableVoiceInterrupt(enable: Bool) -> Bool {
        // send message to data channel
        if self.isJoined == false {
            return false
        }
        
        if self.enablePushToTalk {
            return false
        }
        
        let model = ARTCAICallMessageSendModel()
        model.type = .EnableVoiceInterrupt
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        model.data = ["enable": enable]
        return self.sendMsgToDataChannel(model: model)
    }
    
    public func switchVoiceId(voiceId: String) -> Bool {
        // send message to data channel
        if self.isJoined == false {
            return false
        }
        let model = ARTCAICallMessageSendModel()
        model.type = .SwitchVoiceId
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        model.data = ["voiceId": voiceId]
        return self.sendMsgToDataChannel(model: model)
    }
    
    public func enableSpeaker(enable: Bool) -> Bool {
        guard let rtcEngine = self.rtcEngine else { return false }
        return rtcEngine.enableSpeakerphone(enable) == 0
    }
    
    public func muteMicrophone(mute: Bool) -> Bool {
        guard let rtcEngine = self.rtcEngine else {
            self.isMuteLocalMic = mute
            return true
        }
        if self.enablePushToTalk {
            self.isMuteLocalMic = mute
            return true
        }
        if rtcEngine.muteLocalMic(mute, mode: .allAudioMode) == 0 {
            self.isMuteLocalMic = mute
            return true
        }
        
        return false
    }
    
    public func muteLocalCamera(mute: Bool) -> Bool {
        if self.agentInfo?.agentType != .VisionAgent {
            return false
        }
        
        guard let rtcEngine = self.rtcEngine else {
            self.isMuteLocalCamera = mute
            return true
        }
        if (rtcEngine.muteLocalCamera(mute, for: .camera) == 0) {
            self.isMuteLocalCamera = mute
            if mute {
                self.stopPreview()
            }
            else {
                self.startPreview()
            }
            
            self.rtcEngine?.publishLocalVideoStream(self.agentInfo?.agentType == .VisionAgent
                                                    && !(self.isMuteLocalCamera || self.enablePushToTalk))
            return true
        }
        return false
    }
    
    public func switchCamera() -> Bool {
        if self.agentInfo?.agentType != .VisionAgent {
            return false
        }
        guard let rtcEngine = self.rtcEngine else { return false }
        return rtcEngine.switchCamera() == 0
    }
    
    private(set) var enablePushToTalk: Bool = false {
        didSet {
            self.updateEnablePushToTalk()
        }
    }
    public func enablePushToTalk(enable: Bool) -> Bool {
        if self.enablePushToTalk == enable {
            return false
        }
        
        self.isStartPushToTalk = false
        if self.rtcEngine == nil {
            self.enablePushToTalk = enable
            return true
        }
        
        if self.isJoined == true {
            let model = ARTCAICallMessageSendModel()
            model.type = .EnablePushToTalk
            model.senderId = self.userId
            model.receiverId = self.agentInfo?.uid
            model.data = ["enable": enable]
            let result = self.sendMsgToDataChannel(model: model)
            if result {
                self.enablePushToTalk = enable
                self.delegate?.onPushToTalk?(enable: self.enablePushToTalk)
            }
            return result
        }
        
        return false
    }
    
    private(set) var isStartPushToTalk: Bool = false
    private(set) var enableControlAuidioCapturePushToTalkMode = false
    
    public func startPushToTalk() -> Bool {
        if self.isJoined == false || !self.enablePushToTalk || self.isStartPushToTalk {
            return false
        }
        self.isStartPushToTalk = true
        let model = ARTCAICallMessageSendModel()
        model.type = .StartPushToTalk
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        _ = self.sendMsgToDataChannel(model: model)
        
        self.checkAudioCapturePushToTalkMode(start: true)
        self.rtcEngine?.muteLocalMic(false, mode: .allAudioMode)
        self.rtcEngine?.publishLocalVideoStream(self.agentInfo?.agentType == .VisionAgent
                                                && !(self.isMuteLocalCamera))
        return true
    }
    
    public func finishPushToTalk() -> Bool {
        if self.isJoined == false || !self.enablePushToTalk || !self.isStartPushToTalk {
            return false
        }
        self.isStartPushToTalk = false
        
        self.checkAudioCapturePushToTalkMode(start: false)
        self.rtcEngine?.muteLocalMic(true, mode: .allAudioMode)
        self.rtcEngine?.publishLocalVideoStream(self.agentInfo?.agentType == .VisionAgent
                                                && !(self.isMuteLocalCamera))
        
        let model = ARTCAICallMessageSendModel()
        model.type = .FinishPushToTalk
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        _ = self.sendMsgToDataChannel(model: model)
        
        return true
    }
    
    public func cancelPushToTalk() -> Bool {
        if self.isJoined == false || !self.enablePushToTalk || !self.isStartPushToTalk {
            return false
        }
        self.isStartPushToTalk = false
        
        self.checkAudioCapturePushToTalkMode(start: false)
        self.rtcEngine?.muteLocalMic(true, mode: .allAudioMode)
        self.rtcEngine?.publishLocalVideoStream(self.agentInfo?.agentType == .VisionAgent
                                                && !(self.isMuteLocalCamera))
        
        let model = ARTCAICallMessageSendModel()
        model.type = .CancelPushToTalk
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        _ = self.sendMsgToDataChannel(model: model)
        
        return true
    }
    
    // 当前断句是否使用声纹降噪识别
    public func useVoiceprint(isUse: Bool) -> Bool {
        // send message to data channel
        if self.isJoined == false {
            return false
        }
        
        let model = ARTCAICallMessageSendModel()
        model.type = .UseVoiceprint
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        model.data = ["enable": isUse]
        return self.sendMsgToDataChannel(model: model)
    }
    
    // 清除当前声纹数据
    public func clearVoiceprint() -> Bool {
        // send message to data channel
        if self.isJoined == false {
            return false
        }
        
        let model = ARTCAICallMessageSendModel()
        model.type = .ClearVoiceprint
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        return self.sendMsgToDataChannel(model: model)
    }
    
    public func getRTCInstance() -> AnyObject? {
        return self.rtcEngine
    }
    
    public func destroy() {
        self.handup(false)
        self.destroyRtcEngine()
    }
    
    private var rtcEngine: AliRtcEngine? = nil
    
    #if DEBUG
    private var enableAIDelayDetection: Bool = true  // 回环延迟检测开关
    #else
    private var enableAIDelayDetection: Bool = false  // 回环延迟检测开关
    #endif
    
    private var agentCanvas: AliVideoCanvas? = nil
    private var agentCanvasUid: String? = nil
    private var isMuteLocalCamera: Bool = false
    private var isMuteLocalMic: Bool = false

    private var isJoining: Bool = false  // 入会中
    private var isJoined: Bool = false  // 入会中
    private var activeSpeakerId: String? = nil
}



extension ARTCAICallEngine {
    
    private func setupRtcEngine() {
        if self.rtcEngine != nil {
            return
        }
        
        var extras: [String: Any] = [:]
        if ARTCAICallEngineDebuger.Debug_IsEnableDumpData {
            extras.updateValue("TRUE", forKey: "user_specified_audio_dump")
        }
        if ARTCAICallEngineDebuger.Debug_IsEnableTipsData {
            extras.updateValue("TRUE", forKey: "user_specified_audio_tips")
        }
        if ARTCAICallEngineDebuger.Debug_IsEnablePreRelease {
            extras.updateValue("PRE_RELEASE", forKey: "user_specified_environment")
        }
        let engine = AliRtcEngine.sharedInstance(self, extras:extras.aicall_jsonString)
        
        let parameter: [String: Any] = [
            "data":[
                "enablePubDataChannel": true,
                "enableSubDataChannel": true,
            ]
        ]
        engine.setParameter(parameter.aicall_jsonString)
        
        // 设置日志级别
        engine.setLogLevel(.info)
        
        // 设置频道模式
        engine.setChannelProfile(AliRtcChannelProfile.interactivelive)
        // 设置角色
        engine.setClientRole(AliRtcClientRole.roleInteractive)
        
        
        // 音频配置
        engine.setAudioSessionOperationRestriction(AliRtcAudioSessionOperationRestriction.none)
        engine.setAudioProfile(AliRtcAudioProfile.engineHighQualityMode, audio_scene: AliRtcAudioScenario.sceneChatroomMode)
        engine.enableAudioVolumeIndication(500, smooth: 3, reportVad: 1)
        engine.enableSpeakerphone(true)
        engine.setDefaultSubscribeAllRemoteAudioStreams(true)
        engine.subscribeAllRemoteAudioStreams(true)
        
        // 视频配置
        if self.agentInfo?.agentType == .AvatarAgent {
            engine.subscribeAllRemoteVideoStreams(true)
        }
        else if self.agentInfo?.agentType == .VisionAgent {
            let captureConfig = AliRtcCameraCapturerConfiguration()
            captureConfig.preference = .preview
            captureConfig.cameraDirection = .back
            engine.setCameraCapturerConfiguration(captureConfig)
            
            let config = AliRtcVideoEncoderConfiguration()
            config.dimensions = self.visionConfigPrivate.dimensions
            config.frameRate = self.visionConfigPrivate.frameRate
            config.bitrate = self.visionConfigPrivate.bitrate
            config.keyFrameInterval = self.visionConfigPrivate.keyFrameInterval
            config.orientationMode = AliRtcVideoEncoderOrientationMode.fixedPortrait
            engine.setVideoEncoderConfiguration(config)
        }
        else {
            engine.setAudioOnlyMode(true)
        }
        
        if let debugView = ARTCAICallEngineDebuger.Debug_TipsView {
            engine.showDebugView(debugView, show: .typeAll, userId: "")
        }
        
        self.rtcEngine = engine
        // 推流配置
        self.rtcEngine?.publishLocalAudioStream(true)
        self.rtcEngine?.publishLocalVideoStream(self.agentInfo?.agentType == .VisionAgent 
                                                && !(self.isMuteLocalCamera || self.enablePushToTalk))

        // 设备控制
        self.rtcEngine?.muteLocalMic(self.isMuteLocalMic || self.enablePushToTalk, mode: .allAudioMode)
        if self.enablePushToTalk{
            if !self.enableControlAuidioCapturePushToTalkMode {
                self.rtcEngine?.startAudioCapture()
            }
        }
        else {
            self.rtcEngine?.startAudioCapture()
        }
        if self.agentInfo?.agentType == .VisionAgent {
            self.rtcEngine?.muteLocalCamera(self.isMuteLocalCamera, for: .camera)
            if !self.isMuteLocalCamera {
                self.startPreview()
            }
        }
    }
    
    private func destroyRtcEngine() {
        ARTCAICallEngineDebuger.Debug_ClearTipsData()
        AliRtcEngine.destroy()
        self.rtcEngine = nil
    }
    
    private func startPreview() {
        guard let preview = self.visionConfigPrivate.preview else { return }
        let renderMode = AliRtcRenderMode(rawValue: UInt(self.visionConfigPrivate.viewMode.rawValue)) ?? .auto
        let canvas = AliVideoCanvas()
        canvas.view = preview
        canvas.renderMode = renderMode
        
        self.rtcEngine?.setLocalViewConfig(canvas, for: AliRtcVideoTrack.camera)
        self.rtcEngine?.startPreview()
    }
    
    private func stopPreview() {
        self.rtcEngine?.stopPreview()
        self.rtcEngine?.setLocalViewConfig(nil, for: AliRtcVideoTrack.camera)
    }
    
    private func stopPublish() {
        self.rtcEngine?.publishLocalAudioStream(false)
        self.rtcEngine?.stopAudioCapture()
        
        self.rtcEngine?.publishLocalVideoStream(false)
    }
    
    private func startPullAgentVideo() {
        if let agentCanvas = self.agentCanvas, let uid = self.agentCanvasUid {
            self.rtcEngine?.setRemoteViewConfig(agentCanvas, uid: uid, for: AliRtcVideoTrack.camera)
        }
    }
    
    private func stopPullAgentVideo() {
        if let agentCanvasUid = self.agentCanvasUid {
            self.rtcEngine?.setRemoteViewConfig(nil, uid: agentCanvasUid, for: AliRtcVideoTrack.camera)
        }
    }
    
    private func resetPullAgentVideo() {
        self.stopPullAgentVideo()
        self.agentCanvas = nil
        self.agentCanvasUid = nil
    }
    
    private func checkAudioCapturePushToTalkMode(start: Bool) {
        guard self.enableControlAuidioCapturePushToTalkMode else {
            return
        }
        if start {
            self.rtcEngine?.startAudioCapture()
        }
        else {
            self.rtcEngine?.stopAudioCapture()
        }
    }
    
    private func updateEnablePushToTalk() {
        if self.enablePushToTalk {
            self.checkAudioCapturePushToTalkMode(start: false)
            self.rtcEngine?.muteLocalMic(true, mode: .allAudioMode)
        }
        else {
            self.checkAudioCapturePushToTalkMode(start: true)
            self.rtcEngine?.muteLocalMic(self.isMuteLocalMic, mode: .allAudioMode)
        }
        self.rtcEngine?.publishLocalVideoStream(self.agentInfo?.agentType == .VisionAgent
                                                && !(self.isMuteLocalCamera || self.enablePushToTalk))
    }
    
    private func sendMsgToDataChannel(model: ARTCAICallMessageSendModel) -> Bool {
        if self.rtcEngine == nil {
            return false
        }
        
        var sendDict: [String: Any] = [
            "type": model.type.rawValue,
        ]
        if let senderId = model.senderId {
            sendDict.updateValue(senderId, forKey: "senderId")
        }
        if let receiverId = model.receiverId {
            sendDict.updateValue(receiverId, forKey: "receiverId")
        }
        if let data = model.data {
            sendDict.updateValue(data, forKey: "data")
        }

        let sendJsonString = sendDict.aicall_jsonString
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine WillSend: \(sendJsonString)")
        if let sendData = sendJsonString.data(using: .utf8) {
            let rtcMsg = AliRtcDataChannelMsg()
            rtcMsg.type = .custom
            rtcMsg.data = sendData
            return self.rtcEngine?.sendDataChannelMessage(rtcMsg) == 0
        }
        return false
    }
    
    private func receivedMsgFromDataChannel(model: ARTCAICallMessageReceiveModel) {
        let seqId = model.seqId ?? 0
        if model.type == .AgentErrorOccurs {
            if let code = model.data?["code"] as? Int32 {
                ARTCAICallEngineLog.WriteLog(.Error, "ARTCAICallEngine Received[\(seqId)] AgentErrorOccurs：\(code)")
                var err: ARTCAICallErrorCode? = nil
                if code == 4001 {
                    err = .AvatarRoutesExhausted
                }
                else if code == 4004 {
                    err = .AgentPullFailed
                }
                else if code == 4005 {
                    err = .AgentASRFailed
                }
                else if code == 4006 {
                    err = .AvatarServiceFailed
                }
                if let err = err {
                    self.delegate?.onErrorOccurs?(code: err)
                }
            }
        }
        else if model.type == .AgentStateChanged {
            if let state = model.data?["state"] as? Int32 {
                if let agentState = ARTCAICallAgentState(rawValue: state) {
                    ARTCAICallEngineLog.WriteLog(.Debug, "ARTCAICallEngine Received[\(seqId)] AgentState：\(agentState)")
                    self.agentState = agentState
                    self.delegate?.onAgentStateChanged?(state: agentState)
                }
            }
        }
        else if model.type == .AgentSubtitleNotify {
            if let text = model.data?["text"] as? String {
                let end = model.data?["end"] as? Bool ?? true
                let sentenceId = model.data?["sentenceId"] as? Int ?? 0
                ARTCAICallEngineLog.WriteLog(.Debug, "ARTCAICallEngine Received[\(seqId)] AgentSubtitleNotify：\(text)  isSentenceEnd=\(end)  sentenceId=\(sentenceId)")
                self.delegate?.onVoiceAgentSubtitleNotify?(text: text, isSentenceEnd: end, userAsrSentenceId: sentenceId)
            }
        }
        else if model.type == .UserSubtitleNotify {
            if let text = model.data?["text"] as? String {
                let end = model.data?["end"] as? Bool ?? true
                let sentenceId = model.data?["sentenceId"] as? Int ?? 0
                let voiceprint = model.data?["voiceprint"] as? Int32 ?? 0
                ARTCAICallEngineLog.WriteLog(.Debug, "ARTCAICallEngine Received[\(seqId)] UserSubtitleNotify：\(text)  isSentenceEnd=\(end)  sentenceId=\(sentenceId)  voiceprint=\(voiceprint)")
                self.delegate?.onUserSubtitleNotify?(text: text, isSentenceEnd: end, sentenceId: sentenceId)
                self.delegate?.onUserSubtitleNotify?(text: text, isSentenceEnd: end, sentenceId: sentenceId, voiceprintResult: ARTCAICallVoiceprintResult(rawValue: voiceprint) ?? .Off)
            }
        }
        else if model.type == .VoiceInterruptChanged {
            if let enable = model.data?["enable"] as? Bool {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] VoiceInterruptChanged：\(enable)")
                self.delegate?.onVoiceInterrupted?(enable: enable)
            }
        }
        else if model.type == .VoiceIdChanged {
            if let voiceId = model.data?["voiceId"] as? String {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] VoiceIdChanged：\(voiceId)")
                self.delegate?.onVoiceIdChanged?(voiceId: voiceId)
            }
        }
        else if model.type == .RTCTokenResponsed {
            if let token = model.data?["token"] as? String {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] RTCTokenResponsed：\(token)")
                self.rtcEngine?.refreshAuthInfo(withToken: token)
            }
        }
        else if model.type == .PushToTalkChanged {
            if let enable = model.data?["enable"] as? Bool {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] PushToTalkChanged：\(enable)")
                if self.enablePushToTalk != enable {
                    self.enablePushToTalk = enable
                    self.delegate?.onPushToTalk?(enable: self.enablePushToTalk)
                }
            }
        }
        else if model.type == .VoiceprintUsingChanged {
            if let enable = model.data?["enable"] as? Bool {
                ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] VoiceprintChanged：\(enable)")
                self.delegate?.onVoiceprint?(enable: enable)
            }
        }
        else if model.type == .VoiceprintClearSucceed {
            ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] VoiceprintClearSucceed")
            self.delegate?.onVoiceprintCleared?()
        }
        else if model.type == .AgentWillLeave {
            let reason = (model.data?["reason"] as? Int32) ?? 0
            let message = (model.data?["message"] as? String) ?? ""
            ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] AgentWillLeave: \(reason) message:\(message)")
            self.delegate?.onAgentWillLeave?(reason: reason, message: message)
        }
        else if model.type == .CustomMessageReceived {
            let jsonString = (model.data?["message"] as? String) ?? ""
            ARTCAICallEngineLog.WriteLog("ARTCAICallEngine Received[\(seqId)] CustomMessageReceived: \(jsonString)")
            if let data = jsonString.data(using: .utf8) {
                let messageDict = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String : Any]
                self.delegate?.onReceivedAgentCustomMessage?(data: messageDict)
            }
            else {
                self.delegate?.onReceivedAgentCustomMessage?(data: nil)
            }
        }
    }
}

extension ARTCAICallEngine: AliRtcEngineDelegate {
    
    public func onDataChannelMessage(_ uid: String, controlMsg: AliRtcDataChannelMsg) {
        if controlMsg.type != .custom {
            return
        }
        
        let dataDict = (try? JSONSerialization.jsonObject(with: controlMsg.data, options: .allowFragments)) as? [String : Any]
        guard let dataDict = dataDict else {
            return
        }
        ARTCAICallEngineLog.WriteLog(.Debug, "ARTCAICallEngine onDataChannelMessage:\(dataDict)")
        guard let type = dataDict["type"] as? Int32 else {
            return
        }
        guard let type = ARTCAICallMessageType(rawValue: type) else {
            return
        }
        
        let receive = ARTCAICallMessageReceiveModel()
        receive.type = type
        receive.seqId = dataDict["seqId"] as? Int64
        receive.senderId = dataDict["senderId"] as? String
        receive.receiverId = dataDict["receiverId"] as? String
        receive.data = dataDict["data"] as? [String: Any]
        DispatchQueue.main.async {
            self.receivedMsgFromDataChannel(model: receive)
        }
    }
    
    public func onJoinChannelResult(_ result: Int32, channel: String, userId: String, elapsed: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onJoinChannelResult:\(result) channel:\(channel) userId:\(userId)")
    }
    
    public func onJoinChannelResult(_ result: Int32, channel: String, elapsed: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onJoinChannelResult:\(result) channel:\(channel)")
    }
    
    public func onLeaveChannelResult(_ result: Int32, stats: AliRtcStats) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onLeaveChannelResult:\(result)")
        if result == 0 {
            DispatchQueue.main.async {
                self.delegate?.onCallEnd?()
            }
        }
    }
    
    public func onAudioPublishStateChanged(_ oldState: AliRtcPublishState, newState: AliRtcPublishState, elapseSinceLastState: Int, channel: String) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onAudioPublishStateChanged oldState:\(oldState) newState:\(newState)")
    }
    
    public func onAudioPublishStateChanged(_ track: AliRtcAudioTrack, oldState: AliRtcPublishState, newState: AliRtcPublishState, elapseSinceLastState: Int, channel: String) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onAudioPublishStateChanged oldState:\(oldState) newState:\(newState)")
    }
    
    public func onRemoteUser(onLineNotify uid: String, elapsed: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onRemoteUserOnLineNotify:\(uid)")
    }
    
    public func onRemoteUserOffLineNotify(_ uid: String, offlineReason reason: AliRtcUserOfflineReason) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onRemoteUserOffLineNotify:\(uid)")
        DispatchQueue.main.async {
            if uid == self.agentCanvasUid || uid == self.agentInfo?.uid {
                self.delegate?.onErrorOccurs?(code: .AgentLeaveChannel)
            }
        }
    }
    
    public func onRemoteTrackAvailableNotify(_ uid: String, audioTrack: AliRtcAudioTrack, videoTrack: AliRtcVideoTrack) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onRemoteTrackAvailableNotify:\(uid)  audioTrack:\(audioTrack)  videoTrack:\(videoTrack)")
        DispatchQueue.main.async {
            
            if videoTrack == .no {
                if uid == self.agentCanvasUid {
                    self.stopPullAgentVideo()
                    self.agentCanvasUid = nil
                }
            }
            else if videoTrack == .camera {
                if self.agentCanvasUid == nil {
                    self.agentCanvasUid = uid
                    self.startPullAgentVideo()
                }
            }
            
            self.delegate?.onAgentVideoAvailable?(available: videoTrack != .no)
            self.delegate?.onAgentAudioAvailable?(available: audioTrack != .no)
        }
    }

    public func onUserAudioMuted(_ uid: String, audioMuted isMute: Bool) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onUserAudioMuted:\(uid) isMute:\(isMute)")
    }
    
    public func onNetworkQualityChanged(_ uid: String, up upQuality: AliRtcNetworkQuality, downNetworkQuality downQuality: AliRtcNetworkQuality) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onNetworkQualityChanged:\(uid) upQuality:\(upQuality.rawValue)  downQuality:\(downQuality.rawValue)")
        DispatchQueue.main.async {
            if let quality = ARTCAICallNetworkQuality(rawValue: Int32(downQuality.rawValue)) {
                self.delegate?.onNetworkStatusChanged?(uid: uid, quality: quality)
            }
        }
    }
    

    public func onConnectionStatusChange(_ status: AliRtcConnectionStatus, reason: AliRtcConnectionStatusChangeReason) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onConnectionStatusChange:\(status.rawValue) reason:\(reason.rawValue)")
        DispatchQueue.main.async {
            if status == AliRtcConnectionStatus.failed {
                self.delegate?.onErrorOccurs?(code: .ConnectionFailed)
            }
        }
    }
    
    public func onOccurError(_ error: Int32, message: String) {
        ARTCAICallEngineLog.WriteLog(.Error, "ARTCAICallEngine onOccurError:\(error) message:\(message)")
        DispatchQueue.main.async {
//            if error == AliRtcErrorCode.errPublishInvaild.rawValue ||
//                error == AliRtcErrorCode.errPublishAudioStreamFailed.rawValue {
//                self.delegate?.onErrorOccurs?(code: .PublishFailed)
//            }
//            else if error == AliRtcErrorCode.errSubscribeInvaild.rawValue ||
//                error == AliRtcErrorCode.errSubscribeAudioStreamFailed.rawValue {
//                self.delegate?.onErrorOccurs?(code: .SubscribeFailed)
//            }
        }
    }
    
    public func onOccurWarning(_ warn: Int32, message: String) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onOccurWarning:\(warn) message:\(message)")
        
    }
    
    public func onLocalDeviceException(_ deviceType: AliRtcLocalDeviceType, exceptionType: AliRtcLocalDeviceExceptionType, message msg: String?) {
        ARTCAICallEngineLog.WriteLog(.Error, "ARTCAICallEngine onLocalDeviceException:\(deviceType) exceptionType:\(exceptionType) message:\(msg ?? "unknown")")
        DispatchQueue.main.async {
            self.delegate?.onErrorOccurs?(code: .LocalDeviceException)
        }
    }
    
    public func onBye(_ code: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onBye:\(code)")
        DispatchQueue.main.async {
            if code == AliRtcOnByeType.userReplaced.rawValue {
                self.delegate?.onErrorOccurs?(code: .KickedByUserReplace)
            }
            else if code == AliRtcOnByeType.beKickedOut.rawValue {
                self.delegate?.onErrorOccurs?(code: .KickedBySystem)
            }
            else if code == AliRtcOnByeType.channelTerminated.rawValue {
                self.delegate?.onErrorOccurs?(code: .KickedByChannelTerminated)
            }
        }
    }
    
    public func onAuthInfoWillExpire() {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onAuthInfoWillExpire")
        let model = ARTCAICallMessageSendModel()
        model.type = .RequestRTCToken
        model.senderId = self.userId
        model.receiverId = self.agentInfo?.uid
        model.data = ["userId": self.userId ?? ""]
        _ = self.sendMsgToDataChannel(model: model)
    }
    
    public func onAuthInfoExpired() {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onAuthInfoExpired")
        DispatchQueue.main.async {
            self.delegate?.onErrorOccurs?(code: .TokenExpired)
        }
    }
    
    public func onActiveSpeaker(_ uid: String) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onActiveSpeaker:\(uid)")
        DispatchQueue.main.async {
            self.activeSpeakerId = uid
        }
    }
    
    public func onAudioVolumeCallback(_ array: [AliRtcUserVolumeInfo]?, totalVolume: Int32) {
        DispatchQueue.main.async {
            if let delegate = self.delegate {
                array?.forEach({ info in
                    var uid = info.uid
                    if info.speech_state == true && uid == self.activeSpeakerId {
                        if uid == "0" && self.userId != nil {
                            uid = self.userId!
                        }
//                        debugPrint("ARTCAICallEngine onAudioVolumeCallback:\(uid) volume:\(info.volume)")
                        delegate.onVoiceVolumeChanged?(uid: uid, volume: info.volume)
                    }
                })
            }
        }
    }
    
    public func onRtcStats(_ stats: AliRtcStats) {
        DispatchQueue.main.async {
            var info: [String: String] = [:]
            info.updateValue(String(stats.available_sent_kbitrate), forKey: "可用带宽(kb) ")
            info.updateValue(String(stats.sent_kbitrate), forKey: "总发送码率(kb) ")
            info.updateValue(String(stats.rcvd_kbitrate), forKey: "总接收码率(kb) ")
            info.updateValue(String(stats.sent_bytes), forKey: "总发送数据量(bytes)")
            info.updateValue(String(stats.rcvd_bytes), forKey: "总接收数据量(bytes) ")
            info.updateValue(String(stats.video_rcvd_kbitrate), forKey: "视频接受码率(kb) ")
            info.updateValue(String(stats.video_sent_kbitrate), forKey: "视频发送码率(kb)")
            info.updateValue(String(stats.call_duration), forKey: "通话时长(s) ")
            info.updateValue(String(stats.cpu_usage), forKey: "进程CPU使用量(%)")
            info.updateValue(String(stats.systemCpuUsage), forKey: "系统CPU使用量(%) ")
            info.updateValue(String(stats.sent_loss_rate), forKey: "客户端到服务器的丢包率(%)")
            info.updateValue(String(stats.sent_loss_pkts), forKey: "客户端到服务器的丢包数")
            info.updateValue(String(stats.sent_expected_pkts), forKey: "客户端到服务器的总包数")
            info.updateValue(String(stats.rcvd_loss_rate), forKey: "服务器到客户端的下行丢包率（%）")
            info.updateValue(String(stats.rcvd_loss_pkts), forKey: "服务器到客户端的下行丢包数")
            info.updateValue(String(stats.rcvd_expected_pkts), forKey: "服务器到客户端的下行总包数")
            info.updateValue(String(stats.lastmile_delay), forKey: "客户端到服务器的延迟(ms)")
            ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RTCStats", value: info)
        }
    }
    
    func onFirstAudioPacketReceived(withUid uid: String, track: AliRtcAudioTrack, timeCost: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onFirstAudioPacketReceived:\(uid)")
        
        DispatchQueue.main.async {
            if self.isOnCall == false && self.isJoined {
                self.isOnCall = true
                self.delegate?.onCallBegin?()
            }
        }
    }
    
    func onFirstRemoteAudioDecoded(withUid uid: String, track: AliRtcAudioTrack, elapsed: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onFirstRemoteAudioDecoded:\(uid)")
    }
    
    func onFirstVideoPacketReceived(withUid uid: String, videoTrack: AliRtcVideoTrack, timeCost: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onFirstVideoPacketReceived:\(uid)")
    }
    
    func onFirstVideoFrameReceived(withUid uid: String, videoTrack: AliRtcVideoTrack, timeCost: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onFirstVideoFrameReceived:\(uid)")
    }
    
    func onFirstRemoteVideoFrameDrawn(_ uid: String, videoTrack: AliRtcVideoTrack, width: Int32, height: Int32, elapsed: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onFirstRemoteVideoFrameDrawn:\(uid)")
        DispatchQueue.main.async {
            if uid == self.agentCanvasUid {
                self.delegate?.onAgentAvatarFirstFrameDrawn?()
            }
        }
    }
    
    func onFirstLocalVideoFrameDrawn(_ width: Int32, height: Int32, elapsed: Int32) {
        ARTCAICallEngineLog.WriteLog("ARTCAICallEngine onFirstLocalVideoFrameDrawn")
    }
}

extension ARTCAICallEngine {
    
    public func parseShareAgentCall(shareInfo: String) -> ARTCAICallAgentShareConfig? {
        let json = shareInfo.aicall_decodeBase64AndDeserialize()
        guard let json = json else {
            return nil
        }
        return ARTCAICallAgentShareConfig.init(data: json)
    }
    
    public func generateShareAgentCall(shareConfig: ARTCAICallAgentShareConfig, userId: String, completed: ((ARTCAICallAgentInfo?, String?, NSError?, String) -> Void)?) {
        guard let shareId = shareConfig.shareId else {
            completed?(nil, nil, NSError.aicall_create(code: .InvalidParames), "")
            return
        }
        
        if (shareConfig.expireTime != nil) && (Date() > shareConfig.expireTime!) {
            completed?(nil, nil, NSError.aicall_create(code: .TokenExpired), "")
        }
        
        var body: [String: Any] = [:]
        let expire: Int = 24 * 60 * 60
        body = [
            "ai_agent_id": shareId,
            "user_id": userId,
            "expire": expire,
            "template_config": shareConfig.templateConfig ?? "{}",
        ]
        if let region = shareConfig.region {
            body.updateValue(region, forKey: "region")
        }

        ARTCAICallRequest.defaultRequest.request(path: "/api/v1/aiagent/generateAIAgentCall", body: body) { response, data, error in
            let reqId = (data?["request_id"] as? String) ?? "unknow"
            ARTCAICallEngineLog.WriteLog("ARTCAICallEngine generateShareAgentCall:\(reqId)")
            if error == nil {
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                let info = ARTCAICallAgentInfo(data: data)
                completed?(info, rtc_auth_token, nil, reqId)
            }
            else {
                completed?(nil, nil, error, reqId)
            }
        }
    }
}
