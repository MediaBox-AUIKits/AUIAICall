//
//  MainViewController.swift
//  Example
//
//  Created by Bingo on 2024/1/10.
//

import UIKit
import AUIFoundation
import AUIAICall

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
#if DEBUG
        
        
#endif
        self.showCallAgentEntrance()
        self.showChatAgentEntrance()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMainViewController(ani: false)
        }
    }
    
    func showMainViewController(ani: Bool) {
        let vc = AUIAICallMainViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showCallAgentEntrance() {
        
        let btn = AVBlockButton(frame: CGRect(x: 48, y: 100, width: 120, height: 40))
        btn.setTitle("VoiceCall", for: .normal)
        btn.av_setLayerBorderColor(UIColor.black, borderWidth: 1.0)
        btn.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(btn)
        
        btn.clickBlock = { sender in
            AUIAICallManager.defaultManager.startCall(agentType: .VoiceAgent)
        }
    }
    
    func showChatAgentEntrance() {
        
        let btn = AVBlockButton(frame: CGRect(x: 48, y: 180, width: 120, height: 40))
        btn.setTitle("Chatbot", for: .normal)
        btn.av_setLayerBorderColor(UIColor.black, borderWidth: 1.0)
        btn.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(btn)
        
        btn.clickBlock = { sender in
            AUIAICallManager.defaultManager.startChat(agentId: nil)
        }
    }
}

