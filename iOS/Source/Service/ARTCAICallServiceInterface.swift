//
//  ARTCAICallServiceInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

@objcMembers open class ARTCAICallRobotInfo: NSObject {
    open var channelId: String = ""
    open var userId: String = ""
    open var token: String = ""
    open var instanceId: String = ""
}

@objc public protocol ARTCAICallServiceInterface: ARTCAICallMessageInterface {
    
    @objc func startRobot(userId: String, config: ARTCAICallConfig, completed: ((_ rsp: ARTCAICallRobotInfo?, _ error: Error?) -> Void)?)
    @objc func stopRobot(instanceId: String, completed: ((_ error: Error?) -> Void)?)
    
    @objc func changedVoice(instanceId: String, voiceId: String, completed: ((_ error: Error?) -> Void)?)
    @objc func enableVoiceInterrupt(instanceId: String, enable: Bool, completed: ((_ error: Error?) -> Void)?)
    @objc func getRtcAuthToken(channelId: String, userId: String, completed: ((_ token: String?, _ error: Error?) -> Void)?)
}
