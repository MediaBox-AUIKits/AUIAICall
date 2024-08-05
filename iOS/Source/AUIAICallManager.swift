//
//  AUIAICallManager.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallManager: NSObject {
    
    public static let defaultManager = AUIAICallManager()
    
    public override init() {
        super.init()
    }
    
    public var userId: String? = nil
    public var robotId: String? = nil
    
    open func startCall(viewController: UIViewController? = nil) {
        
        if self.userId == nil {
            self.userId = NSString.av_random()
        }
        
        AVDeviceAuth.checkMicAuth { auth in
            if auth == false {
                return
            }
            
            let engine = ARTCAICallEngine(userId: self.userId!)
            engine.config.robotId = self.robotId
            let vc = AUIAICallViewController(engine)
            let topVC = viewController ?? UIViewController.av_top()
            topVC.av_presentFullScreenViewController(vc, animated: false)
        }
    }
}
