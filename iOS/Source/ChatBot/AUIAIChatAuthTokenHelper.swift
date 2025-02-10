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
    
    public static let isDebug: Bool = false
    public static var AppId = ""
    public static var AppKey = ""
    public static var AppSign = ""

    private static func GenerateSignToken(userId: String, nonce: String, timestamp: Int, role: String) -> String {
        let stringBuilder = self.AppId + self.AppKey + userId + nonce + "\(timestamp)" + role
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
        
        let auth = ARTCAIChatAuthToken(appId: self.AppId, appSign: self.AppSign, token: token, timestamp: timestamp, role: role, nonce: nonce)
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
