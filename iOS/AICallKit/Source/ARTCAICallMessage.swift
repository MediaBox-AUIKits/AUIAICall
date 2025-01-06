//
//  ARTCAICallMessageInterface.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit

@objc public enum ARTCAICallMessageType: Int32 {
    
    case None = 0
    case AgentErrorOccurs = 1000
    case AgentStateChanged = 1001
    case AgentSubtitleNotify = 1002
    case UserSubtitleNotify = 1003
    case VoiceInterruptChanged = 1004
    case VoiceIdChanged = 1005
    case RTCTokenResponsed = 1006
    case PushToTalkChanged = 1007
    case VoiceprintUsingChanged = 1008
    case VoiceprintClearSucceed = 1009
    case AgentWillLeave = 1010
    case CustomMessageReceived = 1011
    case HumanTakeoverWillStart = 1012
    case HumanTakeoverConnected = 1013
    case AgentEmotionNotify = 1014
    
    case StopAIAgent = 1100
    case InterruptSpeaking = 1101
    case EnableVoiceInterrupt = 1102
    case SwitchVoiceId = 1103
    case RequestRTCToken = 1104
    case EnablePushToTalk = 1105
    case StartPushToTalk = 1106
    case FinishPushToTalk = 1107
    case CancelPushToTalk = 1108
    case UseVoiceprint = 1109
    case ClearVoiceprint = 1110
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
    open var seqId: Int64? = nil
    open var senderId: String? = nil
    open var receiverId: String? = nil
}
