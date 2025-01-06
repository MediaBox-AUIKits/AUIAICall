//
//  ARTCAICallTemplateConfig.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/11.
//

import UIKit


/**
 * 用于启动通话的TemplateConfig参数
 * 参考：https://help.aliyun.com/zh/ims/developer-reference/api-ice-2020-11-09-generateaiagentcall
 */
@objcMembers open class ARTCAICallTemplateConfig: NSObject {
    
    /**
     * 智能体欢迎语，为空表示使用智能体配置值
     */
    open var agentGreeting: String? = nil
    
    /**
     * 用户未入会，智能体超时关闭任务的时间，小于0则使用服务端默认值60s
     */
    open var userOnlineTimeout: Int32 = -1
    
    /**
     * 用户退会后，智能体超时关闭任务的时间，小于0则使用服务端默认值5s
     */
    open var userOfflineTimeout: Int32 = -1
    
    /**
     * 工作流覆盖参数
     */
    open var workflowOverrideParams: [String: Any]? = nil
    
    /**
     * 百炼应用中心参数
     */
    open var bailianAppParams: [String: Any]? = nil
    
    /**
     * 语音断句检测阈值，静音时长超过该阈值会被认为断句，参数范围 200ms～1200ms，，小于0则使用服务端默认值400ms
     */
    open var asrMaxSilence: Int32 = -1
    
    /**
     * 智能体说话的音量，范围为 0~400，输出音量=工作流中的语音输出音量 * volume/100，小于0则使用服务端默认值100
     */
    open var volume: Int32 = -1
    
    /**
     * 是否开启智能打断
     */
    open var enableVoiceInterrupt = true
    
    /**
     * 智能体讲话音色Id，为空表示使用智能体配置值
     */
    open var agentVoiceId: String? = nil
    
    /**
     * 智能断句开关，开启智能断句后，用户说话的发生断句会智能合并成一句
     */
    open var enableIntelligentSegment = true
    
    /**
     * 当前断句是否使用声纹降噪识别
     */
    open var useVoiceprint = true
    
    /**
     * 声纹Id，如果不为空表示当前通话开启声纹降噪能力，为空表示不启用声纹降噪能力
     */
    open var voiceprintId: String? = nil
    
    /**
     * 智能体闲时的最大等待时间(单位：秒)，超时智能体自动下线，设置为-1表示闲时不退出，小于0则使用服务端默认值600s
     */
    open var agentMaxIdleTime: Int32 = -1
    
    /**
     * 是否开启对讲机模式
     */
    open var enablePushToTalk = false
    
    
    /**
     * 是否优雅下线
     * 优雅下线：当智能体被停止的时候，播报完当前说的话再停止，最多播报 10 秒
     */
    open var agentGracefulShutdown = false
    
    /**
     * 数字人模型Id，为空表示使用智能体配置值
     */
    open var agentAvatarId: String? = nil
    
    open func getJsonString(_ agentType: ARTCAICallAgentType) -> String {
        var template_config: [String : Any] = [:]
        var configDict: [String : Any] = [
            "EnableVoiceInterrupt": self.enableVoiceInterrupt,
            "EnablePushToTalk": self.enablePushToTalk,
            "EnableIntelligentSegment": self.enableIntelligentSegment,
            "GracefulShutdown": self.agentGracefulShutdown,
        ]
        if let agentGreeting = self.agentGreeting {
            configDict.updateValue(agentGreeting, forKey: "Greeting")
        }
        if self.userOnlineTimeout > -1 {
            configDict.updateValue(self.userOnlineTimeout, forKey: "UserOnlineTimeout")
        }
        if self.userOfflineTimeout > -1 {
            configDict.updateValue(self.userOfflineTimeout, forKey: "UserOfflineTimeout")
        }
        if let workflowOverrideParams = self.workflowOverrideParams {
            configDict.updateValue(workflowOverrideParams.aicall_jsonString, forKey: "WorkflowOverrideParams")
        }
        if let bailianAppParams = self.bailianAppParams {
            configDict.updateValue(bailianAppParams.aicall_jsonString, forKey: "BailianAppParams")
        }
        if self.asrMaxSilence > -1 {
            configDict.updateValue(self.asrMaxSilence, forKey: "AsrMaxSilence")
        }
        if self.volume > -1 {
            configDict.updateValue(self.volume, forKey: "Volume")
        }
        if let agentVoiceId = self.agentVoiceId {
            configDict.updateValue(agentVoiceId, forKey: "VoiceId")
        }
        if let voiceprintId = self.voiceprintId {
            configDict.updateValue(voiceprintId, forKey: "VoiceprintId")
            configDict.updateValue(self.useVoiceprint, forKey: "UseVoiceprint")
        }
        if self.agentMaxIdleTime > -1 {
            configDict.updateValue(self.agentMaxIdleTime, forKey: "MaxIdleTime")
        }
        
        if agentType == .AvatarAgent {
            if let agentAvatarId = self.agentAvatarId {
                configDict.updateValue(agentAvatarId, forKey: "AvatarId")
            }
        }
        template_config.updateValue(configDict, forKey: ARTCAICallTemplateConfig.getTemplateConfigKey(agentType))
        return template_config.aicall_jsonString
    }
}

extension ARTCAICallTemplateConfig {
    
    public static func getTemplateConfigKey(_ agentType: ARTCAICallAgentType) -> String {
        if agentType == .AvatarAgent {
            return "AvatarChat3D"
        }
        else if agentType == .VisionAgent {
            return "VisionChat"
        }
        return "VoiceChat"
    }
    
}
