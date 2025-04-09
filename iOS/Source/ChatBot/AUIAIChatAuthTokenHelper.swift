//
//  AUIAIChatAuthTokenHelper.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import ARTCAICallKit
import CommonCrypto

@objcMembers public class AUIAIChatAuthTokenHelper: NSObject {
    
    private static let EnableDevelopToken: Bool = false
    private static let IMDevelopAppId = ""
    private static let IMDevelopAppKey = ""
    private static let IMDevelopAppSign = ""

    public static let shared = AUIAIChatAuthTokenHelper()

    
    private var appserver: AUIAICallAppServer? = nil
    
    
    public func fetchAuthToken(userId: String, agentId: String?, region: String?, completed: ((_ authToken: ARTCAIChatAuthToken?, _ error: NSError?) -> Void)?) {
        if AUIAIChatAuthTokenHelper.EnableDevelopToken {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                completed?(AUIAIChatAuthTokenHelper.GenerateAuthToken(userId: userId), nil)
            }
        }
        else {
            self.generateMessageChatToken(userId: userId, agentId: agentId, region: region) { authToken, error, reqId in
                ARTCAICallEngineDebuger.Debug_UpdateExtendInfo(key: "RequestId", value: reqId)
                completed?(authToken, error)
            }
        }
    }
    
    private func generateMessageChatToken(userId: String, agentId: String?, region: String?, completed: ((_ authToken: ARTCAIChatAuthToken?, _ error: NSError?, _ reqId: String) -> Void)?) {
        
        let expire: Int = 1 * 60 * 60
        var body: [String: Any] = [
            "user_id": userId,
            "expire": expire,
        ]
        if let agentId = agentId {
            body.updateValue(agentId, forKey: "ai_agent_id")
        }
        if let region = region {
            body.updateValue(region, forKey: "region")
        }
        
        self.appserver = AUIAICallAppServer()
        self.appserver?.request(path: "/api/v2/aiagent/generateMessageChatToken", body: body) { [weak self] response, data, error in
            self?.appserver = nil
            let reqId = (data?["request_id"] as? String) ?? "unknow"
            if error == nil {
                debugPrint("generateMessageChatToken response: success")
                let authToken = ARTCAIChatAuthToken(data: data as? [String: Any])
                completed?(authToken, nil, reqId)
            }
            else {
                debugPrint("generateMessageChatToken response: failed, error:\(error!)")
                completed?(nil, self?.handlerCallError(error: error, data: data), reqId)
            }
        }
    }
    
    private func handlerCallError(error: NSError?, data: [AnyHashable: Any]?) -> NSError? {
        return NSError.aicall_handlerErrorData(data: data) ?? error
    }
}

extension AUIAIChatAuthTokenHelper {
    
    private static func GenerateSignToken(userId: String, nonce: String, timestamp: Int, role: String) -> String {
        let stringBuilder = self.IMDevelopAppId + self.IMDevelopAppKey + userId + nonce + "\(timestamp)" + role
        let token = GetSHA256(stringBuilder)
        return token
    }
    
    /**
     根据channelId，userId, nonce 生成单参数入会 的token
     */
    public static func GenerateAuthToken(userId: String) -> ARTCAIChatAuthToken {
        let nonce = ""
        let role = ""
        let timestamp = Int(Date().addingTimeInterval(1 * 60 * 60).timeIntervalSince1970)  // 过期时间戳最大1小时
        let token = self.GenerateSignToken(userId: userId, nonce: nonce, timestamp: timestamp, role:role)
        
        let auth = ARTCAIChatAuthToken(appId: self.IMDevelopAppId, appSign: self.IMDevelopAppSign, token: token, timestamp: timestamp, role: role, nonce: nonce)
        return auth
    }

    /**
     字符串签名
     */
    private static func GetSHA256(_ input: String) -> String {
        // 将输入字符串转换为数据
        let data = Data(input.utf8)
        
        // 创建用于存储哈希结果的缓冲区
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        // 计算 SHA-256 哈希值
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        // 将哈希值转换为十六进制字符串
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
