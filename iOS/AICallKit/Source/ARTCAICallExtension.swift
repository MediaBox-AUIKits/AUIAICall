//
//  ARTCAICallExtension.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import CommonCrypto

extension String {
    public func aicall_decodeBase64AndDeserialize() -> [String: Any]? {
        // Base64 Decode
        guard let decodedData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        
        // JSON Deserialize
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: decodedData, options: [])
            if let jsonDictionary = jsonObject as? [String: Any] {
                return jsonDictionary
            }
        } catch {
            debugPrint("Failed to deserialize JSON: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    public func aicall_parseDateString(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.date(from: self)
    }

    public func aicall_isDateStringExpired(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Bool {
        guard let date = self.aicall_parseDateString(dateFormat: dateFormat) else {
            debugPrint("Failed to formatted Data String")
            return false
        }
        
        let currentDate = Date()
        return currentDate > date
    }
}

extension Dictionary {
    
    public var aicall_jsonString: String {
        do {
            let stringData = try JSONSerialization.data(withJSONObject: self as NSDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let string = String(data: stringData, encoding: String.Encoding.utf8){
                return string
            }
        } catch _ {
            
        }
        return "{}"
    }
}

extension NSError {
    public static func aicall_create(code: Int, message: String?) -> NSError {
        let error = NSError(domain: "aui.aicall", code: code, userInfo: [NSLocalizedDescriptionKey:message ?? "unknown"])
        return error
    }
    
    public static func aicall_create(code: ARTCAICallErrorCode, message: String? = nil) -> NSError {
        var msg = "unknow"
        switch code {
        case .InvalidAction:
            msg = "Invalid action"
            break
        case.InvalidParames:
            msg = "Invalid Params"
            break
        default:
            break
        }
        if let message = message {
            msg = msg + ": \(message)"
        }
        let error = NSError(domain: "aui.aicall", code: Int(code.rawValue), userInfo: [NSLocalizedDescriptionKey:msg])
        return error
    }
}


@objcMembers public class ARTCAICallRTCTokenHelper: NSObject {
    
    public static var AppId = ""
    public static var AppKey = ""
    
    /**
     根据channelId，userId, timestamp 生成多参数入会的 token
     */
    public static func GenerateToken(channelId: String, userId: String, timestamp: Int) -> String {
        let stringBuilder = self.AppId + self.AppKey + channelId + userId + "\(timestamp)"
        let token = GetSHA256(stringBuilder)
        return token
    }
    
    /**
     根据channelId，userId, nonce 生成单参数入会 的token
     */
    public static func GenerateToken(channelId: String, userId: String, nonce: String) -> String {
        // 过期时间戳最大24小时
        let timestamp = Int(Date().addingTimeInterval(24 * 60 * 60).timeIntervalSince1970)
        let token = self.GenerateToken(channelId: channelId, userId: userId, timestamp: timestamp)
        
        let tokenJson: [String: Any] = [
            "appid": self.AppId,
            "channelid": channelId,
            "userid": userId,
            "nonce": nonce,
            "timestamp": timestamp,
            "token": token
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: tokenJson, options: []),
           let base64Token = jsonData.base64EncodedString() as String? {
            return base64Token
        }
        
        return ""
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
