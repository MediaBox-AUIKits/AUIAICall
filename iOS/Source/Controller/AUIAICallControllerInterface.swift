//
//  AUIAICallControllerInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit
import ARTCAICallKit

/**
 * 定义启动通话的配置
 */
@objcMembers open class AUIAICallConfig: NSObject {
    
    public override init() {
        super.init()
        self.agentConfig = ARTCAICallAgentConfig()
    }
    
    // =================== 启动通话智能体信息 ====================================
    open var agentId: String? = nil                // 智能体Id
    open var agentType: ARTCAICallAgentType = .VoiceAgent // 智能体类型
    open var expireSecond: UInt32 = 3600           // 用户入会后失效的时间，超过这个时间会触发onAICallUserTokenExpired事件
    open var limitSecond: UInt32 = 0               // 通话限制时间，为0表示不限制，否则通话时间到达秒数后，会自动结束通话
    open var region: String? = nil                 // 智能体服务所在的区域
    open var agentConfig: ARTCAICallAgentConfig!              // 智能体启动配置，该信息最终传给智能体
    open var userData: [String: Any]? = nil                   // 用户自定义信息，该信息最终传给智能体

    open var chatSyncConfig: ARTCAICallChatSyncConfig? = nil  // 关联的chat智能体配置，如果设置了，那么在通话过程中会把通话记录同步到chat智能体上
    
    // =================== 端侧设备控制能力 ====================================
    open var enableSpeaker = true                  // 是否开启扬声器
    open var muteMicrophone = false                // 是否关闭麦克风（静音）
    open var muteLocalCamera = false               // 是否关闭摄像头
    
    open func getWorkflowType() -> String {
        return ARTCAICallTemplateConfig.getTemplateConfigKey(self.agentType)
    }
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
     * RTC引擎被成功创建，可以在这个回调里调用getRTCInstance获取到rtc引擎实例
     */
    @objc optional func onAICallRTCEngineCreated()
    
    /**
     * AI智能体已被启动
     */
    @objc optional func onAICallAIAgentStarted(agentInfo: ARTCAICallAgentInfo, elapsedTime: TimeInterval)
    
    /**
     * AI智能体开始通话
     */
    @objc optional func onAICallBegin(elapsedTime: TimeInterval)
    
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
     * 智能体情绪结果通知
     * @param emotion 情绪标签，例如：neutral\happy\angry\sad 等
     * @param userAsrSentenceId 回答用户问题的句子ID
     */
    @objc optional func onAICallAgentEmotionNotify(emotion: String, userAsrSentenceId: Int)
    
    /**
     * 智能体即将结束通话 
     * @param reason 原因：2001(闲时退出) , 2002(真人接管结束)   0(其他)
     */
    @objc optional func onAICallAgentWillLeave(reason: Int32, message: String)
    
    /**
     * 当前通话的对讲机模式是否启用
     */
    @objc optional func onAICallAgentPushToTalkChanged(enable: Bool)
    
    /**
     * 当真人即将接管当前智能体
     */
    @objc optional func onAICallHumanTakeoverWillStart(takeoverUid: String, takeoverMode: Int)
    
    /**
     * 当真人接管已经接通
     */
    @objc optional func onAICallHumanTakeoverConnected(takeoverUid: String)
    
    /**
     * 当前Vision通话是否启用了自定义截帧模式
     */
    @objc optional func onAICallVisionCustomCapture(enable: Bool)
    
    /**
     * 当前智能体讲话被打断
     */
    @objc optional func onAICallSpeakingInterrupted(reason: ARTCAICallSpeakingInterruptedReason)
    
    /**
     * 用户Token过期
     */
    @objc optional func onAICallUserTokenExpired()
    
    /**
     * 收到当前智能体发过来VCR结果
     */
    @objc optional func onAICallReceivedAgentVcrResult(result: ARTCAICallAgentVcrResult)
    
    /**
     * 用户对话延时通知
     * @param sentenceId 对话ID。
     * @param delayMs 对话音频回环延迟（毫秒）
     *
     * User conversation delay notification
     * @param sentenceId The ID of the conversation.
     * @param delayMs The audio loopback delay of the conversation (in milliseconds).
     *
     */
    @objc optional func onAudioDelayInfo(sentenceId: Int32, delayMs: Int64)
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
    
    // 当前智能体音色列表
    var agentVoiceIdList: [String] { get }
    
    // 事件回调
    weak var delegate: AUIAICallControllerDelegate? { get set }
    
    // 创建&开始通话
    func start()
    
    // 挂断
    func handup()
    
    // 设置智能体渲染视图配置
    func setAgentViewConfig(viewConfig: ARTCAICallViewConfig?)
    
    // 打断智能体说话
    func interruptSpeaking()
    
    // 给智能体发送文本消息
    func sendTextToAgent(req: ARTCAICallSendTextToAgentRequest) -> Bool
    
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
