//
//  AUIAICallAuthTokenHelper.swift
//  AUIAICall
//
//  Created by Bingo on 2025/3/5.
//

import UIKit
import ARTCAICallKit
import CommonCrypto


@objcMembers public class AUIAICallAuthTokenHelper: NSObject {
    
    private static let EnableDevelopToken: Bool = false
    private static let RTCDevelopAppId: String = ""
    private static let RTCDevelopAppKey: String = ""
    
    public static let shared = AUIAICallAuthTokenHelper()
    
    
    public private(set) var authToken: String = ""
    public private(set) var channelId: String = ""
    private var requestTime: TimeInterval = 0
    private var userId: String = ""
    private var isRequesting: Bool = false
    private var completed:((_ authToken: String, _ error: NSError?) -> Void)? = nil
    
    public func isAuthTokenValid() -> Bool {
        if self.authToken.isEmpty == false {
            // Token 24小时有效，超过23小时则需要重新获取，避免在使用过程中失效
            if Date().timeIntervalSince1970 - self.requestTime < 23 * 60 * 60 {
                return true
            }
        }
        return false
    }
    
    public func fetchAuthToken(userId: String, completed:((_ authToken: String, _ error: NSError?) -> Void)?) {
        if self.isAuthTokenValid(), self.userId == userId {
            debugPrint("AUIAICallAuthTokenHelper.fetchAuthToken return last auth token")
            completed?(self.authToken, nil)
            return
        }
        
        self.completed = completed
        if self.isRequesting && self.userId == userId {
            debugPrint("AUIAICallAuthTokenHelper.fetchAuthToken is already requesting")
            return
        }
        debugPrint("AUIAICallAuthTokenHelper.fetchAuthToken should request new one")
        self.userId = userId
        self.requestNewAuthToken()
    }
    
    public func requestNewAuthToken() {
        debugPrint("AUIAICallAuthTokenHelper.requestNewAuthToken")
        self.authToken = ""
        self.channelId = String.aicall_random()
        self.isRequesting = true
        if AUIAICallAuthTokenHelper.EnableDevelopToken {
            ARTCAICallRTCTokenHelper.AppId = AUIAICallAuthTokenHelper.RTCDevelopAppId
            ARTCAICallRTCTokenHelper.AppKey = AUIAICallAuthTokenHelper.RTCDevelopAppKey
            let channelId = self.channelId
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                debugPrint("AUIAICallAuthTokenHelper.requestNewAuthToken result: \(self.authToken)")

                self.requestTime = Date().timeIntervalSince1970
                self.authToken = ARTCAICallRTCTokenHelper.GenerateToken(channelId: channelId, userId: self.userId, nonce: "")
                self.completed?(self.authToken, nil)
                self.isRequesting = false
                self.completed = nil
            }
        }
        else {
            self.generateCallToken(userId: self.userId) {[weak self] authToken, error in
                guard let self = self else {
                    return
                }
                debugPrint("AUIAICallAuthTokenHelper.requestNewAuthToken result: \(error?.description ?? "success")")

                self.requestTime = Date().timeIntervalSince1970
                self.authToken = authToken ?? ""
                self.completed?(self.authToken, error)
                self.isRequesting = false
                self.completed = nil
            }
        }
    }
        
    private var appserver: AUIAICallAppServer? = nil
    
    private func generateCallToken(userId: String, completed: ((_ authToken: String?, _ error: NSError?) -> Void)?) {
        
        let body: [String: Any] = [
            "user_id": userId,
            "channel_id": self.channelId,
        ]
        
        debugPrint("AUIAICallAuthTokenHelper.generateCallToken")
        self.appserver = AUIAICallAppServer()
        self.appserver?.request(path: "/api/v2/aiagent/getRtcAuthToken", body: body) {[weak self] response, data, error in
            self?.appserver = nil
            let rtc_auth_token = data?["rtc_auth_token"] as? String
            if let rtc_auth_token = rtc_auth_token {
                debugPrint("AUIAICallAuthTokenHelper.generateCallToken response: success")
                completed?(rtc_auth_token, nil)
            }
            else {
                debugPrint("AUIAICallAuthTokenHelper.generateCallToken response: failed, error:\(error!)")
                completed?(nil, error ?? NSError.aicall_create(code: .UnknowError))
            }
        }
    }
    

}
