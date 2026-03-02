//
//  AUIAICallVoiceprintManager.swift
//  AUIAICall
//
//  Created by Bingo on 2025/07/04.
//

import UIKit
import AliyunOSSiOS


@objcMembers open class AUIAICallVoiceprintManager: NSObject {
    
    public static let shared = AUIAICallVoiceprintManager()
    
    private override init() {
        super.init()
    }
    
    // 获取声纹降噪开关
    open private(set) var isEnable: Bool = true
    

    // 是否开启声纹降噪
    open func enableVoiceprint(_ isEnable: Bool) -> Void {
        self.isEnable = isEnable
        self.saveData()
    }
    
    // 获取声纹注册模式，false表示预注册， true表示无感注册
    open private(set) var isAutoRegister: Bool = false
    
    // 切换注册模式，false表示预注册， true表示无感注册
    open func switchVoiceprintMode(isAutoRegister: Bool) {
        self.isAutoRegister = isAutoRegister
        self.saveData()
    }
    
    // 使用当前声纹的用户Id
    open var userId: String = "" {
        didSet {
            if self.loadData() == false {
                self.reset()
            }
        }
    }
    
    // 预注册时，声纹需要上传到OSS所在的区域
    // ⚠️ 注意智能体如果使用预注册的声纹，智能体所在的区域需要与该区域一致
    open var region: String {
        return "cn-shanghai"
    }
    
    // 当前是否预发环境
    open var isPreEnv: Bool = false {
        didSet {
            if self.loadData() == false {
                self.reset()
            }
            self.appserver = nil
        }
    }
    
    // 是否完整声纹录入
    open func isRegistedVoiceprint() -> Bool {
        if self.isAutoRegister {
            return self.autoRegisterVoiceprintItem != nil
        }
        return self.preRegisterVoiceprintItem != nil
    }
    
    // 通话时，可以使用的声纹Id，返回nil表示未注册
    open func getVoiceprintId() -> String? {
        if self.isAutoRegister{
            return self.autoRegisterVoiceprintItem?.voiceprintId
        }
        return self.preRegisterVoiceprintItem?.voiceprintId
    }
    
    private var preRegisterVoiceprintItem: AUIAICallVoiceprintItem? = nil
    private var autoRegisterVoiceprintItem: AUIAICallVoiceprintItem? = nil

    open func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("voiceprint")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("创建文件夹失败：\(url)")
            }
        }
        return url
    }
    
    private func getStorePath(filePath: String) -> String {
        let dir = self.getDirectory().absoluteString
        if filePath.hasPrefix(dir) {
            return String(filePath.suffix(from: dir.endIndex))
        }
        return filePath
    }
    
    private func reset() {
        self.isEnable = true
        self.isAutoRegister = false
        self.preRegisterVoiceprintItem = nil
        self.autoRegisterVoiceprintItem = nil
    }
    
    private func loadData() -> Bool {
        let fileURL = self.getDirectory().appendingPathComponent("\(self.userId)_data\(self.isPreEnv ? "_pre" : "").json")
        do {
            let data = try Data(contentsOf: fileURL)
            self.reset()
            if let dict = String.init(data: data, encoding: .utf8)?.aicall_jsonObj() {
                if let isEnable = dict["Enable"] as? Bool {
                    self.isEnable = isEnable
                }
                if let itemDict = dict["Item"] as? [String: AnyHashable] {
                    self.preRegisterVoiceprintItem = AUIAICallVoiceprintItem(dict: itemDict)
                }
                if let isAutoRegister = dict["AutoRegister"] as? Bool {
                    self.isAutoRegister = isAutoRegister
                }
                if let itemDict = dict["AutoItem"] as? [String: AnyHashable] {
                    self.autoRegisterVoiceprintItem = AUIAICallVoiceprintItem(dict: itemDict)
                }
            }
            debugPrint("[voiceprint]加载当前预注册声纹Id:\(self.preRegisterVoiceprintItem?.voiceprintId ?? "未注册") 其他信息{uid: \(self.userId), pre: \(self.isPreEnv)}")
            debugPrint("[voiceprint]加载当前无感注册声纹Id:\(self.autoRegisterVoiceprintItem?.voiceprintId ?? "未注册") 其他信息{uid: \(self.userId), pre: \(self.isPreEnv)}")
            return true
        } catch {
            debugPrint("读取失败: \(error)")
        }
        return false
    }

    private func saveData() {
        let fileURL = self.getDirectory().appendingPathComponent("\(self.userId)_data\(self.isPreEnv ? "_pre" : "").json")
        do {
            debugPrint("[voiceprint]保存当前预注册声纹Id:\(self.preRegisterVoiceprintItem?.voiceprintId ?? "未注册") 其他信息{uid: \(self.userId), pre: \(self.isPreEnv)}")
            debugPrint("[voiceprint]保存当前无感注册声纹Id:\(self.autoRegisterVoiceprintItem?.voiceprintId ?? "未注册") 其他信息{uid: \(self.userId), pre: \(self.isPreEnv)}")
            var dict: [String: AnyHashable] = [
                "Enable": self.isEnable,
                "AutoRegister": self.isAutoRegister,
            ]
            if let preRegisterVoiceprintItem = self.preRegisterVoiceprintItem {
                dict["Item"] = preRegisterVoiceprintItem.toDict()
            }
            if let autoRegisterVoiceprintItem = self.autoRegisterVoiceprintItem {
                dict["AutoItem"] = autoRegisterVoiceprintItem.toDict()
            }
            
            let data = dict.aicall_jsonString.data(using: .utf8)
            try data?.write(to: fileURL)
        } catch {
            debugPrint("存储失败: \(error)")
        }
    }

    private var appserver: AUIAICallAppServer? = nil
    private var client: OSSClient!
    
    private func getOssConfig(completed:((_ config: [String: Any]?,  _ error: NSError?) -> Void)?) {
        self.appserver?.request(path: "/api/v2/aiagent/getOssConfig", body: ["user_id": self.userId]) { response, data, error in
            if error == nil {
                completed?(data as? [String: Any], error)
            }
            else {
                completed?(nil, error)
            }
        }
    }


    private func uploadFile(audioFileUrl: URL, info: [String: Any], completed:((_ ossUrl: String?, _ error: NSError?)->Void)?) {
        debugPrint("开始上传：\(audioFileUrl)")
        let accessKeyId = (info["access_key_id"] as? String) ?? ""
        let accessKeySecret = (info["access_key_secret"] as? String) ?? ""
        let securityToken = (info["sts_token"] as? String) ?? ""
        let endpoint = "https://\((info["region"] as? String) ?? "").aliyuncs.com"
        let bucketName = (info["bucket"] as? String) ?? "ai-agent-demo"
        let objectKey = ((info["base_path"] as? String) ?? "voice") + "/" + audioFileUrl.lastPathComponent

        let credentialProvider = OSSStsTokenCredentialProvider(accessKeyId: accessKeyId,
                                                               secretKeyId: accessKeySecret,
                                                               securityToken: securityToken)
        let config = OSSClientConfiguration()
        config.maxRetryCount = 3
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        self.client = OSSClient(endpoint: endpoint,
                           credentialProvider: credentialProvider,
                           clientConfiguration: config)

        let putRequest = OSSPutObjectRequest()
        putRequest.bucketName = bucketName
        putRequest.objectKey = objectKey
        putRequest.uploadingFileURL = audioFileUrl

        self.client.putObject(putRequest).continue({ (task) -> AnyObject? in
            if let error = task.error as? NSError {
                debugPrint("上传失败: \(error)")
                DispatchQueue.main.async {
                    completed?(nil, error)
                }
            } else {
                if let ossUrl = self.client.presignConstrainURL(withBucketName: bucketName, withObjectKey: objectKey, withExpirationInterval: 24 * 3600).result as? String {
                    debugPrint("上传成功：\(ossUrl)")
                    DispatchQueue.main.async {
                        completed?(ossUrl, nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completed?(nil, NSError.aicall_create(code: -1, message: "Fetch ossurl failed"))
                    }
                }
            }

            return nil
        })
    }

    private func registerVoiceprint(audioOssUrl: String, completed:((_ voiceId: String?, _ error: NSError?)->Void)?) {
        let voiceprintId = "\(self.userId)_\(String.aicall_random())"
        let input = [
            "Type": "oss",
            "Data": audioOssUrl,
            "Format": "wav",
        ]
        let body: [String: Any] = [
            "user_id": self.userId,
            "region": self.region,
            "voiceprint_id": voiceprintId,
            "input": input.aicall_jsonString
        ]
        self.appserver?.request(path: "/api/v2/aiagent/setAIAgentVoiceprint", body: body) { response, data, error in
            if let data = data {
                if let voiceprintId = data["voiceprint_id"] as? String {
                    completed?(voiceprintId, nil)
                    return
                }
                
                let code = (data["code"] as? Int) ?? -1
                let message = data.aicall_jsonString
                completed?(nil, NSError.aicall_create(code: code, message: message))
                return
            }
            completed?(nil, error ?? NSError.aicall_create(code: -1, message: data?.aicall_jsonString ?? "unknown"))
        }
    }

    // 预注册声纹时，发起注册
    open func startPreRester(audioFileUrl: URL, completed:((_ error: NSError?)->Void)?) {
        
        if self.userId.isEmpty == true {
            completed?(NSError.aicall_create(code: .InvalidParames, message: "userId is empty"))
            return
        }
        
        if self.appserver == nil {
            self.appserver = AUIAICallAppServer()
        }

        let resultBlock: (_ error: NSError?)->Void = { error in
            completed?(error)
        }

        self.getOssConfig() {[weak self] config, error in
            guard let self = self else { return }
            if let error = error {
                resultBlock(error)
                return
            }
            guard let info = config else {
                resultBlock(NSError.aicall_create(code: -1, message: "Fetch ossconfig failed"))
                return
            }
            self.uploadFile(audioFileUrl: audioFileUrl, info: info, completed: { [weak self] ossUrl, error in
                guard let self = self else { return }
                if let error = error {
                    resultBlock(error)
                    return
                }
                self.registerVoiceprint(audioOssUrl: ossUrl!) { [weak self] voiceprintId, error in
                    guard let self = self else { return }
                    if let error = error {
                        resultBlock(error)
                        return
                    }
                    if let voiceprintId = voiceprintId {
                        let item = AUIAICallVoiceprintItem(voiceprintId: voiceprintId)
                        item.filePath = self.getStorePath(filePath: audioFileUrl.absoluteString)
                        item.ossUrl = ossUrl!
                        self.preRegisterVoiceprintItem = item
                        self.saveData()
                        resultBlock(nil)
                        return
                    }
                    resultBlock(NSError.aicall_create(code: -1, message: "Register voiceprint failed"))
                }
            })
        }
    }
    
    // 生成一个声纹Id，用于自动注册
    open func generateVoiceprintId() -> String {
        return "\(self.userId)_\(String.aicall_random())"
    }
    
    // 无感模式声纹完成注册
    open func onAutoRegisted(voiceprintId: String) {
        
        if self.isAutoRegister == false {
            return
        }
        
        if let item = self.autoRegisterVoiceprintItem {
            if item.voiceprintId != voiceprintId {
                debugPrint("[voiceprint]⚠️⚠️⚠️ 警告：当前的声纹是无感模式，且已经注册，但注册的声纹Id与在通话中返回的声纹Id不一致，请检查调用情况")
                debugPrint("[voiceprint]当前已无感注册的声纹Id：\(item.voiceprintId)")
                debugPrint("[voiceprint]当前通话中返回的声纹Id：\(voiceprintId)")
            }
            return
        }
        
        let item = AUIAICallVoiceprintItem(voiceprintId: voiceprintId)
        self.autoRegisterVoiceprintItem = item
        self.saveData()
    }
    
    // 移除无感模式的已经注册的声纹
    open func removeAutoRegister(completed: ((_ success: Bool) -> Void)? = nil) {
        guard let removeItem = self.autoRegisterVoiceprintItem else {
            return
        }
        self.autoRegisterVoiceprintItem = nil
        self.saveData()
        
        // 调用OpenAPI
        if self.appserver == nil {
            self.appserver = AUIAICallAppServer()
        }
        
        let voiceprintId = removeItem.voiceprintId
        let body: [String: Any] = [
            "user_id": self.userId,
            "region": self.region,
            "voiceprint_id": voiceprintId,
            "registration_mode": "Implicit"
        ]
        self.appserver?.request(path: "/api/v2/aiagent/clearAIAgentVoiceprint", body: body) { response, data, error in
            if let data = data {
                let code = (data["code"] as? Int) ?? -1
                let message = data.aicall_jsonString
                debugPrint("clearAIAgentVoiceprint result: \(code) message: \(message)")
                completed?(code == 200)
            }
            else {
                debugPrint("clearAIAgentVoiceprint failed: \(data?.aicall_jsonString ?? "unknown")")
                completed?(false)
            }
        }
    }
}

// 声纹信息结构
@objcMembers open class AUIAICallVoiceprintItem: NSObject {
    
    public init(voiceprintId: String) {
        self.voiceprintId = voiceprintId
    }
    
    public private(set) var voiceprintId: String = ""
    public var name: String = ""
    public var filePath: String = ""
    public var ossUrl: String = ""
    
    public init(dict: [String: AnyHashable]) {
        if let voiceprintId = dict["voiceprintId"] as? String {
            self.voiceprintId = voiceprintId
        }
        if let name = dict["name"] as? String {
            self.name = name
        }
        if let filePath = dict["filePath"] as? String {
            self.filePath = filePath
        }
        if let ossUrl = dict["ossUrl"] as? String {
            self.ossUrl = ossUrl
        }
    }
    
    open func toDict() -> [String: AnyHashable] {
        return [
            "voiceprintId": self.voiceprintId,
            "name": self.name,
            "filePath": self.filePath,
            "ossUrl": self.ossUrl,
        ]
    }

}
