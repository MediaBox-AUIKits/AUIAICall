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
 * 智能体视图镜像模式
 */
@objc public enum ARTCAICallAgentViewMirrorMode: Int32 {
    
    /**
     * 只有前置摄像头预览镜像，其余不镜像
     */
    case OnlyFrontCameraPreviewEnabled = 0
    
    /**
     * 镜像都开启
     */
    case AllEnabled = 1
    
    /**
     * 镜像都关闭
     */
    case AllDisabled = 2
}

/**
 * 智能体视图旋转模式
 */
@objc public enum ARTCAICallAgentViewRotationMode: Int32 {
    
    /**
     * 视频视图旋转角度 - 0
     */
    case Rotation_0 = 0
    
    /**
     * 视频视图旋转角度 - 90
     */
    case Rotation_90 = 1
    
    /**
     * 视频视图旋转角度 - 180
     */
    case Rotation_180 = 2
    
    /**
     * 视频视图旋转角度 - 270
     */
    case Rotation_270 = 3
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
     * 发起通话，超出每天免费体验的额度
     */
    case AgentSubscriptionRequired = -10203
    
    /**
     * 智能体未能找到（智能体ID不存在）
     */
    case AgentNotFound = -10204
        
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
     * 智能体情绪结果通知
     * @param emotion 情绪标签，例如：neutral\happy\angry\sad 等
     * @param userAsrSentenceId 回答用户问题的句子ID
     */
    @objc optional func onAgentEmotionNotify(emotion: String, userAsrSentenceId: Int)
    
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
    
    /**
     * 当前智能体即将离开（结束当前通话）
     * @param reason 原因：2001(闲时退出) , 2002(真人接管结束)   0(其他)
     * @param message 描述原因
     */
    @objc optional func onAgentWillLeave(reason: Int32, message: String)
    
    /**
     * 收到当前智能体发过来的自定义消息
     * @param data 消息内容
     */
    @objc optional func onReceivedAgentCustomMessage(data: [String: Any]?)
    
    /**
     * 当真人即将接管当前智能体
     * @param takeoverUid 真人uid
     * @param takeoverMode 1：表示使用真人音色输出；0：表示使用智能体音色输出
     */
    @objc optional func onHumanTakeoverWillStart(takeoverUid: String, takeoverMode: Int)
    
    /**
     * 当真人接管已经接通
     * @param takeoverUid 真人uid
     */
    @objc optional func onHumanTakeoverConnected(takeoverUid: String)
    
    /**
     * 音频回环延迟
     *  @param idx 语句ID
     *  @param delayMs 延迟（毫秒）
     */
    @objc optional func onAudioDelayInfo(sentenceId: Int32, delayMs: Int64)

}


/**
 * 分享智能体配置信息
 */
@objcMembers open class ARTCAICallAgentShareConfig: NSObject {
    /**
     * 初始化
     */
    public init(shareId: String?, agentType: ARTCAICallAgentType, expireTime: Date?, templateConfig: String?, region: String?) {
        self.shareId = shareId
        self.agentType = agentType
        self.expireTime = expireTime
        self.templateConfig = templateConfig
        self.region = region
    }
    
    /**
     * 初始化
     */
    public convenience init(data: Dictionary<AnyHashable, Any>?) {
        let shareId = data?["TemporaryAIAgentId"] as? String
        let expireTime = (data?["ExpireTime"] as? String)?.aicall_parseDateString()

        var type = ARTCAICallAgentType.VoiceAgent
        if data?["WorkflowType"] as? String == "AvatarChat3D" {
            type = ARTCAICallAgentType.AvatarAgent
        }
        else if data?["WorkflowType"] as? String == "VisionChat" {
            type = ARTCAICallAgentType.VisionAgent
        }
        let templateConfig = data?["TemplateConfig"] as? String
        let region = data?["Region"] as? String
        self.init(shareId: shareId, agentType: type, expireTime: expireTime, templateConfig: templateConfig, region: region)
    }
    
    
    /**
     * 智能体分享ID
     */
    public let shareId: String?
    
    /**
     * 智能体工作量类型
     */
    public let agentType: ARTCAICallAgentType
    
    /**
     * 过期时间
     */
    public let expireTime: Date?
    
    /**
     * 服务所在区域
     */
    public let region: String?
    
    /**
     * 模板配置（Json字符串）
     */
    public var templateConfig: String? = nil
    
    /**
     * 用户自定义信息，该信息最终传给智能体
     */
    public var userData: [String: Any]? = nil

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
 * 智能体视图配置，当智能体需要渲染时（例如：数字人）需要通过该类进行设置
 */
@objcMembers open class ARTCAICallViewConfig: NSObject {
    
    /**
     * 初始化
     */
    public init(view: UIView,
                viewMode: ARTCAICallAgentViewMode = .Auto,
                viewMirrorMode: ARTCAICallAgentViewMirrorMode = .OnlyFrontCameraPreviewEnabled,
                viewRotationMode: ARTCAICallAgentViewRotationMode = .Rotation_0) {
        self.view = view
        self.viewMode = viewMode
        self.viewMirrorMode = viewMirrorMode
        self.viewRotationMode = viewRotationMode
    }
    
    /**
     * 渲染视图
     */
    public let view: UIView
    
    /**
     * 画面渲染模式
     */
    public let viewMode: ARTCAICallAgentViewMode
    
    /**
     * 画面镜像模式
     */
    public let viewMirrorMode: ARTCAICallAgentViewMirrorMode
    
    /**
     * 画面旋转模式
     */
    public let viewRotationMode: ARTCAICallAgentViewRotationMode
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
                viewMirrorMode: ARTCAICallAgentViewMirrorMode = .OnlyFrontCameraPreviewEnabled,
                viewRotationMode: ARTCAICallAgentViewRotationMode = .Rotation_0,
         dimensions: CGSize = CGSize(width: 360, height: 640),
         frameRate: Int = 15,
         bitrate: Int = 512,
         keyFrameInterval: Int = 1000) {
        self.preview = preview
        self.viewMode = viewMode
        self.viewMirrorMode = viewMirrorMode
        self.viewRotationMode = viewRotationMode
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
     * 预览画面镜像模式
     */
    public let viewMirrorMode: ARTCAICallAgentViewMirrorMode
    
    /**
     * 预览画面旋转模式
     */
    public let viewRotationMode: ARTCAICallAgentViewRotationMode
    
    /**
     * 推流分辨率
     */
    public let dimensions: CGSize
    
    /**
     * 推流帧率
     */
    public let frameRate: Int
    
    /**
     * 推流码率
     */
    public let bitrate: Int
    
    /**
     * 推流关键帧间隔（毫秒）
     */
    public let keyFrameInterval: Int
    
    /**
     * 是否使用高清预览，否则SDK根据推流分辨率自动调整
     */
    public var useHighQualityPreview: Bool = true
    
    /**
     * 预览分辨率
     */
    public let cameraCaptureFrameRate: Int = 15
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
     * 设置智能体渲染视图及渲染模式，当智能体有画面渲染时需要设置（当前仅针对数字人有效）
     */
    @available(*, deprecated, message: "Use 'setAgentViewConfig(viewConfig: ARTCAICallViewConfig?)' instead.")
    func setAgentView(view: UIView?, mode: ARTCAICallAgentViewMode)
    
    /**
     * 设置智能体渲染视图配置，当智能体有画面渲染时需要设置（当前仅针对数字人有效）
     */
    func setAgentViewConfig(viewConfig: ARTCAICallViewConfig?)
        
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
    
    
    /**
     * 解析一个分享的智能体信息
     */
    func parseShareAgentCall(shareInfo: String) -> ARTCAICallAgentShareConfig?
    
    /**
     * 启动一个分享的智能体通话
     */
    func generateShareAgentCall(shareConfig: ARTCAICallAgentShareConfig, userId: String, completed: ((_ rsp: ARTCAICallAgentInfo?, _ token: String?, _ error: NSError?, _ reqId: String) -> Void)?)
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
