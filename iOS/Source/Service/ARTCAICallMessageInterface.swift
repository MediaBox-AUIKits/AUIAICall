//
//  ARTCAICallMessageInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

@objc public enum ARTCAICallMessageType: Int32 {
    
    case None = 0
    case RobotStateChanged = 1001
    case RobotLLMSpeaking = 1002
    case RobotASRResult = 1003
    
    case InterruptSpeaking = 1101
    
}

@objcMembers open class ARTCAICallMessageSendModel: NSObject {
    open var type: ARTCAICallMessageType = .None
    open var data: [AnyHashable: Any]? = nil
    open var senderId: String? = nil
    open var receiverId: String? = nil
}

@objcMembers open class ARTCAICallMessageReceiveModel: NSObject {
    open var type: ARTCAICallMessageType = .None
    open var data: [AnyHashable: Any]? = nil
    open var senderId: String? = nil
    open var receiverId: String? = nil
}

@objc public protocol ARTCAICallMessageDelegate {
    @objc func onReceivedMessage(model: ARTCAICallMessageReceiveModel)
}


@objc public protocol ARTCAICallMessageInterface {
    
    @objc func sendMessage(model: ARTCAICallMessageSendModel, completed: ((_ error: Error?) -> Void)?)

    @objc weak var receivedMessageDelegate: ARTCAICallMessageDelegate? { get set }
}

