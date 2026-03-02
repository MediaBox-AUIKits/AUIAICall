//
//  AUIAICallAgentManager.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/23.
//


import UIKit
import AUIFoundation
import ARTCAICallKit



@objcMembers open class AUIAICallAgentManager: NSObject {
    
    public static let shared: AUIAICallAgentManager = AUIAICallAgentManager()
    
    public static let defaultSceneFileName = "agent_scenes"
    
    private override init() {
        super.init()
        
        self.loadStartupConfig()
        self.loadSceneConfigs(from: AUIAICallAgentManager.defaultSceneFileName)
    }
    
    
    open func getLocalDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("agent_configs")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("创建文件夹失败：\(url)")
            }
        }
        return url
    }

    /** 启动配置相关  Begin */
    
    open var enableUserGuide: Bool = true {
        didSet {
            self.saveStartupConfig()
        }
    }
        
    open var enableSemanticMode: Bool = true {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var semanticEagerness: String = "Medium" {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var enableVoiceInterrupt: Bool = true
    {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var enableBackChanneling: Bool = true
    {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var enableAutoSpeechUserIdle: Bool = true
    {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var autoSpeechUserIdleWaitTime: Int32 = 10000
    {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var autoSpeechUserIdleMaxRepeats: Int32 = 10
    {
        didSet {
            self.saveStartupConfig()
        }
    }
    open var ambientResourceId: String = "" {
        didSet {
            self.saveStartupConfig()
        }
    }
    
    private func saveStartupConfig() {
        let fileURL = self.getLocalDirectory().appendingPathComponent("startup.json")
        do {
            let dict: [String: AnyHashable] = [
                "EnableUserGuide": self.enableUserGuide,
                "EnableSemanticMode": self.enableSemanticMode,
                "SemanticEagerness": self.semanticEagerness,
                "EnableVoiceInterrupt": self.enableVoiceInterrupt,
                "EnableBackChanneling": self.enableBackChanneling,
                "EnableAutoSpeechUserIdle": self.enableAutoSpeechUserIdle,
                "AutoSpeechUserIdleWaitTime": self.autoSpeechUserIdleWaitTime,
                "AutoSpeechUserIdleMaxRepeats": self.autoSpeechUserIdleMaxRepeats,
                "AmbientResourceId": self.ambientResourceId,
            ]
            let data = dict.aicall_jsonString.data(using: .utf8)
            try data?.write(to: fileURL)
        } catch {
            debugPrint("存储失败: \(error)")
        }
    }

    private func loadStartupConfig() {
        let fileURL = self.getLocalDirectory().appendingPathComponent("startup.json")
        do {
            let data = try Data(contentsOf: fileURL)
            if let dict = String.init(data: data, encoding: .utf8)?.aicall_jsonObj() {
                if let enableUserGuide = dict["EnableUserGuide"] as? Bool {
                    self.enableUserGuide = enableUserGuide
                }
                if let enableSemanticMode = dict["EnableSemanticMode"] as? Bool {
                    self.enableSemanticMode = enableSemanticMode
                }
                if let semanticEagerness = dict["SemanticEagerness"] as? String {
                    self.semanticEagerness = semanticEagerness
                }
                if let enableVoiceInterrupt = dict["EnableVoiceInterrupt"] as? Bool {
                    self.enableVoiceInterrupt = enableVoiceInterrupt
                }
                if let enableBackChanneling = dict["EnableBackChanneling"] as? Bool {
                    self.enableBackChanneling = enableBackChanneling
                }
                if let enableAutoSpeechUserIdle = dict["EnableAutoSpeechUserIdle"] as? Bool {
                    self.enableAutoSpeechUserIdle = enableAutoSpeechUserIdle
                }
                if let autoSpeechUserIdleWaitTime = dict["AutoSpeechUserIdleWaitTime"] as? Int32 {
                    self.autoSpeechUserIdleWaitTime = autoSpeechUserIdleWaitTime
                }
                if let autoSpeechUserIdleMaxRepeats = dict["AutoSpeechUserIdleMaxRepeats"] as? Int32 {
                    self.autoSpeechUserIdleMaxRepeats = autoSpeechUserIdleMaxRepeats
                }
                if let ambientResourceId = dict["AmbientResourceId"] as? String {
                    self.ambientResourceId = ambientResourceId
                }
            }
        } catch {
            debugPrint("读取失败: \(error)")
        }
        
        
        
    }
    
    open func generateStartupConfigs(_ defaultStartupConfigs: ARTCAICallAgentConfig? = nil) -> ARTCAICallAgentConfig {
        let config = defaultStartupConfigs ?? ARTCAICallAgentConfig()
        
        // 声纹
        let vpManager = AUIAICallVoiceprintManager.shared
        if vpManager.isEnable {
            if vpManager.isAutoRegister {
                // 无感模式，如果还没注册成功，则生成一个声纹id到通话中进行注册
                let vpId = vpManager.getVoiceprintId() ?? vpManager.generateVoiceprintId()
                config.voiceprintConfig.voiceprintId = vpId
                config.voiceprintConfig.useVoiceprint = true
                config.voiceprintConfig.registrationMode = "Implicit"
            }
            else {
                // 预注册模式，如果有声纹id表示已经注册过了，开启开启声纹
                if let vpId = vpManager.getVoiceprintId() {
                    config.voiceprintConfig.voiceprintId = vpId
                    config.voiceprintConfig.useVoiceprint = true
                    config.voiceprintConfig.registrationMode = "Explicit"
                }
            }
        }
        
        // 是否开启智能打断
        config.interruptConfig.enableVoiceInterrupt = self.enableVoiceInterrupt
        
        // AI语义断句
        config.turnDetectionConfig.mode = self.enableSemanticMode ? .Semantic : .Normal
        if self.enableSemanticMode {
            config.turnDetectionConfig.eagerness = self.semanticEagerness
        }
        
        // 附和语
        if self.enableBackChanneling {
            let backChannel = ARTCAICallAgentBackChanneling()
            backChannel.probability = 1.0
            backChannel.words = [
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "嗯，你说。", "Probability": 0.25]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "嗯嗯。", "Probability": 0.20]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "这样啊。", "Probability": 0.18]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "嗯，然后呢？", "Probability": 0.15]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "啊，明白。", "Probability": 0.13]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "还有吗？", "Probability": 0.09]),
            ]
            config.backChannelingConfigs = [backChannel]
        }
        
        // 主动问询
        if self.enableAutoSpeechUserIdle {
            let userIdleConfig = ARTCAICallAgentAutoSpeechUserIdle()
            userIdleConfig.waitTime = self.autoSpeechUserIdleWaitTime
            userIdleConfig.maxRepeats = self.autoSpeechUserIdleMaxRepeats
            userIdleConfig.messages = [
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "您好，还在吗？如果有任何问题，我很乐意帮您解答。", "Probability": 0.25]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "是不是刚才的信息不太清楚？我可以再为您说明一遍。", "Probability": 0.20]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "请问您还在考虑哪方面的问题呢？我可以帮您一起看看。", "Probability": 0.15]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "如果暂时不方便说话，也可以稍后联系我们，我会一直在这里。", "Probability": 0.13]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "您是不是遇到网络或信号问题了？如果能听到，请回复‘在’。", "Probability": 0.12]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "我注意到您刚才没有回应，是我说得不够清楚吗？", "Probability": 0.09]),
                ARTCAICallAgentAutoSpeechContent(data: ["Text": "感谢您的耐心，若还有需要，随时告诉我哦～", "Probability": 0.06]),
            ]
            config.autoSpeechForUserIdleConfig = userIdleConfig
        }
        
        // 背景音
        if self.ambientResourceId.isEmpty == false {
            config.ambientConfig.resourceId = self.ambientResourceId
        }
        
        return config
    }

    /** 启动配置相关  Begin */
    
    
    
    
    /** 场景化配置相关 Begin */
    
    open private(set) var agentSceneConfigVersion: Int = 0
    open private(set) var agentSceneConfigList: [AUIAICallAgentSceneConfig] = []
    
    open func parseSceneConfigs(from dict: [String: Any], checkVersion: Bool) -> Bool {
        guard let version = dict["version"] as? Int,
              let agentsArray = dict["agents"] as? [[String: Any]] else {
            return false
        }
        
        if checkVersion == true && version <= self.agentSceneConfigVersion {
            // 旧版本
            return false
        }
        
        self.agentSceneConfigVersion = version
        self.agentSceneConfigList = agentsArray.compactMap { AUIAICallAgentSceneConfig.fromDictionary($0) }
        return true
    }
    
    open func loadSceneConfigs(from fileName: String) {
        
        // 读取沙箱
        var jsonData: Data? = nil
        let sandboxPath = self.getLocalDirectory().appendingPathComponent("\(fileName).json")
        jsonData = try? Data(contentsOf: sandboxPath)
        if let jsonData = jsonData {
            if let dict = String.init(data: jsonData, encoding: .utf8)?.aicall_jsonObj() {
                _ = self.parseSceneConfigs(from: dict, checkVersion: false)
            }
        }
        
        // 读取本地内置，如果版本比沙箱高，则使用本地版本
        let aicall = Bundle(path: Bundle.main.bundlePath + "/AUIAIMain.bundle")
        if let installPath = aicall?.url(forResource: fileName, withExtension: "json") {
            jsonData = try? Data(contentsOf: installPath)
        }
        if let jsonData = jsonData {
            if let dict = String.init(data: jsonData, encoding: .utf8)?.aicall_jsonObj() {
                _ = self.parseSceneConfigs(from: dict, checkVersion: true)
            }
        }
        else {
            debugPrint("读取智能体配置Json失败")
        }
    }
    
    /// 获取指定 agentType 的场景列表
    /// - Parameter stringType: 智能体类型
    /// - Returns: 场景列表，如果没有找到对应类型则返回空数组
    open func getScenes(_ stringType: String) -> [AUIAICallAgentScene] {
        if let sceneConfig = self.agentSceneConfigList.first(where: { $0.agentType == stringType }) {
            return sceneConfig.scenes
        }
        else {
            return []
        }
    }
    
    open func getScenes(for agentType: ARTCAICallAgentType) -> [AUIAICallAgentScene] {
        var string = ""
        if (agentType == ARTCAICallAgentType.VoiceAgent) {
            string = "VoiceAgent"
        }
        else if (agentType == ARTCAICallAgentType.AvatarAgent) {
            string = "AvatarAgent"
        }
        else if (agentType == ARTCAICallAgentType.VisionAgent) {
            string = "VisionAgent"
        }
        else if (agentType == ARTCAICallAgentType.VideoAgent) {
            string = "VideoAgent"
        }

        return self.getScenes(string)
    }
    
    open func addScene(scene: AUIAICallAgentScene, for type: String) -> Bool {
        if let sceneConfig = self.agentSceneConfigList.first(where: { $0.agentType == type }) {
            sceneConfig.addScene(scene)
            return true
        }
        return false
    }
    
    /// 获取所有智能体类型
    /// - Returns: 所有可用的 agentType 列表
    open func getAllAgentSceneTypes() -> [String] {
        return self.agentSceneConfigList.map { $0.agentType }
    }
    
    /** 场景化配置相关 End */
}


@objcMembers open class AUIAICallAgentSceneConfig: NSObject {
    public let agentType: String
    open private(set) var scenes: [AUIAICallAgentScene]
    
    public init(agentType: String, scenes: [AUIAICallAgentScene]) {
        self.agentType = agentType
        self.scenes = scenes
        super.init()
    }
    
    open func addScene(_ scene: AUIAICallAgentScene) {
        self.scenes.append(scene)
    }
    
    public static func fromDictionary(_ dict: [String: Any]) -> AUIAICallAgentSceneConfig? {
        guard let agentType = dict["agent_type"] as? String,
              let scenesArray = dict["scenes"] as? [[String: Any]] else {
            return nil
        }
        
        let scenes = scenesArray.compactMap { AUIAICallAgentScene.fromDictionary($0) }
        return AUIAICallAgentSceneConfig(agentType: agentType, scenes: scenes)
    }
}

@objcMembers open class AUIAICallAgentScene: NSObject {
    public let agentId: String
    public let region: String
    public let title: String
    public let tags: [AUIAICallAgentSceneTag]
    public let desc: String
    public let limitSeconds: UInt32 // 等于0则通话不限制
    public let asrModelId: String
    public let ttsModelId: String
    public let voiceStyles: [AUIAICallAgentVoiceStyle]
    
    public init(agentId: String,
                region: String,
                title: String = "",
                tags: [AUIAICallAgentSceneTag] = [],
                limitSeconds: Int32 = 0,
                description: String = "",
                asrModelId: String = "",
                ttsModelId: String = "",
                voiceStyles: [AUIAICallAgentVoiceStyle] = []) {
        self.agentId = agentId
        self.region = region
        self.title = title
        self.tags = tags
        self.limitSeconds = limitSeconds < 0 ? 0 : UInt32(limitSeconds)
        self.desc = description
        self.asrModelId = asrModelId
        self.ttsModelId = ttsModelId
        self.voiceStyles = voiceStyles
        super.init()
    }
    
    public static func fromDictionary(_ dict: [String: Any]) -> AUIAICallAgentScene? {
        guard let agentId = dict["agent_id"] as? String,
              let region = dict["region"] as? String,
              let title = dict["title"] as? String else {
            return nil
        }
        
        let limitSeconds = dict["limit_seconds"] as? Int32 ?? -1
        let desc = dict["description"] as? String ?? ""
        let asrModelId = dict["asr_model_id"] as? String ?? ""
        let ttsModelId = dict["tts_model_id"] as? String ?? ""

        let tagsArray = (dict["tags"] as? [[String: Any]]) ?? []
        let tags = tagsArray.compactMap { AUIAICallAgentSceneTag.fromDictionary($0) }

        let voiceStylesArray = (dict["voice_styles"] as? [[String: Any]]) ?? []
        let voiceStyles = voiceStylesArray.compactMap { AUIAICallAgentVoiceStyle.fromDictionary($0) }
        
        return AUIAICallAgentScene(agentId: agentId, region: region, title: title, tags: tags, limitSeconds: limitSeconds,
                    description: desc, asrModelId: asrModelId,
                    ttsModelId: ttsModelId, voiceStyles: voiceStyles)
    }
}

@objcMembers open class AUIAICallAgentSceneTag: NSObject {
    public let name: String
    public let fg: String?
    public let bg: String?
    
    public init(name: String, fg: String?, bg: String?) {
        self.name = name
        self.fg = fg
        self.bg = bg
        super.init()
    }
    
    public static func fromDictionary(_ dict: [String: Any]) -> AUIAICallAgentSceneTag? {
        guard let name = dict["name"] as? String else {
            return nil
        }
        let fg = dict["fg"] as? String
        let bg = dict["bg"] as? String
        
        return AUIAICallAgentSceneTag(name: name, fg: fg, bg: bg)
    }
}


