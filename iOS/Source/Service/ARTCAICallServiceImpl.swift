//
//  ARTCAICallServiceImpl.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

#if canImport(AliVCSDK_ARTC)
import AliVCSDK_ARTC
#elseif canImport(AliVCSDK_InteractiveLive)
import AliVCSDK_InteractiveLive
#elseif canImport(AliVCSDK_Standard)
import AliVCSDK_Standard
#elseif canImport(AliRTCSdk)
import AliRTCSdk
#endif

@objcMembers open class ARTCAICallServiceImpl: ARTCAICallServiceInterface {
    
    public func startRobot(userId: String, config: ARTCAICallConfig, completed: ((_ rsp: ARTCAICallRobotInfo?, _ error: Error?) -> Void)?) {
        
//        if !AUIAICallAppServer.serverAuthValid() {
//            completed?(nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
//            return
//        }
        
        let cofigDict: [String : Any] = [
            "VoiceId": config.robotVoiceId,
            "EnableVoiceInterrupt": config.enableVoiceInterrupt
        ]
        
        var body = [
            "user_id": userId,
            "config": cofigDict.aicall_jsonString
        ]
        if let robotId = config.robotId {
            if robotId.isEmpty == false {
                body.updateValue(robotId, forKey: "robot_id")
            }
        }
        AUIAICallAppServer.request(path: "/api/v1/imsRobot/startRobot", body: body) { response, data, error in
            if error == nil {
                debugPrint("startRobot response: success")
                let robot_instance_id = data?["robot_instance_id"] as? String
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                let channel_id = data?["channel_id"] as? String
                let robot_user_id = data?["robot_user_id"] as? String

                let info = ARTCAICallRobotInfo()
                info.channelId = channel_id ?? ""
                info.userId = robot_user_id ?? ""
                info.token = rtc_auth_token ?? ""
                info.instanceId = robot_instance_id ?? ""
                completed?(info, nil)
            }
            else {
                debugPrint("startRobot response: failed, error:\(error!)")
                completed?(nil, error)
            }
        }
    }
    
    public func stopRobot(instanceId: String, completed: ((_ error: Error?) -> Void)?) {
        
//        if !AUIAICallAppServer.serverAuthValid() {
//            completed?(nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
//            return
//        }
        
        let body = ["robot_instance_id": instanceId]
        AUIAICallAppServer.request(path: "/api/v1/imsRobot/stopRobot", body: body) { response, data, error in
            if error == nil {
                if data?["result"] as? Bool == true {
                    debugPrint("stopRobot response: success")
                    completed?(nil)
                }
                else {
                    debugPrint("stopRobot response: result, failed")
                    completed?(NSError.aicall_create(code: -1, message: "api failed"))
                }
            }
            else {
                debugPrint("stopRobot response: failed, error:\(error!)")
                completed?(error)
            }
        }
    }
    
    public func changedVoice(instanceId: String, voiceId: String, completed: ((_ error: Error?) -> Void)?) {
        
//        if !AUIAICallAppServer.serverAuthValid() {
//            completed?(nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
//            return
//        }
        
        let body = [
            "robot_instance_id": instanceId,
            "config": ["VoiceId":voiceId].aicall_jsonString
        ]
        AUIAICallAppServer.request(path: "/api/v1/imsRobot/updateRobot", body: body) { response, data, error in
            if error == nil {
                if data?["result"] as? Bool == true {
                    debugPrint("updateRobot response: success")
                    completed?(nil)
                }
                else {
                    debugPrint("updateRobot response: result, failed")
                    completed?(NSError.aicall_create(code: -1, message: "api failed"))
                }
            }
            else {
                debugPrint("updateRobot changedVoice response: failed, error:\(error!)")
                completed?(error)
            }
        }
    }
    
    public func enableVoiceInterrupt(instanceId: String, enable: Bool, completed: ((_ error: Error?) -> Void)?) {
        
//        if !AUIAICallAppServer.serverAuthValid() {
//            completed?(nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
//            return
//        }
        
        let body = [
            "robot_instance_id": instanceId,
            "config": ["EnableVoiceInterrupt":enable].aicall_jsonString
        ]
        AUIAICallAppServer.request(path: "/api/v1/imsRobot/updateRobot", body: body) { response, data, error in
            if error == nil {
                if data?["result"] as? Bool == true {
                    debugPrint("updateRobot response: success")
                    completed?(nil)
                }
                else {
                    debugPrint("updateRobot response: result, failed")
                    completed?(NSError.aicall_create(code: -1, message: "api failed"))
                }
            }
            else {
                debugPrint("updateRobot enableVoiceInterrupt response: failed, error:\(error!)")
                completed?(error)
            }
        }
    }
    
    public func getRtcAuthToken(channelId: String, userId: String, completed: ((_ token: String?, _ error: Error?) -> Void)?) {
        
//        if !AUIAICallAppServer.serverAuthValid() {
//            completed?(nil, NSError.aicall_create(code: -1, message: "lack of auth token"))
//            return
//        }
        
        let body = [
            "channel_id": channelId,
            "user_id": userId
        ]
        AUIAICallAppServer.request(path: "/api/v1/imsRobot/getRtcAuthToken", body: body) { response, data, error in
            if error == nil {
                debugPrint("getRtcAuthToken response: success")
                let rtc_auth_token = data?["rtc_auth_token"] as? String
                completed?(rtc_auth_token, nil)
            }
            else {
                debugPrint("getRtcAuthToken response: failed, error:\(error!)")
                completed?(nil, error)
            }
        }
    }
    
    
    public func sendMessage(model: ARTCAICallMessageSendModel, completed: ((Error?) -> Void)?) {
        let ret = self.sendMsgToDataChannel(model: model)
        if ret {
            completed?(nil)
        }
        else {
            completed?(NSError.aicall_create(code: -1, message: "send message failed"))
        }
    }
    
    public weak var receivedMessageDelegate: ARTCAICallMessageDelegate? = nil
    
    private weak var rtcEngine: AliRtcEngine? = nil
}

extension ARTCAICallServiceImpl: ARTCAICallRTCBridgeDelegate {
    
    public func onSetupRtcEngine(rtcEngine: AnyObject?) {
        self.rtcEngine = rtcEngine as? AliRtcEngine
    }
    
    public func onWillReleaseEngine() {
        self.rtcEngine = nil
    }
    
    public func onDataChannelMessage(uid: String, controlMsg: AnyObject) {
        guard let rtcMsg = controlMsg as? AliRtcDataChannelMsg else {
            return
        }
        if rtcMsg.type != .custom {
            return
        }
        
        let dataDict = (try? JSONSerialization.jsonObject(with: rtcMsg.data, options: .allowFragments)) as? [String : Any]
        guard let dataDict = dataDict else {
            return
        }
        debugPrint("onDataChannelMessage:\(dataDict)")
        guard let type = dataDict["type"] as? Int32 else {
            return
        }
        guard let type = ARTCAICallMessageType(rawValue: type) else {
            return
        }
        
        let receive = ARTCAICallMessageReceiveModel()
        receive.type = type
        receive.seqId = dataDict["seqId"] as? Int64
        receive.senderId = dataDict["senderId"] as? String
        receive.receiverId = dataDict["receiverId"] as? String
        receive.data = dataDict["data"] as? [String: Any]
        self.receivedMessageDelegate?.onReceivedMessage(model: receive)
    }
    
    private func sendMsgToDataChannel(model: ARTCAICallMessageSendModel) -> Bool {
        if self.rtcEngine == nil {
            return false
        }
        
        var sendDict: [String: Any] = [
            "type": model.type.rawValue,
        ]
        if let senderId = model.senderId {
            sendDict.updateValue(senderId, forKey: "senderId")
        }
        if let receiverId = model.receiverId {
            sendDict.updateValue(receiverId, forKey: "receiverId")
        }
        if let data = model.data {
            sendDict.updateValue(data, forKey: "data")
        }

        if let sendData = sendDict.aicall_jsonString.data(using: .utf8) {
            let rtcMsg = AliRtcDataChannelMsg()
            rtcMsg.type = .custom
            rtcMsg.data = sendData
            return self.rtcEngine?.sendDataChannelMessage(rtcMsg) == 0
        }
        return false
    }
    
    
}
