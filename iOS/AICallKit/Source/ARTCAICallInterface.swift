//
//  ARTCAICallInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/8/7.
//

import UIKit


/**
 * 智能体类型
 */
@objc public enum ARTCAICallAgentType: Int32 {
    
    /**
     * 纯语音
     */
    case VoiceAgent = 0
    
    /**
     * 数字人
     */
    case AvatarAgent
    
    /**
     * 视觉理解
     */
    case VisionAgent
}

/**
 * 智能体状态
 */
@objc public enum ARTCAICallAgentState: Int32 {
    
    /**
     * 聆听中
     */
    case Listening = 1
    
    /**
     * 思考中
     */
    case Thinking = 2
    
    /**
     * 讲话中
     */
    case Speaking = 3
}

/**
 * 智能体视图渲染模式
 */
@objc public enum ARTCAICallAgentViewMode: Int32 {
    
    /**
     * 自动模式
     */
    case Auto = 0
    
    /**
     * 延伸模式
     */
    case Stretch = 1
    
    /**
     * 填充模式
     */
    case Fill = 2
    
    /**
     * 裁剪模式
     */
    case Crop = 3
}

/**
 * 网络状态
 */
@objc public enum ARTCAICallNetworkQuality: Int32 {
    
    /**
     * 网络极好，流程度清晰度质量好
     */
    case Excellent = 0
    
    /**
     * 网络好，流畅度清晰度和极好差不多
     */
    case Good = 1
    
    /**
     * 网络有点差，音视频流畅度清晰度有瑕疵，不影响沟通
     */
    case Poor = 2
    
    /**
     * 网络差，视频卡顿严重，音频能正常沟通
     */
    case Bad = 3
    
    /**
     * 网络极差，基本无法沟通
     */
    case VeryBack = 4
    
    /**
     * 网络中断
     */
    case Disconnect = 5
    
    /**
     * 未知
     */
    case Unknow = 6
}

/**
 * 声纹降噪反馈结果
 */
@objc public enum ARTCAICallVoiceprintResult: Int32 {

    /**
     * 没开启声纹降噪
     */
    case Off = 0
    
    /**
     * 开启了，还未注册
     */
    case Unregister = 1
    
    /**
     * 开启了，识别到主讲人
     */
    case DetectedSpeaker = 2
    
    /**
     * 开启了，没识别到主讲人
     */
    case UndetectedSpeaker = 3
}

/**
 * 错误码
 */
@objc public enum ARTCAICallErrorCode: Int32 {
    /**
     * 成功
     */
    case None = 0
    
    /**
     * 操作无效
     */
    case InvalidAction = -1
    
    /**
     * 参数错误
     */
    case InvalidParames = -2
    
    /**
     * 启动通话失败
     */
    case BeginCallFailed = -10000
    
    /**
     * 链接出现问题
     */
    case ConnectionFailed = -10001
    
    /**
     * 推流失败
     */
    case PublishFailed = -10002
    
    /**
     * 拉流失败
     */
    case SubscribeFailed = -10003
    
    /**
     * 通话认证过期
     */
    case TokenExpired = -10004
    
    /**
     * 同名登录导致通话无法进行
     */
    case KickedByUserReplace = -10005
    
    /**
     * 被系统踢出导致通话无法进行
     */
    case KickedBySystem = -10006
    
    /**
     * 频道被销毁导致通话无法进行
     */
    case KickedByChannelTerminated = -10007
    
    /**
     * 本地设备问题导致无法进行
     */
    case LocalDeviceException = -10008
    
    /**
    * 智能体离开频道了（智能体结束通话）
    */
   case AgentLeaveChannel = -10101
    
    /**
     * 智能体拉流失败了
     */
    case AgentPullFailed = -10102
    
    /**
     * 智能体ASR失败
     */
    case AgentASRFailed = -10103
    
    /**
     * 数字智能体服务启动失败
     */
    case AvatarServiceFailed = -10201
    
    /**
     * 数字智能体超出并发路数
     */
    case AvatarRoutesExhausted = -10202
    
    /**
     * 未知错误
     */
    case UnknowError = -40000
}

/**
 * 回调
 */
@objc public protocol ARTCAICallEngineDelegate {
    
    /**
     * 发生了错误
     * @param code 错误码
     */
    @objc optional func onErrorOccurs(code: ARTCAICallErrorCode)
    
    /**
     * 通话开始（入会）
     */
    @objc optional func onCallBegin()
    
    /**
     * 通话结束（离会）
     */
    @objc optional func onCallEnd()
    
    /**
     * 智能体视频是否可用（推流）
     * @param available 是否可用
     */
    @objc optional func onAgentVideoAvailable(available: Bool)
    
    /**
     * 智能体音频是否可用（推流）
     * @param available 是否可用
     */
    @objc optional func onAgentAudioAvailable(available: Bool)
    
    /**
     * 智能体数字人首帧渲染
     */
    @objc optional func onAgentAvatarFirstFrameDrawn()
    
    /**
     * 智能体状态改变
     * @param state 当前智能体状态
     */
    @objc optional func onAgentStateChanged(state: ARTCAICallAgentState)
    
    /**
     * 网络状态改变
     * @param uid 当前讲话人的Id
     * @param quality 网络质量
     */
    @objc optional func onNetworkStatusChanged(uid: String, quality: ARTCAICallNetworkQuality)
    
    
    /**
     * 音量变化通知
     * @param uid 当前讲话人的uid
     * @param volume 音量[0-255]
     */
    @objc optional func onVoiceVolumeChanged(uid: String, volume: Int32)
    
    
    
    /**
     * 用户提问被智能体识别结果的通知
     * @param text 被智能体识别出的提问文本
     * @param isSentenceEnd 当前文本是否为这句话的最终结果
     * @param sentenceId 当前文本属于的句子ID
     */
    @available(*, deprecated, message: "Use 'onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprint: Int32)' instead.")
    @objc optional func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int)
    
    /**
     * 用户提问被智能体识别结果的通知
     * @param text 被智能体识别出的提问文本
     * @param isSentenceEnd 当前文本是否为这句话的最终结果
     * @param sentenceId 当前文本属于的句子ID
     * @param voiceprintResult 当前声纹降噪识别结果反馈
     */
    @objc optional func onUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult)
    
    /**
     * 智能体回答结果通知
     * @param text 智能体回答的文本
     * @param isSentenceEnd 当前文本是否为此次回答的最后一句
     * @param userAsrSentenceId 回答用户问题的句子ID
     */
    @objc optional func onVoiceAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int)
    
    /**
     * 当前通话的音色发生了改变
     * @param voiceId 当前音色Id
     */
    @objc optional func onVoiceIdChanged(voiceId: String)
    
    /**
     * 当前通话的语音打断是否启用
     * @param enable 是否启用
     */
    @objc optional func onVoiceInterrupted(enable: Bool)
    
    /**
     * 当前通话的对讲机模式是否启用
     * @param enable 是否启用
     */
    @objc optional func onPushToTalk(enable: Bool)
    
    /**
     * 当前通话的声纹降噪是否启用
     * 邀测阶段，如需体验，请联系相关人员
     * @param enable 是否启用
     */
    @objc optional func onVoiceprint(enable: Bool)
    
    /**
     * 当前通话的声纹数据被清除
     * 邀测阶段，如需体验，请联系相关人员
     */
    @objc optional func onVoiceprintCleared()
}

/**
 * 智能体运行时信息
 */
@objcMembers open class ARTCAICallAgentInfo: NSObject {
    
    /**
     * 初始化
     */
    public init(agentType: ARTCAICallAgentType, channelId: String, uid: String, instanceId: String) {
        self.agentType = agentType
        self.channelId = channelId
        self.uid = uid
        self.instanceId = instanceId
    }
    
    /**
     * 初始化
     */
    public convenience init(data: Dictionary<AnyHashable, Any>?) {
        let agent_instance_id = data?["ai_agent_instance_id"] as? String
        let channel_id = data?["channel_id"] as? String
        let ai_agent_user_id = data?["ai_agent_user_id"] as? String
        
        var type = ARTCAICallAgentType.VoiceAgent
        if data?["workflow_type"] as? String == "AvatarChat3D" {
            type = ARTCAICallAgentType.AvatarAgent
        }
        else if data?["workflow_type"] as? String == "VisionChat" {
            type = ARTCAICallAgentType.VisionAgent
        }
        self.init(agentType: type, channelId: channel_id ?? "", uid: ai_agent_user_id ?? "", instanceId: agent_instance_id ?? "")
    }
    
    /**
     * 智能体工作量类型
     */
    public let agentType: ARTCAICallAgentType
    
    /**
     * 智能体所在的RTC频道ID
     */
    public let channelId: String
    
    /**
     * 智能体进入RTC频道的唯一标识
     */
    public let uid: String
    
    /**
     * 当前智能体运行的实例ID
     */
    public let instanceId: String
}

/**
 * 视频理解智能体运行配置
 */
@objcMembers open class ARTCAICallVisionConfig: NSObject {
    
    /**
     * 初始化
     */
    public init(preview: UIView? = nil,
         viewMode: ARTCAICallAgentViewMode = .Auto,
         dimensions: CGSize = CGSize(width: 360, height: 640),
         frameRate: Int = 15,
         bitrate: Int = 512,
         keyFrameInterval: Int = 1000) {
        self.preview = preview
        self.viewMode = viewMode
        self.dimensions = dimensions
        self.frameRate = frameRate
        self.bitrate = bitrate
        self.keyFrameInterval = keyFrameInterval
    }
    
    /**
     * 预览，为空表示不预览只推流
     */
    public let preview: UIView?
    
    /**
     * 预览画面渲染模式
     */
    public let viewMode: ARTCAICallAgentViewMode
    
    /**
     * 分辨率
     */
    public let dimensions: CGSize
    
    /**
     * 帧率
     */
    public let frameRate: Int
    
    /**
     * 帧率
     */
    public let bitrate: Int
    
    /**
     * 关键帧间隔（毫秒）
     */
    public let keyFrameInterval: Int
}

/**
 * 引擎接口
 */
@objc public protocol ARTCAICallEngineInterface {
    
    /**
     * 获取当前通话的UserId
     */
    var userId: String? {get}
    
    /**
     * 是否通话中, 从接通后到挂断或出错前为true，其他为false
     */
    var isOnCall: Bool { get }
    
    /**
     * 获取当前智能体信息
     */
    var agentInfo: ARTCAICallAgentInfo? { get }

    /**
     * 视觉配置，VisionAgent时，在通话前设置才能生效，
     */
    var visionConfig: ARTCAICallVisionConfig { set get }
    
    /**
     * 获取当前智能体状态
     */
    var agentState: ARTCAICallAgentState { get }
    
    /**
     * 设置和获取回调事件
     */
    weak var delegate: ARTCAICallEngineDelegate? { get set }
    
    /**
     * 开始通话
     */
    func call(userId: String, token: String, agentInfo: ARTCAICallAgentInfo, completed:((_ error: NSError?) -> Void)?)
    
    /**
     * 挂断
     */
    func handup(_ stopAIAgent: Bool)
    
    /**
     * 设置智能体渲染视图，及缩放模式，AvatarAgent时有效
     */
    func setAgentView(view: UIView?, mode: ARTCAICallAgentViewMode)
        
    /**
     * 打断智能体讲话
     */
    func interruptSpeaking() -> Bool
    
    /**
     * 开启/关闭智能打断
     */
    func enableVoiceInterrupt(enable: Bool) -> Bool
    
    /**
     * 切换音色
     */
    func switchVoiceId(voiceId: String) -> Bool
    
    /**
     * 开启/关闭扬声器
     */
    func enableSpeaker(enable: Bool) -> Bool
    
    /**
     * 静音/取消禁音麦克风
     */
    func muteMicrophone(mute: Bool) -> Bool
    
    /**
     * 关闭/取消关闭摄像头，VisionAgent时有效
     */
    func muteLocalCamera(mute: Bool) -> Bool
    
    /**
     * 切换前后摄像头，VisionAgent时有效
     */
    func switchCamera() -> Bool
    
    /**
     * 开启/关闭对讲机模式，对讲机模式下，只有在finishPushToTalk被调用后，智能体才会播报结果
     */
    func enablePushToTalk(enable: Bool) -> Bool
    
    /**
     * 开始讲话
     */
    func startPushToTalk() -> Bool
    
    /**
     * 结束讲话
     */
    func finishPushToTalk() -> Bool
    
    /**
     * 取消这次讲话
     */
    func cancelPushToTalk() -> Bool
    
    /**
     * 当前断句是否使用声纹降噪识别
     * 邀测阶段，如需体验，请联系相关人员
     */
    func useVoiceprint(isUse: Bool) -> Bool
    
    /**
     * 清除当前声纹数据
     * 邀测阶段，如需体验，请联系相关人员
     */
    func clearVoiceprint() -> Bool
    
    /**
     * 获取RTC引擎
     */
    func getRTCInstance() -> AnyObject?
    
    /**
     * 释放资源
     */
    func destroy()
}

/**
 * 引擎工厂
 */
@objcMembers open class ARTCAICallEngineFactory: NSObject {
    
    /**
     * 创建默认的AICallEngine
     */
    public static func createEngine() -> ARTCAICallEngineInterface {
        let engine = ARTCAICallEngine()
        return engine
    }
}
