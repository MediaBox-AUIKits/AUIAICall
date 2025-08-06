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
    
    public override init() {
        super.init()

        _ = self.loadData()
    }
    
    // 获取声纹降噪开关
    open private(set) var isEnable: Bool = true
    
    public private(set) var voiceprintItem: AUIAICallVoiceprintItem? = nil
    
    public var userId: String = "" {
        didSet {
            if self.loadData() == false {
                self.reset()
            }
        }
    }
    
    public var region: String {
#if DEMO_FOR_DEBUG
        AUIAICallDebugManager.shared.getRegion()
#else
        AUIAICallAgentConfig.shared.getRegion()
#endif
    }
    private var appserver: AUIAICallAppServer? = nil
    
    
    // 是否完整声纹录入
    open func isRegistedVoiceprint() -> Bool {
        return self.voiceprintItem != nil
    }
    
    // 通话时，可否可以使用声纹降噪能力
    open func canUseVoiceprint() -> Bool {
        return self.isEnable && self.isRegistedVoiceprint()
    }
    
    // 是否开启声纹降噪
    open func enableVoiceprint(_ isEnable: Bool) -> Void {
        self.isEnable = isEnable
        self.saveData()
    }
    
    public func getDirectory() -> URL {
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
        self.voiceprintItem = nil
        self.saveData()
    }
    
    private func loadData() -> Bool {
        let fileURL = self.getDirectory().appendingPathComponent("\(self.userId)_data.json")
        do {
            let data = try Data(contentsOf: fileURL)
            if let dict = String.init(data: data, encoding: .utf8)?.aicall_jsonObj() {
                if let isEnable = dict["Enable"] as? Bool {
                    self.isEnable = isEnable
                }
                if let itemDict = dict["Item"] as? [String: AnyHashable] {
                    self.voiceprintItem = AUIAICallVoiceprintItem(dict: itemDict)
                }
            }
            return true
        } catch {
            debugPrint("读取失败: \(error)")
        }
        return false
    }

    private func saveData() {
        let fileURL = self.getDirectory().appendingPathComponent("\(self.userId)_data.json")
        do {
            let dict: [String: AnyHashable] = [
                "Enable": self.isEnable,
                "Item": self.voiceprintItem?.toDict()
            ]
            
            let data = dict.aicall_jsonString.data(using: .utf8)
            try data?.write(to: fileURL)
        } catch {
            debugPrint("存储失败: \(error)")
        }
    }

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

    var client: OSSClient!
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

    public func start(audioFileUrl: URL, completed:((_ error: NSError?)->Void)?) {
        
        if self.userId.isEmpty == true {
            completed?(NSError.aicall_create(code: .InvalidParames, message: "userId is empty"))
            return
        }
        
        if self.appserver == nil {
            self.appserver = AUIAICallAppServer()
        }

        let resultBlock: (_ error: NSError?)->Void = { [weak self] error in
            self?.appserver = nil
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
                        self.voiceprintItem = item
                        self.saveData()
                        resultBlock(nil)
                        return
                    }
                    resultBlock(NSError.aicall_create(code: -1, message: "Register voiceprint failed"))
                }
            })
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
