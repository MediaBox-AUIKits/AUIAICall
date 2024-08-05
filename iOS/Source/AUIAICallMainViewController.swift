//
//  AUIAICallMainViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallMainViewController: AVBaseViewController {
    
    deinit {
        debugPrint("deinit:\(self)")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleView.text = AUIAICallBundle.getString("Intelligent Call")
        self.hiddenMenuButton = false
        self.menuButton.addTarget(self, action: #selector(onMenuBtnClick), for: .touchUpInside)
        
        self.view.insertSubview(self.bgView, at: 0)
        self.contentView.addSubview(self.startCallBtn)
        
        AUIAICallManager.defaultManager.robotId =  UserDefaults.standard.object(forKey: "aui_current_robot_id") as? String
    }
    
    open lazy var bgView: UIImageView = {
        let view = UIImageView(frame: self.view.bounds)
        view.contentMode = .scaleAspectFill
        view.image = AUIAICallBundle.getCommonImage("bg_main.jpg")
        return view
    }()
    
    open lazy var startCallBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0, height: 44.0))
        btn.layer.cornerRadius = 22.0
        btn.layer.masksToBounds = true
        btn.setTitle(AUIAICallBundle.getString("Start"), for: .normal)
        btn.setBackgroundColor(AVTheme.colourful_fill_strong, for: .normal)
        btn.setBackgroundColor(AVTheme.colourful_fill_disabled, for: .disabled)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.addTarget(self, action: #selector(onStartCallBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    @objc open func onStartCallBtnClicked() {
        AUIAICallManager.defaultManager.startCall(viewController: self)
    }
    
    @objc open func onMenuBtnClick() {
        let robotId = AUIAICallManager.defaultManager.robotId
        AVAlertController.showInput(robotId, title: AUIAICallBundle.getString("Please Enter the Robot ID"), message: AUIAICallBundle.getString("Leave Blank to Use the Default Robot"), okTitle: AUIAICallBundle.getString("Enable & Save"), cancelTitle: nil, vc: self) { input, cancel in
            if cancel == false {
                AUIAICallManager.defaultManager.robotId = input
                UserDefaults.standard.set(input, forKey: "aui_current_robot_id")
            }
        }
    }
    
    
}
