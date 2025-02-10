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
            self?.updateConfigBtnVisible()
        }
        self.sysAgentContentView.pageChanged = { [weak self] agentType in
            self?.sysAgentTabView.agentIndex = agentType
            self?.updateConfigBtnVisible()
        }
        
        self.selectAgent(isCus: false, isAni: false)
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
        btn.title = AUIAIMainBundle.getString("Configuration")
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
        btn.setBackgroundColor(AVTheme.fill_medium, for: .disabled)
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
                    if ret.agentIndex == 3 {
                        self.startChat(agentShareInfo: authToken)
                    }
                    else {
                        self.startCall(agentShareInfo: authToken)
                    }
                }
            }
            else {
                let agentIndex = self.sysAgentTabView.agentIndex
                if agentIndex == 3 {
                    self.startChat()
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
        view.inputField.isEnabled = false
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
    
    open func updateConfigBtnVisible() {
        var visible = false
        if self.sysAgentBtn.isSelected == true {
            let agentIndex = self.sysAgentTabView.agentIndex
            if agentIndex != 3 {
                visible = true
            }
        }
        self.configCallBtn.isHidden = !visible
        self.startCallBtn.frame = visible ? CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0 - 32 - 8, height: 44.0) : CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0, height: 44.0)
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
        self.updateConfigBtnVisible()
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
        if agentType == .AvatarAgent {
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
        var agentIndex: Int = 0
        if workflowType == "VoiceChat" {
            agentIndex = 0
        }
        else if workflowType == "AvatarChat3D" {
            agentIndex = 1
        }
        else if workflowType == "VisionChat" {
            agentIndex = 2
        }
        else if workflowType == "MessageChat" {
            agentIndex = 3
        }
        else {
            AVAlertController.show(AUIAIMainBundle.getString("Invalid Token"))
            return nil
        }

        let region = json["Region"] as? String
        
        return (agentId, agentIndex, region)
    }
}


@objcMembers open class AUIAICallSysAgentTabView: UIScrollView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let itemCount = 4.0
        self.audioCallBtn.sizeToFit()
        self.audioCallBtn.av_centerX = self.av_width / (itemCount * 2)
        self.addSubview(self.audioCallBtn)
        
        self.avatarCallBtn.sizeToFit()
        self.avatarCallBtn.av_centerX = self.av_width / (itemCount * 2) * 3
        self.addSubview(self.avatarCallBtn)
        
        self.visionCallBtn.sizeToFit()
        self.visionCallBtn.av_centerX = self.av_width / (itemCount * 2) * 5
        self.addSubview(self.visionCallBtn)
        
        self.chatBtn.sizeToFit()
        self.chatBtn.av_centerX = self.av_width / (itemCount * 2) * 7
        self.addSubview(self.chatBtn)
        
        self.addSubview(self.lineView)
        self.contentSize = CGSize(width: max(self.chatBtn.av_right + 20, self.av_width), height: self.av_height)
        self.showsHorizontalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        self.updateAgent()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var audioCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: 20.0, y: 0, width: 0, height: 0))
        btn.setTitle(AUIAIMainBundle.getString("AI Voice Call"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.mediumFont(12)
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int8 = 0
            self?.agentIndex = agentIndex
            self?.agentWillChanged?(agentIndex)
        }
        return btn
    }()
    
    open lazy var avatarCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.audioCallBtn.av_right + 20.0, y: 0, width: 0, height: 0))
        btn.setTitle(AUIAIMainBundle.getString("AI Avatar Call"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.mediumFont(12)
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int8 = 1
            self?.agentIndex = agentIndex
            self?.agentWillChanged?(agentIndex)
        }
        return btn
    }()
    
    open lazy var visionCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.avatarCallBtn.av_right + 20.0, y: 0, width: 0, height: 0))
        btn.setTitle(AUIAIMainBundle.getString("AI Vision Call"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.mediumFont(12)
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int8 = 2
            self?.agentIndex = agentIndex
            self?.agentWillChanged?(agentIndex)
        }
        return btn
    }()
    
    open lazy var chatBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.visionCallBtn.av_right + 20.0, y: 0, width: 0, height: 0))
        btn.setTitle(AUIAIMainBundle.getString("AI Chat"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.mediumFont(12)
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int8 = 3
            self?.agentIndex = agentIndex
            self?.agentWillChanged?(agentIndex)
        }
        return btn
    }()
    
    open lazy var lineView: UIView = {
        let view = UIView(frame: CGRect(x: self.audioCallBtn.av_left, y: self.audioCallBtn.av_bottom + 4, width: self.audioCallBtn.av_width, height: 1))
        view.backgroundColor = AVTheme.colourful_text_strong
        return view
    }()
    
    open var agentIndex: Int8 = 0 {
        didSet {
            self.updateAgent()
        }
    }
    
    func updateAgent() {
        let agentIndex = self.agentIndex
        var rect = self.lineView.frame
        if agentIndex == 0 {
            self.audioCallBtn.isSelected = true
            self.audioCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.audioCallBtn.av_left, y: self.audioCallBtn.av_bottom + 4, width: self.audioCallBtn.av_width, height: 1)
        }
        else if agentIndex == 1 {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = true
            self.avatarCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.avatarCallBtn.av_left, y: self.avatarCallBtn.av_bottom + 4, width: self.avatarCallBtn.av_width, height: 1)
        }
        else if agentIndex == 2 {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = true
            self.visionCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.visionCallBtn.av_left, y: self.visionCallBtn.av_bottom + 4, width: self.visionCallBtn.av_width, height: 1)
        }
        else if agentIndex == 3 {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = true
            self.chatBtn.titleLabel?.font = AVTheme.mediumFont(12)
            rect = CGRect(x: self.chatBtn.av_left, y: self.chatBtn.av_bottom + 4, width: self.chatBtn.av_width, height: 1)
        }
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame = rect
        }
    }
    
    open var agentWillChanged: ((_ agentIndex: Int8) -> Void)? = nil
}


@objcMembers open class AUIAICallSysAgentContentView: UIScrollView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.voiceView)
        self.addSubview(self.avatarView)
        self.addSubview(self.visionView)
        self.addSubview(self.chatView)
        self.contentSize = CGSize(width: self.chatView.av_right, height: self.av_height)
        self.isPagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var voiceView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.av_width, height: self.av_height))
        view.contentMode = .scaleAspectFit
        view.image = AUIAIMainBundle.getCommonImage("bg_main_voice")
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open lazy var avatarView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: self.voiceView.av_right, y: 0, width: self.av_width, height: self.av_height))
        view.contentMode = .scaleAspectFit
        view.image = AUIAIMainBundle.getCommonImage("bg_main_avatar")
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open lazy var visionView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: self.avatarView.av_right, y: 0, width: self.av_width, height: self.av_height))
        view.contentMode = .scaleAspectFit
        view.image = AUIAIMainBundle.getCommonImage("bg_main_vision")
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open lazy var chatView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: self.visionView.av_right, y: 0, width: self.av_width, height: self.av_height))
        view.contentMode = .scaleAspectFit
        view.image = AUIAIMainBundle.getCommonImage("bg_main_chat")
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open var pageChanged: ((_ agentIndex: Int8) -> Void)? = nil
    
    open func scrollToAgent(_ agentIndex: Int8) {
        let pageWidth = self.frame.size.width
        let targetOffset = CGPoint(x: pageWidth * CGFloat(agentIndex), y: 0)
        self.setContentOffset(targetOffset, animated: true)
    }
}

extension AUIAICallSysAgentContentView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int8(scrollView.contentOffset.x / pageWidth)
        
        self.pageChanged?(currentPage)
    }
}


@objcMembers open class AUIAICallCusAgentContentView: UIView, UITextFieldDelegate {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.scanBtn)
        self.addSubview(self.inputField)
        self.addSubview(self.lineView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 0, y: 16, width: self.av_width, height: 24))
        title.text = AUIAIMainBundle.getString("Authorized AI Agent")
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(14)
        return title
    }()
    
    open lazy var scanBtn: AVBlockButton = {
        let scan = AVBlockButton(frame: CGRect(x: self.av_width - 24, y: self.titleLabel.av_bottom + 2, width: 24, height: 42))
        scan.setImage(AUIAIMainBundle.getImage("ic_scan"), for: .normal)
        return scan
    }()
    
    open lazy var inputField: UITextField = {
        let input = UITextField(frame: CGRect(x: 0, y: self.titleLabel.av_bottom + 2, width: self.av_width - 24 , height: 42))
        input.textColor = AVTheme.text_strong
        input.keyboardType = .default
        input.returnKeyType = .done
        input.delegate = self
        let placeholderText = AUIAIMainBundle.getString("Please Scan Code to Get Authorized Token")
        let placeholderColor = AVTheme.text_ultraweak
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: AVTheme.regularFont(14)
        ]
        input.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return input
    }()
    
    open lazy var lineView: UIView = {
        let line = UIView(frame: CGRect(x: 0, y: self.inputField.av_bottom, width: self.av_width, height: 1))
        line.backgroundColor = AVTheme.border_weak
        return line
    }()
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if self.inputField.isFirstResponder && view != self.inputField {
            self.inputField.resignFirstResponder()
        }
        return view
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
