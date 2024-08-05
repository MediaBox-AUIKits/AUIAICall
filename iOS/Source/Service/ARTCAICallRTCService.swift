//
//  ARTCAICallRTCService.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

#if canImport(AliVCSDK_ARTC)
import AliVCSDK_ARTC
#elseif canImport(AliVCSDK_InteractiveLive)
import AliVCSDK_InteractiveLive
#elseif canImport(AliVCSDK_Standard)
import AliVCSDK_Standard
#elseif canImport(AliRTCSdk)
import AliRTCSdk
#endif


@objc public protocol ARTCAICallRTCBridgeDelegate {
    
    @objc optional func onSetupRtcEngine(rtcEngine: AnyObject?)
    @objc optional func onWillReleaseEngine()
    @objc optional func onDataChannelMessage(uid: String, controlMsg: AnyObject)
}

@objc public enum ARTCAICallRTCServiceError: Int32 {
    case TokenExpired
    case PublishFailed
    case SubscribeFailed
    case ConnectionStatusFailed
    case ByeByUserReplaced
    case ByeByKickedOut
    case ByeByChannelTerminated
    case LocalDeviceException
}

@objc public protocol ARTCAICallRTCDelegate {
    
    @objc optional func onJoined(userId: String)
    @objc optional func onLeaved(userId: String)

    @objc optional func onStartedPublish(userId: String)
    @objc optional func onStopedPublish(userId: String)
    
    @objc optional func onAudioVolumeChanged(data: [String: Any])
    @objc optional func onSpeakerActived(userId: String)
    
    @objc optional func onTokenWillExpire(getNewTokenCompleted: ((_ token: String?, _ error: NSError?) -> Void)?)
    @objc optional func onOccurError(error: ARTCAICallRTCServiceError)
}

@objcMembers open class ARTCAICallRTCService: NSObject {
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    public func destroy() {
        self.leave()
        self.destroyRtcEngine()
    }
        
    public weak var bridgeDelegate: ARTCAICallRTCBridgeDelegate? = nil
    public weak var delegate: ARTCAICallRTCDelegate? = nil

    private var rtcEngine: AliRtcEngine? = nil
    public func getRTCEngine() -> AnyObject? {
        return self.rtcEngine
    }
    
    private func setupRtcEngine() {
        if self.rtcEngine != nil {
            return
        }
        
        var extras: [String: Any] = [:]
        if ARTCAICallRTCService.Debug_IsEnableDumpData {
            extras.updateValue("TRUE", forKey: "user_specified_audio_dump")
        }
        if ARTCAICallRTCService.Debug_IsEnableTipsData {
            extras.updateValue("TRUE", forKey: "user_specified_audio_tips")
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
        engine.setClientRole(AliRtcClientRole.rolelive)
        
        
        // 音频配置
        engine.setAudioSessionOperationRestriction(AliRtcAudioSessionOperationRestriction.none)
        engine.setAudioProfile(AliRtcAudioProfile.engineHighQualityMode, audio_scene: AliRtcAudioScenario.sceneChatroomMode)
        engine.enableAudioVolumeIndication(500, smooth: 3, reportVad: 1)
        engine.enableSpeakerphone(true)
        engine.setDefaultSubscribeAllRemoteAudioStreams(true)
        engine.subscribeAllRemoteAudioStreams(true)
        
        // 推流配置
        engine.publishLocalVideoStream(false)
        engine.publishLocalAudioStream(false)
        
        if let debugView = ARTCAICallRTCService.Debug_TipsView {
            engine.showDebugView(debugView, show: .typeAll, userId: "")
        }
        
        self.rtcEngine = engine
        self.bridgeDelegate?.onSetupRtcEngine?(rtcEngine: engine)
    }
    
    private func destroyRtcEngine() {
        ARTCAICallRTCService.Debug_ClearTipsData()
        self.bridgeDelegate?.onWillReleaseEngine?()
        AliRtcEngine.destroy()
        self.rtcEngine = nil
    }
    
    public private(set) var isJoined: Bool = false
    
    public func join(token: String, completed: ((_ error: NSError?) -> Void)? = nil) -> Void {
        self.setupRtcEngine()
        self.rtcEngine?.joinChannel(token, channelId: nil, userId: nil, name: nil) { [weak self] errCode, channel, userId, elapsed in
            var err : NSError? = nil
            if errCode != 0 {
                debugPrint("ARTCAICallRTCService joinChannel failed:\(errCode)")
                err = NSError.aicall_create(code: errCode, message: "join channel failed")
            }
            else {
                self?.isJoined = true
            }
            completed?(err)
        }
    }
    
    public func leave() {
        self.stopPublish()
        self.rtcEngine?.leaveChannel()
        self.isJoined = false
    }

    public private(set) var isPublishing: Bool = false
    
    public func startPublish() {
        if self.isJoined == false {
            return
        }
        self.rtcEngine?.startAudioCapture()
        self.rtcEngine?.setClientRole(AliRtcClientRole.roleInteractive)
        self.rtcEngine?.publishLocalAudioStream(true)
        self.isPublishing = true
    }
    
    public func stopPublish() {
        self.isPublishing = false
        self.rtcEngine?.publishLocalAudioStream(false)
        self.rtcEngine?.setClientRole(AliRtcClientRole.rolelive)
        self.rtcEngine?.stopAudioCapture()
    }
    
    // 打开或关闭我的麦克风
    public func switchMicrophone(off: Bool) {
        self.rtcEngine?.muteLocalMic(off, mode: .allAudioMode)
//        if off {
//            self.rtcEngine?.stopAudioCapture()
//        }
//        else {
//            self.rtcEngine?.startAudioCapture()
//        }
    }
    
    // 禁音远端用户
    public func muteRemoteUser(mute: Bool, uid: String) {
        self.rtcEngine?.setRemoteAudioVolume(uid, volume: mute ? 0 : 100)
    }
    
    public func enableSpeakerphone(enable: Bool) {
        self.rtcEngine?.enableSpeakerphone(enable)
    }
    
    public func isEnableSpeakerphone() -> Bool {
        let enable = self.rtcEngine?.isEnableSpeakerphone()
        guard let enable = enable else {
            return true
        }
        return enable
    }
}

extension ARTCAICallRTCService: AliRtcEngineDelegate {
    
    public func onDataChannelMessage(_ uid: String, controlMsg: AliRtcDataChannelMsg) {
        self.bridgeDelegate?.onDataChannelMessage?(uid: uid, controlMsg: controlMsg)
    }
    
    public func onJoinChannelResult(_ result: Int32, channel: String, userId: String, elapsed: Int32) {
        debugPrint("ARTCAICallRTCService onJoinChannelResult:\(result) channel:\(channel) userId:\(userId)")
    }
    
    public func onJoinChannelResult(_ result: Int32, channel: String, elapsed: Int32) {
        debugPrint("ARTCAICallRTCService onJoinChannelResult:\(result) channel:\(channel)")
    }
    
    public func onLeaveChannelResult(_ result: Int32, stats: AliRtcStats) {
        debugPrint("ARTCAICallRTCService onLeaveChannelResult")

    }
    
    public func onRemoteUser(onLineNotify uid: String, elapsed: Int32) {
        debugPrint("ARTCAICallRTCService onRemoteUserOnLineNotify:\(uid)")
        self.delegate?.onJoined?(userId: uid)
    }
    
    public func onRemoteUserOffLineNotify(_ uid: String, offlineReason reason: AliRtcUserOfflineReason) {
        debugPrint("ARTCAICallRTCService onRemoteUserOffLineNotify:\(uid)")
        self.delegate?.onLeaved?(userId: uid)
    }
    
    public func onRemoteTrackAvailableNotify(_ uid: String, audioTrack: AliRtcAudioTrack, videoTrack: AliRtcVideoTrack) {
        debugPrint("ARTCAICallRTCService onRemoteTrackAvailableNotify:\(uid)  videoTrack:\(videoTrack)")
        if audioTrack == AliRtcAudioTrack.no {
            self.delegate?.onStopedPublish?(userId: uid)
        }
        else {
            self.delegate?.onStartedPublish?(userId: uid)
        }
    }
    
    public func onUserAudioMuted(_ uid: String, audioMuted isMute: Bool) {
        debugPrint("ARTCAICallRTCService onUserAudioMuted:\(uid) isMute:\(isMute)")
    }
    
    public func onNetworkQualityChanged(_ uid: String, up upQuality: AliRtcNetworkQuality, downNetworkQuality downQuality: AliRtcNetworkQuality) {
        debugPrint("ARTCAICallRTCService onNetworkQualityChanged:\(uid) upQuality:\(upQuality.rawValue)  downQuality:\(downQuality.rawValue)")
    }
    

    public func onConnectionStatusChange(_ status: AliRtcConnectionStatus, reason: AliRtcConnectionStatusChangeReason) {
        debugPrint("ARTCAICallRTCService onConnectionStatusChange:\(status.rawValue) reason:\(reason.rawValue)")
        if status == AliRtcConnectionStatus.failed {
            self.delegate?.onOccurError?(error: .ConnectionStatusFailed)
        }
    }
    
    public func onOccurError(_ error: Int32, message: String) {
        debugPrint("ARTCAICallRTCService onOccurError:\(error) message:\(message)")
//        if error == AliRtcErrorCode.errPublishInvaild.rawValue ||
//            error == AliRtcErrorCode.errPublishAudioStreamFailed.rawValue {
//            self.delegate?.onOccurError?(error: .PublishFailed)
//        }
//        else if error == AliRtcErrorCode.errSubscribeInvaild.rawValue ||
//            error == AliRtcErrorCode.errSubscribeAudioStreamFailed.rawValue {
//            self.delegate?.onOccurError?(error: .SubscribeFailed)
//        }
    }
    
    public func onOccurWarning(_ warn: Int32, message: String) {
        debugPrint("ARTCAICallRTCService onOccurWarning:\(warn) message:\(message)")
        
    }
    
    public func onLocalDeviceException(_ deviceType: AliRtcLocalDeviceType, exceptionType: AliRtcLocalDeviceExceptionType, message msg: String?) {
        debugPrint("ARTCAICallRTCService onLocalDeviceException:\(deviceType) exceptionType:\(exceptionType) message\(msg ?? "unknown")")
        self.delegate?.onOccurError?(error: .LocalDeviceException)
    }
    
    public func onBye(_ code: Int32) {
        debugPrint("ARTCAICallRTCService onBye\(code)")
        self.isJoined = false
        if code == AliRtcOnByeType.userReplaced.rawValue {
            self.delegate?.onOccurError?(error: .ByeByUserReplaced)
        }
        else if code == AliRtcOnByeType.beKickedOut.rawValue {
            self.delegate?.onOccurError?(error: .ByeByKickedOut)
        }
        else if code == AliRtcOnByeType.channelTerminated.rawValue {
            self.delegate?.onOccurError?(error: .ByeByChannelTerminated)
        }
    }
    
    public func onAuthInfoWillExpire() {
        debugPrint("ARTCAICallRTCService onAuthInfoWillExpire")
        self.delegate?.onTokenWillExpire?(getNewTokenCompleted: {[weak self] token, error in
            if let token = token, let self = self {
                self.rtcEngine?.refreshAuthInfo(withToken: token)
            }
        })
    }
    
    public func onAuthInfoExpired() {
        debugPrint("ARTCAICallRTCService onAuthInfoExpired")
        self.delegate?.onOccurError?(error: .TokenExpired)
    }
    
    public func onActiveSpeaker(_ uid: String) {
        debugPrint("ARTCAICallRTCService onActiveSpeaker:\(uid)")
        self.delegate?.onSpeakerActived?(userId: uid)
    }
    
    public func onAudioVolumeCallback(_ array: [AliRtcUserVolumeInfo]?, totalVolume: Int32) {
        if let delegate = self.delegate {
            var data = [String: Any]()
            array?.forEach({ info in
//                debugPrint("ARTCAICallRTCService onAudioVolumeCallback:\(info.uid)  speech_state:\(info.speech_state)  volume:\(info.volume)  ")
                if info.speech_state == true {
                    data[info.uid] = info.volume
                }
            })
            delegate.onAudioVolumeChanged?(data: data)
        }
    }
    
    public func onRtcStats(_ stats: AliRtcStats) {
        ARTCAICallRTCService.Debug_UpdateExtendInfo(key: "RTCStats", value: stats)
    }
}

// 开发者相关
extension ARTCAICallRTCService {
    
    public static var Debug_IsEnableDumpData: Bool = false
    
    public static var Debug_IsEnableTipsData: Bool = false
    public static var Debug_TipsView: UITextView? = nil

    public static var Debug_IsEnableExtendData: Bool = false {
        didSet {
            if self.Debug_IsEnableExtendData == false {
                self.Debug_ExtendInfo.removeAll()
                NotificationCenter.default.post(name: NSNotification.Name("DebugExtentInfoUpdate"), object: nil, userInfo: self.Debug_ExtendInfo)
            }
        }
    }
    
    public static var Debug_ExtendInfo: [String: String] = [:]
    
    public static func Debug_UpdateExtendInfo(key: String, value: Any) {
        if Debug_IsEnableExtendData == false {
            self.Debug_ExtendInfo.removeAll()
            return
        }
        
        var post = false
        if let value = value as? String {
            self.Debug_ExtendInfo.updateValue(value, forKey: key)
            post = true
        }
        
        if let stat = value as? AliRtcStats {
            var info: [String: String] = [:]
            info.updateValue(String(stat.available_sent_kbitrate), forKey: "可用带宽(kb) ")
            info.updateValue(String(stat.sent_kbitrate), forKey: "总发送码率(kb) ")
            info.updateValue(String(stat.rcvd_kbitrate), forKey: "总接收码率(kb) ")
            info.updateValue(String(stat.sent_bytes), forKey: "总发送数据量(bytes)")
            info.updateValue(String(stat.rcvd_bytes), forKey: "总接收数据量(bytes) ")
            info.updateValue(String(stat.video_rcvd_kbitrate), forKey: "视频接受码率(kb) ")
            info.updateValue(String(stat.video_sent_kbitrate), forKey: "视频发送码率(kb)")
            info.updateValue(String(stat.call_duration), forKey: "通话时长(s) ")
            info.updateValue(String(stat.cpu_usage), forKey: "进程CPU使用量(%)")
            info.updateValue(String(stat.systemCpuUsage), forKey: "系统CPU使用量(%) ")
            info.updateValue(String(stat.sent_loss_rate), forKey: "客户端到服务器的丢包率(%)")
            info.updateValue(String(stat.sent_loss_pkts), forKey: "客户端到服务器的丢包数")
            info.updateValue(String(stat.sent_expected_pkts), forKey: "客户端到服务器的总包数")
            info.updateValue(String(stat.rcvd_loss_rate), forKey: "服务器到客户端的下行丢包率（%）")
            info.updateValue(String(stat.rcvd_loss_pkts), forKey: "服务器到客户端的下行丢包数")
            info.updateValue(String(stat.rcvd_expected_pkts), forKey: "服务器到客户端的下行总包数")
            info.updateValue(String(stat.lastmile_delay), forKey: "客户端到服务器的延迟(ms)")
            self.Debug_ExtendInfo.merge(info)  { (_, new) in new }
            post = true
        }
        
        if post == true {
//            debugPrint("Debug Extent Info:\(self.Debug_ExtendInfo)")
            NotificationCenter.default.post(name: NSNotification.Name("DebugExtentInfoUpdate"), object: nil, userInfo: self.Debug_ExtendInfo)
        }
    }
    
    private static func Debug_ClearTipsData() {
        self.Debug_TipsView?.text = nil
        self.Debug_ExtendInfo.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name("DebugExtentInfoUpdate"), object: nil, userInfo: self.Debug_ExtendInfo)
    }
}
