//
//  AUIAICallMainViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

public let AUIAIMainBundle = AUIAICallTheme("AUIAIMain")


@objcMembers open class AUIAICallMainViewController: AVBaseViewController {
    
    deinit {
        debugPrint("deinit:\(self)")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = AVTheme.bg_medium
        self.titleView.text = AUIAIMainBundle.getString("AIAgent")
        
#if DEMO_FOR_DEBUG
        self.hiddenMenuButton = false
        self.menuButton.addTarget(self, action: #selector(onMenuBtnClick), for: .touchUpInside)
        AUIAICallDebugManager.shared.setup()
#else
        self.hiddenMenuButton = true
#endif
        
        self.contentView.addSubview(self.agentTypeBgView)
        self.agentTypeBgView.addSubview(self.agentSeletctBgView)
        self.agentTypeBgView.addSubview(self.sysAgentBtn)
        self.agentTypeBgView.addSubview(self.cusAgentBtn)

        
        self.contentView.addSubview(self.configCallBtn)
        self.contentView.addSubview(self.startCallBtn)
        
        self.contentView.addSubview(self.sysAgentTabView)
        self.contentView.addSubview(self.sysAgentContentView)
        self.contentView.addSubview(self.cusAgentContentView)

        self.sysAgentTabView.agentWillChanged = { [weak self] agentIndex in
            self?.sysAgentContentView.scrollToAgent(agentIndex)
            self?.onTabIndexChanged()
        }
        self.sysAgentContentView.pageChanged = { [weak self] agentIndex in
            self?.sysAgentTabView.agentIndex = agentIndex
            self?.onTabIndexChanged()
        }
        self.sysAgentContentView.outboundCallView.onInputPhoneNumberChanged = { [weak self] in
            self?.onTabIndexChanged()
        }
        
        self.selectAgent(isCus: false, isAni: false)
        
        // 提前获取Token
        AUIAICallAuthTokenHelper.shared.fetchAuthToken(userId: AUIAICallManager.defaultManager.userId!, completed: nil)
    }
    
    open lazy var agentTypeBgView: UIView = {
        let view = UIView(frame: CGRect(x: 20.0, y: 16.0, width: self.contentView.av_width - 20.0 - 20.0, height: 46))
        view.layer.cornerRadius = view.av_height / 2.0
        view.layer.borderWidth = 1
        view.layer.borderColor = AVTheme.border_weak.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    open lazy var agentSeletctBgView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.agentTypeBgView.av_width / 2.0, height: self.agentTypeBgView.av_height))
        view.layer.cornerRadius = view.av_height / 2.0
        view.layer.borderWidth = 1
        view.layer.borderColor = AVTheme.border_infrared.cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = AVTheme.bg_weak
        return view
    }()
    
    open lazy var sysAgentBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: 0.0, y: 0.0, width: self.agentTypeBgView.av_width / 2.0, height: self.agentTypeBgView.av_height))
        btn.setTitle(AUIAIMainBundle.getString("Official Agent"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.clickBlock = { [weak self] sender in
            self?.selectAgent(isCus: false, isAni: true)
        }
        return btn
    }()
    
    open lazy var cusAgentBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.agentTypeBgView.av_width / 2.0, y: 0.0, width: self.agentTypeBgView.av_width / 2.0, height: self.agentTypeBgView.av_height))
        btn.setTitle(AUIAIMainBundle.getString("Custom Agent"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.clickBlock = { [weak self] sender in
            self?.selectAgent(isCus: true, isAni: true)
        }
        return btn
    }()
    
    open lazy var configCallBtn: AVBaseButton = {
        let btn = AVBaseButton.imageText(with: .bottom)
        btn.frame = CGRect(x: self.contentView.av_width - 48 - 24, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: 48, height: 44)
        btn.title = AUIAIMainBundle.getString("Options")
        btn.image = AUIAIMainBundle.getCommonImage("ic_agent_config")
        btn.color = AVTheme.text_weak
        btn.font = AVTheme.regularFont(10)
        btn.action = { [weak self] sender in
            guard let self = self else {
                return
            }
            
            let panel = AUIAICallAgentConfigPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
            panel.show(on: self.view, with: .clickToClose)
        }
        return btn
    }()
    
    open lazy var startCallBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0 - 32 - 8, height: 44.0))
        btn.layer.cornerRadius = 22.0
        btn.layer.masksToBounds = true
        btn.setTitle(AUIAIMainBundle.getString("Start"), for: .normal)
        btn.setBackgroundColor(AVTheme.colourful_fill_strong, for: .normal)
        btn.setBackgroundColor(UIColor.av_color(withHexString: "004C61"), for: .disabled)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_ultraweak, for: .disabled)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.clickBlock = { [weak self] sender in
            guard let self = self else {
                return
            }
            let isCus = self.cusAgentBtn.isSelected == true
            if isCus {
                let authToken = self.cusAgentContentView.inputField.text ?? ""
                if authToken.isEmpty {
                    AVAlertController.show(AUIAIMainBundle.getString("Please Scan Code to Get Authorized Token"), vc: self)
                    return
                }
                if let ret = AUIAICallMainViewController.checkAuthToken(authToken: authToken) {
                    if ret.agentIndex == ChatAgentTypeIndex {
                        self.startChat(agentShareInfo: authToken)
                    }
                    else {
                        self.startCall(agentShareInfo: authToken)
                    }
                }
            }
            else {
                let agentIndex = self.sysAgentTabView.agentIndex
                if agentIndex == ChatAgentTypeIndex {
                    self.startChat()
                }
                else if agentIndex == OutboundCallTypeIndex {
                    let outboundCallView = self.sysAgentContentView.outboundCallView
                    guard let phoneNumber = outboundCallView.phoneNumber else { return }
                    AUIAICallManager.defaultManager.startOutboundCall(phoneNumber: phoneNumber, voiceId: outboundCallView.voiceId, enableVoiceInterrupt: outboundCallView.isVoiceInterrupted, viewController: self)
                }
                else {
                    self.startCall(agentType: ARTCAICallAgentType(rawValue: Int32(agentIndex))!)
                }
            }
        }
        return btn
    }()
    
    lazy var sysAgentTabView: AUIAICallSysAgentTabView = {
        let tabView = AUIAICallSysAgentTabView(frame: CGRect(x: 0, y: self.agentTypeBgView.av_bottom + 24.0, width: self.contentView.av_width, height: 34.0))
        return tabView
    }()
    
    open lazy var sysAgentContentView: AUIAICallSysAgentContentView = {
        let view = AUIAICallSysAgentContentView(frame: CGRect(x: 20, y: self.sysAgentTabView.av_bottom + 30, width: self.contentView.av_width - 40, height: self.startCallBtn.av_top - self.sysAgentTabView.av_bottom - 32 - 32))
        return view
    }()
    
    open lazy var cusAgentContentView: AUIAICallCusAgentContentView = {
        let view = AUIAICallCusAgentContentView(frame: CGRect(x: 20, y: self.cusAgentBtn.av_bottom + 16, width: self.contentView.av_width - 40, height: self.startCallBtn.av_top - self.cusAgentBtn.av_bottom - 16 - 38))
#if !DEMO_FOR_DEBUG
        view.inputField.isEnabled = false
#endif
        view.scanBtn.clickBlock = { [weak self] btn in
            let qr = AVQRCodeScanner()
            qr.scanResultBlock = { scaner, content in
                scaner.navigationController?.popViewController(animated: true)
                if let _ = AUIAICallMainViewController.checkAuthToken(authToken: content) {
                    self?.cusAgentContentView.inputField.text = content
                }
            }
            self?.navigationController?.pushViewController(qr, animated: true)
        }
        return view
    }()

#if DEMO_FOR_DEBUG
    @objc open func onMenuBtnClick() {
        AUIAICallDebugManager.shared.openSetting(self)
    }
#endif
    
    open func onTabIndexChanged() {
        var visible = false
        if self.sysAgentBtn.isSelected == true {
            let agentIndex = self.sysAgentTabView.agentIndex
            if agentIndex != ChatAgentTypeIndex && agentIndex != OutboundCallTypeIndex {
                visible = true
            }
        }
        self.configCallBtn.isHidden = !visible
        self.startCallBtn.frame = visible ? CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0 - 32 - 8, height: 44.0) : CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0, height: 44.0)
        
        var enable = true
        if self.sysAgentBtn.isSelected == true {
            if self.sysAgentTabView.agentIndex == OutboundCallTypeIndex {
                enable = self.sysAgentContentView.outboundCallView.phoneNumber?.isEmpty == false
            }
        }
        self.startCallBtn.isEnabled = enable

    }
    
    open func selectAgent(isCus: Bool, isAni: Bool) {
        if isCus {
            self.cusAgentBtn.isSelected = true
            self.cusAgentBtn.titleLabel?.font = AVTheme.mediumFont(14)
            self.sysAgentBtn.isSelected = false
            self.sysAgentBtn.titleLabel?.font = AVTheme.regularFont(14)
            self.sysAgentTabView.isHidden = true
            self.cusAgentContentView.isHidden = false
            self.sysAgentContentView.isHidden = true
        }
        else {
            self.sysAgentBtn.isSelected = true
            self.sysAgentBtn.titleLabel?.font = AVTheme.mediumFont(14)
            self.cusAgentBtn.isSelected = false
            self.cusAgentBtn.titleLabel?.font = AVTheme.regularFont(14)
            self.sysAgentTabView.isHidden = false
            self.sysAgentContentView.isHidden = false
            self.cusAgentContentView.isHidden = true
        }
        self.onTabIndexChanged()
        if isAni {
            UIView.animate(withDuration: 0.25) {
                self.agentSeletctBgView.av_left = isCus ? self.cusAgentBtn.av_left : 0.0
            } completion: { _ in
                self.agentSeletctBgView.av_left = isCus ? self.cusAgentBtn.av_left : 0.0
            }
        }
        else {
            self.agentSeletctBgView.av_left = isCus ? self.cusAgentBtn.av_left : 0.0
        }
    }
    
    open func startCall(agentShareInfo: String) {
        AUIAICallManager.defaultManager.startCall(agentShareInfo: agentShareInfo, viewController: self)
    }
    
    open func startCall(agentType: ARTCAICallAgentType, agentId: String? = nil, region: String? = nil) {
        if agentType == .AvatarAgent || agentType == .VideoAgent {
            let seconds: UInt32 = 5 * 60
            AUIAICallManager.defaultManager.startCall(agentType: agentType, agentId: agentId, region: region, limitSecond: seconds, viewController: self)
            return
        }
        
        AUIAICallManager.defaultManager.startCall(agentType: agentType, agentId: agentId, region: region, viewController: self)
    }
    
    open func startChat(agentId: String? = nil) {
        AUIAICallManager.defaultManager.startChat(agentId: agentId, viewController: self)
    }
    
    open func startChat(agentShareInfo: String) {
        AUIAICallManager.defaultManager.startChat(agentShareInfo: agentShareInfo, viewController: self)
    }
    
    static func checkAuthToken(authToken: String) -> (agentId: String, agentIndex: Int, region: String?)? {
        let json = authToken.aicall_decodeBase64AndDeserialize()
        guard let json = json else {
            AVAlertController.show(AUIAIMainBundle.getString("Invalid Token"))
            return nil
        }
        
        let expireTime = json["ExpireTime"] as? String
        guard let expireTime = expireTime else {
            AVAlertController.show(AUIAIMainBundle.getString("Invalid Token"))
            return nil
        }
        if expireTime.aicall_isDateStringExpired() {
            AVAlertController.show(AUIAIMainBundle.getString("Token Expire"))
            return nil
        }
        
        let agentId = json["TemporaryAIAgentId"] as? String
        guard let agentId = agentId else {
            AVAlertController.show(AUIAIMainBundle.getString("Invalid Token"))
            return nil
        }
        
        let workflowType = json["WorkflowType"] as? String
        var agentIndex: Int = VoiceAgentTypeIndex
        if workflowType == "VoiceChat" {
            agentIndex = VoiceAgentTypeIndex
        }
        else if workflowType == "AvatarChat3D" {
            agentIndex = AvatarAgentTypeIndex
        }
        else if workflowType == "VisionChat" {
            agentIndex = VisionAgentTypeIndex
        }
        else if workflowType == "VideoChat" {
            agentIndex = VideoAgentTypeIndex
        }
        else if workflowType == "MessageChat" {
            agentIndex = ChatAgentTypeIndex
        }
        else {
            AVAlertController.show(AUIAIMainBundle.getString("Invalid Token"))
            return nil
        }

        let region = json["Region"] as? String
        
        return (agentId, agentIndex, region)
    }
}
