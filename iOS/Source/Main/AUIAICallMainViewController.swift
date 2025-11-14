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


@objcMembers open class AUIAICallMainViewController: UIViewController {
    
    deinit {
        debugPrint("deinit:\(self)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = AUIAIMainBundle.color_bg
        
        self.view.addSubview(self.bgLineView)
        self.view.addSubview(self.headerView)
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.startCallBtn)
        
        self.setupDebug()
        
        self.contentView.addSubview(self.mainTabView)
        self.contentView.addSubview(self.mainInfoView)

        // 提前获取Token
        AUIAICallAuthTokenHelper.shared.fetchAuthToken(userId: AUIAICallManager.defaultManager.userId!, completed: nil)
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
    
    open lazy var bgLineView: AUIAICallBgLineView = {
        let view = AUIAICallBgLineView(frame: self.view.bounds, gradient: false)
        return view
    }()
    
    open lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: UIView.av_safeTop, width: self.view.av_width, height: 0))
        
        let themeBtn = AVBlockButton(frame: CGRect(x: 24, y: 6, width: 36, height: 36))
        themeBtn.setImage(AUIAIMainBundle.getTemplateImage("ic_theme_light"), for: .normal)
        themeBtn.setImage(AUIAIMainBundle.getTemplateImage("ic_theme_dark"), for: .selected)
        themeBtn.tintColor = AUIAIMainBundle.color_icon
        themeBtn.av_setLayerBorderColor(AUIAIMainBundle.color_border_tertiary, borderWidth: 1)
        themeBtn.layer.cornerRadius = 18
        themeBtn.backgroundColor = AUIAIMainBundle.color_bg_elevated
        themeBtn.isSelected = AVTheme.currentMode == .dark
        themeBtn.clickBlock = { sender in
            AVTheme.currentMode = sender.isSelected ? .light : .dark
            sender.isSelected = !sender.isSelected
        }
        view.addSubview(themeBtn)
        
        let rightView = UIView(frame: CGRect(x: view.av_width - 92 - 24, y: 7, width: 92, height: 34))
        rightView.av_setLayerBorderColor(AUIAIMainBundle.color_border_tertiary, borderWidth: 1)
        rightView.layer.cornerRadius = 17
        rightView.backgroundColor = AUIAIMainBundle.color_bg_elevated
        view.addSubview(rightView)
        
        let settingBtn = AVBlockButton(frame: CGRect(x: 0, y: 0, width: rightView.av_width / 2.0, height: rightView.av_height))
        settingBtn.setImage(AUIAIMainBundle.getTemplateImage("ic_setting"), for: .normal)
        settingBtn.tintColor = AUIAIMainBundle.color_icon
        settingBtn.clickBlock = { [weak self] sender in
            guard let self = self else {
                return
            }
            let panel = AUIAICallAgentConfigPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
            panel.voiceprintSettingView.registerBar.tappedAction = { [weak self, weak panel] bar in
                panel?.hide()
                if let self = self {
                    self.navigationController?.pushViewController(AUIAICallVoiceprintViewController(), animated: true)
                }
            }
            panel.show(on: self.view, with: .clickToClose)
        }
        rightView.addSubview(settingBtn)
        
        let splitView = UIView(frame: CGRect(x: rightView.av_width / 2.0, y: 8, width: 1.0, height: 18))
        splitView.backgroundColor = AUIAIMainBundle.color_border_tertiary
        rightView.addSubview(splitView)
        
        let exitBtn = AVBlockButton(frame: CGRect(x: rightView.av_width / 2.0, y: 0, width: rightView.av_width / 2.0, height: rightView.av_height))
        exitBtn.setImage(AUIAIMainBundle.getTemplateImage("ic_exit"), for: .normal)
        exitBtn.tintColor = AUIAIMainBundle.color_icon
        exitBtn.clickBlock = { [weak self] sender in
            self?.goBack()
        }
        rightView.addSubview(exitBtn)
        
        
        let titleView = UIImageView(frame: CGRect(x: 25, y: 57, width: 0, height: 0))
        if AVLocalization.isInternational() {
            titleView.image = AUIAIMainBundle.getTemplateImage("img_title_eng")
        }
        else {
            titleView.image = AUIAIMainBundle.getTemplateImage("img_title")
        }
        titleView.tintColor = AUIAIMainBundle.color_icon
        titleView.sizeToFit()
        view.addSubview(titleView)
        
        view.av_height = titleView.av_bottom
        return view
    }()
    
    open lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: self.headerView.av_bottom, width: self.view.av_width, height: self.view.av_height - self.headerView.av_bottom))
        return view
    }()
    
    
    open lazy var startCallBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 25.0, y: self.contentView.av_height - 12.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 25.0 - 25.0, height: 44.0))
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
        btn.setImage(nil, for: .normal)
        btn.setTitle(AUIAIMainBundle.getString("Start"), for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_Inverse, for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon_Inverse
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.isHighlighted = false
        btn.clickBlock = { [weak self] sender in
            
            guard let self = self else {
                return
            }
            
            let tabIndex = self.mainTabView.currTabItem.index
            if tabIndex == .CustomAgent {
                self.startCustomAgent()
            }
            else if tabIndex == .InboundCall {
                self.startInbound()
            }
            else if tabIndex == .OutboundCall {
                self.startOutbound()
                
            }
            else if tabIndex == .ChatAgent {
                self.startChat()
            }
            else {
                self.startCall(agentType: ARTCAICallAgentType(rawValue: Int32(tabIndex.rawValue))!)
            }
        }
        return btn
    }()
    
    
    lazy var mainTabView: AUIAICallMianTabView = {
        let tabView = AUIAICallMianTabView(frame: CGRect(x: 0, y: 16.0, width: self.contentView.av_width, height: 40.0))
        tabView.tabWillChanged = { [weak self] item, posIndex in
            self?.mainInfoView.currTabItem = item
            self?.mainInfoView.contentShowView.scrollView.scroll(item)
            self?.updateStartBtn()
        }
        return tabView
    }()
    
    open lazy var mainInfoView: AUIAICallMainInfoView = {
        let view = AUIAICallMainInfoView(frame: CGRect(x: 0, y: self.mainTabView.av_bottom, width: self.contentView.av_width, height: self.startCallBtn.av_top - self.mainTabView.av_bottom))
        view.contentShowView.scrollView.tabWillChanged = { [weak self] item, posIndex in
            self?.mainTabView.currTabItem = item
            self?.mainInfoView.currTabItem = item
            self?.updateStartBtn()
        }
        return view
    }()
    
    func goBack() {
        if let nv = self.navigationController {
            nv.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    func updateStartBtn() {
        if self.mainTabView.currTabItem.index == .CustomAgent {
            self.startCallBtn.setImage(AUIAIMainBundle.getTemplateImage("ic_scan"), for: .normal)
            self.startCallBtn.setTitle(AUIAIMainBundle.getString("Start Scan"), for: .normal)
        }
        else {
            self.startCallBtn.setImage(nil, for: .normal)
            self.startCallBtn.setTitle(AUIAIMainBundle.getString("Start"), for: .normal)
        }
        
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
    
    open func startOutbound() {
        let vc = AUIAICallOutboundViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    open func startInbound() {
        let vc = AUIAICallInboundViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// shareInfo
extension AUIAICallMainViewController {

    open func startCustomAgent() {
#if DEMO_FOR_DEBUG
        let enableInput = AUIAICallDebugManager.shared.customAgentInputAuthToken
#else
        let enableInput = false
#endif
        let openBlock: (_ authToken: String) -> Void = { authToken in
            if let ret = AUIAICallMainViewController.checkAuthToken(authToken: authToken) {
                if ret.agentIndex == ChatAgentTypeIndex {
                    self.startChat(agentShareInfo: authToken)
                }
                else {
                    self.startCall(agentShareInfo: authToken)
                }
            }
        }
        if enableInput {
            AVAlertController.showInput("Auth Token", vc: self) { content in
                if content.count > 0 {
                    openBlock(content)
                }
            }
        }
        else {
            let qr = AVQRCodeScanner()
            qr.scanResultBlock = { scaner, content in
                scaner.navigationController?.popViewController(animated: true)
                openBlock(content)
            }
            self.navigationController?.pushViewController(qr, animated: true)
        }
        
    }
    
    open func startCall(agentShareInfo: String) {
        AUIAICallManager.defaultManager.startCall(agentShareInfo: agentShareInfo, viewController: self)
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

extension AUIAICallMainViewController {
    
    func setupDebug() {
#if DEMO_FOR_DEBUG
        AUIAICallDebugManager.shared.setup()
        
        let debugBtn = AVBlockButton(frame: CGRect.zero)
        debugBtn.setTitle("Debug", for: .normal)
        debugBtn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        debugBtn.backgroundColor = AUIAIMainBundle.color_bg_elevated
        debugBtn.clickBlock = { sender in
            AUIAICallDebugManager.shared.openSetting(self)
        }
        debugBtn.sizeToFit()
        debugBtn.center = CGPoint(x: self.view.av_width / 2.0, y: UIView.av_safeTop + 22 )
        self.view.addSubview(debugBtn)
#endif
    }
    
}
