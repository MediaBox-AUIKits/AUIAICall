//
//  AUIAICallSingletonController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import ARTCAICallKit

#if canImport(AliVCSDK_ARTC)
import AliVCSDK_ARTC
#elseif canImport(AliVCSDK_InteractiveLive)
import AliVCSDK_InteractiveLive
#elseif canImport(AliVCSDK_Standard)
import AliVCSDK_Standard
#endif
@objcMembers open class AUIAICallSingletonController: AUIAICallController {
        
    public override init(userId: String) {
        super.init(userId: userId)
        
        self.engine.createRTCEngine()
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        self.engine.destroy()
    }
    
    override func createCallConfig() -> ARTCAICallConfig {
        let callConfig = super.createCallConfig()
        let audioConfig = ARTCAICallAudioConfig()
        audioConfig.ignoreSetAudioProfile = true
        callConfig.audioConfig = audioConfig
        return callConfig
    }
    
    public override func onRTCEngineCreated() {
        let rtc = self.engine.getRTCInstance() as? AliRtcEngine
        
        rtc?.setAudioProfile(.engineHighQualityMode, audio_scene: .sceneDefaultMode)
        let audioCap = AliRtcAudioCapability()
        audioCap.captureKeepAlive = true
        audioCap.playoutKeepAlive = true
        rtc?.setAudioCapability(audioCap)
        rtc?.startAudioCapture()
        rtc?.setParameter("{\"audio\":{\"user_specified_ahead_push_stream\":true}}");
        super.onRTCEngineCreated()
    }
    
    open override func handup() {
        if self.state != .None {
            self.engine.handup(destroy: false)
//            self.engine.handup(true)
            self.state = .Over
        }
        self.state = .None
    }
}
