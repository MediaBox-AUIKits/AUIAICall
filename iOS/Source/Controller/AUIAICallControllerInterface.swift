//
//  AUIAICallControllerInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit
import ARTCAICallKit

@objcMembers open class AUIAICallConfig: NSObject {
    open var agentId: String? = nil                // 智能体Id
    open var agentType: ARTCAICallAgentType = .VoiceAgent // 智能体类型
    open var agentVoiceId: String = ""             // 智能体讲话音色Id
    open var agentAvatarId: String = ""            // 数字人模型Id
    open var agentGreeting: String? = nil          // 智能体欢迎语，AI智能体在用户入会后主动说的一句话
    open var region: String? = nil                 // 智能体服务所在的区域，如果为空，Appserver会使用默认的region来启动智能体服务
    open var enableVoiceInterrupt = true           // 是否开启智能打断
    open var enablePushToTalk = false              // 是否开启对讲机模式
    open var useVoiceprint = false                 // 当前断句是否使用声纹降噪识别
    open var voiceprintId: String? = nil           // 声纹Id，如果不为空表示当前通话开启声纹降噪能力，为空表示不启用声纹降噪能力
    open var enableSpeaker = true                  // 是否开启扬声器
    open var muteMicrophone = false                // 是否关闭麦克风（静音）
    open var muteLocalCamera = false               // 是否关闭摄像头
    open var limitSecond: UInt32 = 0               // 通话限制时间，为0表示不限制，否则通话时间到达秒数后，会自动结束通话
}

@objc public enum AUIAICallState: Int32 {
    case None            // 初始化
    case Connecting      // 接通中
    case Connected       // 通话中
    case Over            // 通话结束
    case Error           // 通话出错了
}

@objc public protocol AUIAICallControllerDelegate {
    
    /**
     * AI智能体已被启动
     */
    @objc optional func onAICallAIAgentStarted(agentInfo: ARTCAICallAgentInfo)
    
    /**
     * AI智能体开始通话
     */
    @objc optional func onAICallBegin()
    
    /**
     * AI智能体开始通话
     */
    @objc optional func onAICallAvatarFirstFrameDrawn()
    
    /**
     * 当前通话状态改变
     */
    @objc optional func onAICallStateChanged()
    
    /**
     * 智能体状态改变
     */
    @objc optional func onAICallAgentStateChanged()
    
    /**
     * 当前讲话Id及音量
     * @param userId 当前讲话人Id
     * @param volume 音量[0-255]
     */
    @objc optional func onAICallActiveSpeakerVolumeChanged(userId: String, volume: Int32)
    
    /**
     * 用户提问被智能体识别结果通知
     */
    @objc optional func onAICallUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult)
    
    /**
     * 智能体回答结果通知
     */
    @objc optional func onAICallAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int)
    
    /**
     * 当前通话的对讲机模式是否启用
     */
    @objc optional func onAICallAgentPushToTalkChanged(enable: Bool)
    
    /**
     * 用户Token过期
     */
    @objc optional func onAICallUserTokenExpired()
}

@objc public protocol AUIAICallControllerInterface {
    
    // 当前通话引擎
    var currentEngine: ARTCAICallEngineInterface {get}
    
    // 当前通话人Id
    var userId: String { get }
    
    // 当前通话配置
    var config: AUIAICallConfig { get }
    
    // 当前通话状态
    var state: AUIAICallState { get }
    
    // 当前错误码， state == .Error 时有效
    var errorCode: ARTCAICallErrorCode { get }
    
    // 当前智能体信息
    var agentInfo: ARTCAICallAgentInfo? { get }
    
    // 当前智能体状态
    var agentState: ARTCAICallAgentState { get }
    
    // 事件回调
    weak var delegate: AUIAICallControllerDelegate? { get set }
    
    // 创建&开始通话
    func start()
    
    // 挂断
    func handup()
    
    // 设置智能体渲染视图，及缩放模式
    func setAgentView(view: UIView?, mode: ARTCAICallAgentViewMode)
    
    // 打断智能体说话
    func interruptSpeaking()
    
    // 开启/关闭智能打断
    func enableVoiceInterrupt(enable: Bool, completed: ((_ error: Error?) -> Void)?)
    
    // 切换音色
    func switchVoiceId(voiceId: String, completed: ((_ error: Error?) -> Void)?)
    
    // 开启/关闭扬声器
    func enableSpeaker(enable: Bool)
    
    // 开启/关闭麦克风
    func muteMicrophone(mute: Bool)

    // 开启/关闭摄像头
    func muteLocalCamera(mute: Bool)
    
    // 切换前后摄像头
    func switchCamera()
    
    // 开启/关闭对讲机模式，对讲机模式下，只有在finishPushToTalk被调用后，智能体才会播报结果
    func enablePushToTalk(enable: Bool, completed: ((_ error: Error?) -> Void)?)
    
    // 开始讲话
    func startPushToTalk() -> Bool
    
    // 结束讲话
    func finishPushToTalk() -> Bool
    
    // 取消这次讲话
    func cancelPushToTalk() -> Bool

    // 当前声纹是否注册（邀测阶段，如需体验，请联系相关人员）
    var isVoiceprintRegisted: Bool { get }
    
    // 当前断句是否使用声纹降噪识别（邀测阶段，如需体验，请联系相关人员）
    func useVoiceprint(isUse: Bool, completed: ((_ error: Error?) -> Void)?)
    
    // 删除当前声纹数据（邀测阶段，如需体验，请联系相关人员）
    func clearVoiceprint() -> Bool
    
}
