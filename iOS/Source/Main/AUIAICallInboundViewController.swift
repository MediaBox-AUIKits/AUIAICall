//
//  AUIAICallInboundViewController.swift
//  Pods
//
//  Created by Bingo on 2025/6/20.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallInboundViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AUIAIMainBundle.color_bg
        
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.numberLabel)
        self.view.addSubview(self.inputFieldContainer)
        self.view.addSubview(self.numberTipsLabel)
        self.view.addSubview(self.refreshBtn)
        self.view.addSubview(self.aiGenTipsLabel)
        self.view.addSubview(self.startCallBtn)

        self.fetchCalledNumber()
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open lazy var backBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_back"), for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon
        btn.setTitle(AUIAIMainBundle.getString("AI Call In"), for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        btn.titleLabel?.font = AVTheme.mediumFont(16)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        btn.sizeToFit()
        btn.frame = CGRect(x: 24, y: UIView.av_safeTop, width: btn.av_width + 12, height: 48)
        btn.clickBlock = { [weak self] sender in
            self?.navigationController?.popViewController(animated: true)
        }
        return btn
    }()
    
    open lazy var numberLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = AUIAIMainBundle.getString("Agent Number")
        label.textColor = AUIAIMainBundle.color_text
        label.font = AVTheme.regularFont(16)
        label.sizeToFit()
        label.av_left = 24
        label.av_top = self.backBtn.av_bottom + 24
        return label
    }()
    
    open lazy var inputFieldContainer: UIView = {
        let view = UIView(frame: CGRect(x: 24, y: self.numberLabel.av_bottom + 12, width: self.view.av_width - 24 - 24 , height: 44))
        view.backgroundColor = AUIAIMainBundle.color_fill_secondary
        
        self.copyBtn.frame = CGRect(x: view.av_width - 16 - 20, y: 0, width: 20, height: view.av_height)
        view.addSubview(self.copyBtn)
        
        self.inputField.frame = CGRect(x: 16, y: 0, width: self.copyBtn.av_left - 16 - 16, height: view.av_height)
        view.addSubview(self.inputField)
        
        
        return view
    }()
    
    open lazy var copyBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_copy"), for: .normal)
        btn.clickBlock = { [weak self] btn in
            guard let self = self, let phoneNumber = self.inputField.text else { return }
            UIPasteboard.general.string = phoneNumber
            self.view.aicall_showToast(AUIAIMainBundle.getString("The agent number has been copied."))
        }
        btn.isEnabled = false
        btn.tintColor = AUIAIMainBundle.color_icon_disabled
        return btn
    }()
    
    open lazy var inputField: UITextField = {
        let input = UITextField(frame: CGRect.zero)
        input.textColor = AUIAIMainBundle.color_text
        input.keyboardType = .phonePad
        input.font = AVTheme.regularFont(14)
        input.tintColor = AUIAIMainBundle.color_primary
        input.isEnabled = false
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AUIAIMainBundle.color_text_tertiary,
            .font: AVTheme.regularFont(14)
        ]
        input.attributedPlaceholder = NSAttributedString(string: "-", attributes: attributes)
        return input
    }()
    
    open lazy var numberTipsLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = AUIAIMainBundle.getString("This number is from the console configuration")
        label.textColor = AUIAIMainBundle.color_text_tertiary
        label.font = AVTheme.regularFont(14)
        label.sizeToFit()
        label.av_left = 24
        label.av_top = self.inputFieldContainer.av_bottom + 8
        return label
    }()
    
    open lazy var refreshBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.numberTipsLabel.av_right + 8, y: 0, width: 24, height: 24))
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_refresh"), for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon_tertiary
        btn.av_centerY = self.numberTipsLabel.av_centerY
        btn.clickBlock = { [weak self] btn in
            self?.fetchCalledNumber()
        }
        return btn
    }()
    
    open lazy var startCallBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 25.0, y: self.aiGenTipsLabel.av_top - 12.0 - 44.0, width: self.view.av_width - 25.0 - 25.0, height: 44.0))
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
        btn.setTitle(AUIAIMainBundle.getString("Call Immediately"), for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_Inverse, for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill_disabled, for: .disabled)
        btn.setTitleColor(AUIAIMainBundle.color_text_disabled, for: .disabled)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.isEnabled = false
        btn.clickBlock = { [weak self] sender in
            
            guard let self = self, let phoneNumber = self.inputField.text else {
                return
            }
            
            if let url = URL(string: "tel://\(phoneNumber)") {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        debugPrint("无法打开电话功能，请检查设备设置")
                    }
                }
            }
             
        }
        return btn
    }()
    
    open lazy var aiGenTipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = AUIAIMainBundle.color_text_tertiary
        label.textAlignment = .center
        label.font = AVTheme.regularFont(11)
        label.text = AUIAIMainBundle.getString("Content generated by AI, for reference only.")
        label.isUserInteractionEnabled = false
        
        label.sizeToFit()
        label.center = CGPoint(x: self.view.av_width / 2.0, y: self.view.av_height - (UIView.av_safeBottom > 0 ? UIView.av_safeBottom - 16 : 0) - label.av_height / 2.0)
        return label
    }()
    
    internal var appserver: AUIAICallAppServer? = nil
        
    public func fetchCalledNumber() {
        
#if DEMO_FOR_DEBUG
        let agentId = AUIAICallDebugManager.shared.getInboundCallAgentId()
        let region = AUIAICallDebugManager.shared.getRegion()
#else
        let agentId = InboundAgentId
        let region = Region
#endif
        let body: [String: Any] = [
            "user_id": AUIAICallManager.defaultManager.userId ?? "",
            "ai_agent_id": agentId,
            "region": region,
        ]
        
        let hud = self.view.aicall_showProgressHud(AUIAIMainBundle.getString("Getting the agent number..."))
        
        if self.appserver == nil {
            self.appserver = AUIAICallAppServer()
        }
        
        self.appserver?.request(path: "/api/v2/aiagent/describeAIAgent", body: body) { [weak self] response, data, error in
            hud.hide(animated: true)
            guard let self = self else {
                return
            }
            self.appserver = nil
            
            if let agent_config = data?["ai_agent"] as? String, let dict = agent_config.aicall_jsonObj() {
                if let inboundPhoneNumber  = (dict["InboundPhoneNumbers"] as? [String])?.first {
                    self.inputField.text = inboundPhoneNumber
                    if self.inputField.text?.isEmpty == false {
                        self.copyBtn.isEnabled = true
                        self.copyBtn.tintColor = AUIAIMainBundle.color_icon
                        self.startCallBtn.isEnabled = true
                    }
                    else {
                        self.copyBtn.isEnabled = false
                        self.copyBtn.tintColor = AUIAIMainBundle.color_icon_disabled
                        self.startCallBtn.isEnabled = false
                    }
                    return
                }
            }
            
            self.view.aicall_showToast(AUIAIMainBundle.getString("Failed to get the number, please refresh and try again."))
        }
    }
}
