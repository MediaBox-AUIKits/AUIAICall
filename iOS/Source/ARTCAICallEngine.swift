//
//  ARTCAICallEngine.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

@objcMembers open class ARTCAICallConfig: NSObject {
    open var robotId: String? = nil
    open var robotVoiceId: String = "zhixiaoxia"
    open var enableVoiceInterrupt = true
    open var enableSpeaker = true
    open var muteMicrophone = false
}

@objc public enum ARTCAICallErrorCode: Int32 {
    case StartFailed            // 无法启动通话
    case TokenExpired           // 通话认证过期
    case ConnectionFailed       // 链接出现问题
    case kickedByUserReplace    // 同名登录导致通话无法进行
    case kickedBySystem         // 被系统踢出导致通话无法进行
    case LocalDeviceException   // 本地设备问题导致无法进行
}

@objc public protocol ARTCAICallEngineDelegate: NSObjectProtocol {
    @objc optional func onAICallEngineStateChanged()
    @objc optional func onAICallEngineRobotStateChanged()
    @objc optional func onAICallEngineActiveSpeakerVolumeChanged(userId: String, volume: Int32)
}


@objcMembers open class ARTCAICallEngine: NSObject {
    
    public enum CallMode: Int32 {
        case OnlyAudio      // 纯语音
        case DigitalHuman   // 数字人(暂不支持)
    }
    
    public enum CallState: Int32 {
        case None            // 初始化
        case Connecting      // 接通中
        case Connected       // 通话中
        case Over            // 通话结束
        case Error           // 通话出错了
    }
    
    public enum RobotState: Int32 {
        case Listening = 1      // 聆听中
        case Thinking = 2       // 思考中
        case Speaking = 3       // 讲话中
    }
    
    
    public init(userId: String) {
        self.userId = userId
        self.callService = ARTCAICallServiceImpl()
        self.rtcService = ARTCAICallRTCService()
        super.init()
        
        self.callService.receivedMessageDelegate = self
        self.rtcService.bridgeDelegate = self.callService as! ARTCAICallServiceImpl
        self.rtcService.delegate = self
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        self.rtcService.destroy()
    }
    
    public let userId: String
    public let config: ARTCAICallConfig = ARTCAICallConfig()
    public let mode: CallMode = .OnlyAudio
    public let rtcService: ARTCAICallRTCService
    public let callService: ARTCAICallServiceInterface
    public private(set) var errorCode: ARTCAICallErrorCode? = nil   // state == .Error 时有效
    
    public private(set) var state: CallState = .None {
        didSet {
            self.delegate?.onAICallEngineStateChanged?()
        }
    }
    
    public private(set) var robot: ARTCAICallRobotInfo? = nil
    public private(set) var robotState: RobotState = .Listening {
        didSet {
            self.delegate?.onAICallEngineRobotStateChanged?()
        }
    }
    
    private var activeSpeakerId: String? = nil

    public weak var delegate: ARTCAICallEngineDelegate?
    
    // 创建&开始通话
    open func start() {
        if self.state != .None {
            return
        }
        self.state = .Connecting
        
//        self.callService.getRtcAuthToken(channelId: "sdk", userId: self.userId) {[weak self] token, error in
//            if let token = token {
//                self?.rtcService.join(token: token) { error in
//                    self?.state = .Connected
//                    self?.rtcService.startPublish()
//                    self?.rtcService.enableSpeakerphone(enable: self?.config.enableSpeaker ?? true)
//                }
//            }
//            else {
//                self?.errorCode = .StartFailed
//                self?.state = .Error
//            }
//        }
        ARTCAICallRTCService.Debug_UpdateExtendInfo(key: "RobotId", value: self.config.robotId ?? "")

        self.callService.startRobot(userId: self.userId, config: self.config) {[weak self] robot, error in
            
            if self?.state == .Over {
                let instanceId = robot?.instanceId
                if instanceId != nil {
                    self?.callService.stopRobot(instanceId: instanceId!, completed: nil)
                }
                return
            }
            
            self?.robot = robot
            if let robot = robot {
                ARTCAICallRTCService.Debug_UpdateExtendInfo(key: "ChannelId", value: robot.channelId)
                ARTCAICallRTCService.Debug_UpdateExtendInfo(key: "UserId", value: robot.userId)
                ARTCAICallRTCService.Debug_UpdateExtendInfo(key: "InstanceId", value: robot.instanceId)

                self?.rtcService.join(token: robot.token, completed: { error in
                    
                    if self?.state == .Over {
                        return
                    }
                    
                    if let _ = error {
                        self?.errorCode = .StartFailed
                        self?.state = .Error
                        self?.callService.stopRobot(instanceId: robot.instanceId, completed: nil)
                    }
                    else {
                        self?.state = .Connected
                        self?.rtcService.startPublish()
                        self?.rtcService.switchMicrophone(off: self?.config.muteMicrophone ?? false)
                        self?.rtcService.enableSpeakerphone(enable: self?.config.enableSpeaker ?? true)
                    }
                })
            }
            else {
                self?.errorCode = .StartFailed
                self?.state = .Error
            }
        }
    }
    
    // 挂断
    open func handup() {
        if self.state != .None {
            if let robot = self.robot {
                self.callService.stopRobot(instanceId: robot.instanceId, completed: nil)
                self.rtcService.leave()
            }
            self.state = .Over
        }
    }
    
    open private(set) var isPause: Bool = false
    
    // 暂停通话
    open func pause() {
        if self.state == .Connected && self.isPause == false {
            self.isPause = true
            // TODO: 待实现
        }
    }
    
    // 继续通话
    open func resume() {
        if self.state == .Connected && self.isPause == true {
            self.isPause = false
            // TODO: 待实现
        }
    }
    
    // 打断机器人说话
    open func interruptSpeaking(completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            let model = ARTCAICallMessageSendModel()
            model.type = .InterruptSpeaking
            model.senderId = self.userId
            model.receiverId = self.robot?.userId
            model.data = nil
            self.callService.sendMessage(model: model) { error in
                if let error = error {
                    debugPrint("InterruptSpeaking Failed:\(error)")
                }
                else {
                    debugPrint("InterruptSpeaking Success")
                }
                completed?(error)
            }
        }
    }
    
    // 开启/关闭智能打断
    open func enableVoiceInterrupt(enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if let robot = self.robot {
                self.callService.enableVoiceInterrupt(instanceId: robot.instanceId, enable: enable) { [weak self] error in
                    if error == nil {
                        self?.config.enableVoiceInterrupt = enable
                    }
                    completed?(error)
                }
                return
            }
        }
        completed?(NSError.aicall_create(code: -1, message: "failed"))
    }
    
    // 切换音色
    open func switchRobotVoice(voiceId: String, completed: ((_ error: Error?) -> Void)?) {
        if self.state == .Connected {
            if let robot = self.robot {
                self.callService.changedVoice(instanceId: robot.instanceId, voiceId: voiceId) { [weak self] error in
                    if error == nil {
                        self?.config.robotVoiceId = voiceId
                    }
                    completed?(error)
                }
                return
            }
        }
        completed?(NSError.aicall_create(code: -1, message: "failed"))
    }
    
    
    // 开启/关闭扬声器
    open func enableSpeaker(enable: Bool) {
        self.config.enableSpeaker = enable
        self.rtcService.enableSpeakerphone(enable: enable)
    }
    
    // 开启/关闭麦克风
    open func switchMicrophone(off: Bool) {
        self.config.muteMicrophone = off
        self.rtcService.switchMicrophone(off: off)
    }
    
}

extension ARTCAICallEngine: ARTCAICallMessageDelegate {
    
    public func onReceivedMessage(model: ARTCAICallMessageReceiveModel) {
        if Thread.isMainThread == false {
            DispatchQueue.main.async {
                self.onReceivedMessage(model: model)
            }
            return
        }

        if model.type == .RobotStateChanged {
            if let state = model.data?["state"] as? Int32 {
                if let robotState = RobotState(rawValue: state) {
                    self.robotState = robotState
                }
            }
        }
        else if model.type == .RobotASRResult {
            if let text = model.data?["text"] as? String {
                debugPrint("Received ASR Text：\(text)")
            }
        }
        else if model.type == .RobotLLMSpeaking {
            if let text = model.data?["text"] as? String {
                debugPrint("Received LLM Text：\(text)")
            }
        }
    }
    
}

extension ARTCAICallEngine: ARTCAICallRTCDelegate {
    
    public func onJoined(userId: String) {
        
    }
    
    public func onLeaved(userId: String) {
        
    }
    
    public func onStartedPublish(userId: String) {
        
    }
    
    public func onStopedPublish(userId: String) {
        
    }
    
    public func onSpeakerActived(userId: String) {
        if Thread.isMainThread {
            if userId == "0" {
                self.activeSpeakerId = self.userId
            }
            else {
                self.activeSpeakerId = userId
            }
        }
        else {
            DispatchQueue.main.async {
                self.onSpeakerActived(userId: userId)
            }
        }
    }
    
    public func onAudioVolumeChanged(data: [String : Any]) {
        if Thread.isMainThread {
            guard let activeSpeakerId = self.activeSpeakerId else {
                return
            }
            var key = activeSpeakerId
            if activeSpeakerId == self.userId {
                key = "0"
            }
            let volume = data[key] as? Int32
            self.delegate?.onAICallEngineActiveSpeakerVolumeChanged?(userId: activeSpeakerId, volume: volume ?? 0)
        }
        else {
            DispatchQueue.main.async {
                self.onAudioVolumeChanged(data: data)
            }
        }
    }
    
    public func onTokenWillExpire(getNewTokenCompleted: ((String?, NSError?) -> Void)?) {
        guard let getNewTokenCompleted = getNewTokenCompleted else { return }
        if self.rtcService.isJoined {
            self.callService.getRtcAuthToken(channelId: self.robot?.channelId ?? "", userId: self.userId) { token, error in
                getNewTokenCompleted(token, error as? NSError)
            }
        }
        else {
            getNewTokenCompleted(nil, NSError.aicall_create(code: -1, message: "state error"))
        }
    }
    
    public func onOccurError(error: ARTCAICallRTCServiceError) {
        if Thread.isMainThread {
            var code: ARTCAICallErrorCode? = nil
            switch error {
            case .TokenExpired:
                code = .TokenExpired
                break
            case .PublishFailed:
                code = .ConnectionFailed
                break
            case .SubscribeFailed:
                code = .ConnectionFailed
                break
            case .ConnectionStatusFailed:
                code = .ConnectionFailed
                break
            case .ByeByUserReplaced:
                code = .kickedByUserReplace
                break
            case .ByeByKickedOut:
                code = .kickedBySystem
                break
            case .ByeByChannelTerminated:
                code = .kickedBySystem
                break
            case .LocalDeviceException:
                code = .LocalDeviceException
                break
            default:
                break
            }
            if let code = code {
                self.errorCode = code
                self.state = .Error
            }
        }
        else {
            DispatchQueue.main.async {
                self.onOccurError(error: error)
            }
        }
    }
}
