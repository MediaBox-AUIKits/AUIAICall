//
//  AUIAICallMainViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallMainViewController: AVBaseViewController {
    
    deinit {
        debugPrint("deinit:\(self)")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = AVTheme.bg_medium
        self.titleView.text = AUIAICallBundle.getString("Voice Agent")
#if DEMO_FOR_DEBUG
        self.hiddenMenuButton = false
        self.menuButton.addTarget(self, action: #selector(onMenuBtnClick), for: .touchUpInside)
        
        let value = UserDefaults.standard.object(forKey: "aui_current_integration") as? Int32
        AUIAICallManager.defaultManager.currentIntegrationWay = AUIAICallManager.IntegrationWay(rawValue: value ?? 0) ?? .Standard
        
        let domain = UserDefaults.standard.object(forKey: "aui_current_domain") as? String
        AUIAICallAppServer.serverDomain = domain == AICallServerDomainPre ? AICallServerDomainPre : AICallServerDomain
#else
        self.hiddenMenuButton = true
#endif
        
        self.contentView.addSubview(self.agentTypeBgView)
        self.agentTypeBgView.addSubview(self.agentSeletctBgView)
        self.agentTypeBgView.addSubview(self.sysAgentBtn)
        self.agentTypeBgView.addSubview(self.cusAgentBtn)

        self.contentView.addSubview(self.audioCallBtn)
        self.contentView.addSubview(self.videoCallBtn)
        
        self.contentView.addSubview(self.startCallBtn)
        
        self.contentView.addSubview(self.sysAgentContentView)
        self.contentView.addSubview(self.cusAgentContentView)

        
        self.selectAgent(isCus: false, isAni: false)
        self.selectCall(isVideo: false)
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
        btn.setTitle(AUIAICallBundle.getString("Official Agent"), for: .normal)
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
        btn.setTitle(AUIAICallBundle.getString("Custom Agent"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.clickBlock = { [weak self] sender in
            self?.selectAgent(isCus: true, isAni: true)
        }
        return btn
    }()
    
    open lazy var audioCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: 20.0, y: self.agentTypeBgView.av_bottom + 16.0, width: (self.contentView.av_width - 40 - 9) / 2.0, height: 40.0))
        btn.setTitle(AUIAICallBundle.getString("AI Voice Call"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.setBackgroundColor(AVTheme.bg_weak, for: .selected)
        btn.setBackgroundColor(UIColor.clear, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = btn.av_height / 2.0
        btn.setBorderColor(AVTheme.border_weak, for: .normal)
        btn.clickBlock = { [weak self] sender in
            self?.selectCall(isVideo: false)
        }
        return btn
    }()
    
    open lazy var videoCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.audioCallBtn.av_right + 9.0, y: self.audioCallBtn.av_top, width: self.audioCallBtn.av_width, height: self.audioCallBtn.av_height))
        btn.setTitle(AUIAICallBundle.getString("AI Avatar Call"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.setBackgroundColor(AVTheme.bg_weak, for: .selected)
        btn.setBackgroundColor(UIColor.clear, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = btn.av_height / 2.0
        btn.setBorderColor(AVTheme.border_weak, for: .normal)
        btn.clickBlock = { [weak self] sender in
            self?.selectCall(isVideo: true)
        }
        return btn
    }()
    
    open lazy var startCallBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 36.0, y: self.contentView.av_height - 36.0 - UIView.av_safeBottom - 44.0, width: self.contentView.av_width - 36.0 - 36.0, height: 44.0))
        btn.layer.cornerRadius = 22.0
        btn.layer.masksToBounds = true
        btn.setTitle(AUIAICallBundle.getString("Start"), for: .normal)
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
                    AVAlertController.show(AUIAICallBundle.getString("Please Scan Code to Get Authorized Token"), vc: self)
                    return
                }
                self.startCall(authToken: authToken)
            }
            else {
                self.startCall(agentType: self.audioCallBtn.isSelected == true ? .VoiceAgent : .AvatarAgent, agentId: nil)
            }
        }
        return btn
    }()
    
    open lazy var sysAgentContentView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 20, y: self.audioCallBtn.av_bottom + 32, width: self.contentView.av_width - 40, height: self.startCallBtn.av_top - self.audioCallBtn.av_bottom - 32 - 32))
        view.contentMode = .scaleAspectFit
        view.image = AUIAICallBundle.getCommonImage("bg_main_voice")
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open lazy var cusAgentContentView: AUIAICallCusAgentContentView = {
        let view = AUIAICallCusAgentContentView(frame: CGRect(x: 20, y: self.cusAgentBtn.av_bottom + 16, width: self.contentView.av_width - 40, height: self.startCallBtn.av_top - self.cusAgentBtn.av_bottom - 16 - 38))
        view.inputField.isEnabled = false
        view.scanBtn.clickBlock = { [weak self] btn in
            let qr = AVQRCodeScanner()
            qr.scanResultBlock = { scaner, content in
                scaner.navigationController?.popViewController(animated: true)
                if let result = self?.checkAuthToken(authToken: content) {
                    self?.cusAgentContentView.inputField.text = content
                }
            }
            self?.navigationController?.pushViewController(qr, animated: true)
        }
        return view
    }()

#if DEMO_FOR_DEBUG
    @objc open func onMenuBtnClick() {
        let alert = UIAlertController(title: AUIAICallBundle.getString("环境配置"), message: nil, preferredStyle: .actionSheet)
        AVTheme.updateRootViewControllerInterfaceStyle(alert)
        let action1 = UIAlertAction(title: AUIAICallBundle.getString("Custom"), style: AUIAICallManager.defaultManager.currentIntegrationWay == .Custom ? .destructive : .default) { action in
            AUIAICallManager.defaultManager.currentIntegrationWay = .Custom
            UserDefaults.standard.set(AUIAICallManager.defaultManager.currentIntegrationWay.rawValue, forKey: "aui_current_integration")
        }
        alert.addAction(action1)
        let action2 = UIAlertAction(title: AUIAICallBundle.getString("Standard"), style: AUIAICallManager.defaultManager.currentIntegrationWay == .Standard ? .destructive : .default) { action in
            AUIAICallManager.defaultManager.currentIntegrationWay = .Standard
            UserDefaults.standard.set(AUIAICallManager.defaultManager.currentIntegrationWay.rawValue, forKey: "aui_current_integration")
        }
        alert.addAction(action2)
        
        let product = UIAlertAction(title: AUIAICallBundle.getString("线上域名"), style: AUIAICallAppServer.serverDomain == AICallServerDomain ? .destructive : .default) { action in
            AUIAICallAppServer.serverDomain = AICallServerDomain
            UserDefaults.standard.set(AICallServerDomain, forKey: "aui_current_domain")
        }
        alert.addAction(product)
        let pre = UIAlertAction(title: AUIAICallBundle.getString("预发域名"), style: AUIAICallAppServer.serverDomain == AICallServerDomainPre ? .destructive : .default) { action in
            AUIAICallAppServer.serverDomain = AICallServerDomainPre
            UserDefaults.standard.set(AICallServerDomainPre, forKey: "aui_current_domain")
        }
        alert.addAction(pre)
        
        let actionLogout = UIAlertAction(title: AUIAICallBundle.getString("Force to Log Out"), style: .default) { action in
            AUIAICallManager.defaultManager.onUserTokenExpiredBlcok?()
        }
        alert.addAction(actionLogout)
        
        let cancel = UIAlertAction(title: AUIAICallBundle.getString("Cancel"), style: .cancel)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
#endif
    
    open func selectAgent(isCus: Bool, isAni: Bool) {
        if isCus {
            self.cusAgentBtn.isSelected = true
            self.cusAgentBtn.titleLabel?.font = AVTheme.mediumFont(14)
            self.sysAgentBtn.isSelected = false
            self.sysAgentBtn.titleLabel?.font = AVTheme.regularFont(14)
            self.audioCallBtn.isHidden = true
            self.videoCallBtn.isHidden = true
            self.cusAgentContentView.isHidden = false
            self.sysAgentContentView.isHidden = true
        }
        else {
            self.sysAgentBtn.isSelected = true
            self.sysAgentBtn.titleLabel?.font = AVTheme.mediumFont(14)
            self.cusAgentBtn.isSelected = false
            self.cusAgentBtn.titleLabel?.font = AVTheme.regularFont(14)
            self.audioCallBtn.isHidden = false
            self.videoCallBtn.isHidden = false
            self.sysAgentContentView.isHidden = false
            self.cusAgentContentView.isHidden = true
        }
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
    
    open func selectCall(isVideo: Bool) {
        if isVideo {
            self.videoCallBtn.isSelected = true
            self.videoCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.sysAgentContentView.image = AUIAICallBundle.getCommonImage("bg_main_avatar")
        }
        else {
            self.audioCallBtn.isSelected = true
            self.audioCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.videoCallBtn.isSelected = false
            self.videoCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.sysAgentContentView.image = AUIAICallBundle.getCommonImage("bg_main_voice")
        }
    }
    
    open func startCall(authToken: String) {
        if let result = self.checkAuthToken(authToken: authToken) {
            self.startCall(agentType: result.agentType, agentId: result.agentId)
        }
    }
    
    open func startCall(agentType: ARTCAICallAgentType, agentId: String?) {
        if agentType == .AvatarAgent {
            let seconds: UInt32 = 5 * 60
            AUIAICallManager.defaultManager.startCall(agentType: agentType, agentId: agentId, limitSecond: seconds, viewController: self)
            return
        }
        
        AUIAICallManager.defaultManager.startCall(agentType: agentType, agentId: agentId, viewController: self)
    }
    
    func checkAuthToken(authToken: String) -> (agentId: String, agentType: ARTCAICallAgentType)? {
        let json = self.decodeAndDeserialize(base64String: authToken)
        guard let json = json else {
            AVAlertController.show(AUIAICallBundle.getString("Invalid Token"), vc: self)
            return nil
        }
        
        let expireTime = json["ExpireTime"] as? String
        guard let expireTime = expireTime else {
            AVAlertController.show(AUIAICallBundle.getString("Invalid Token"), vc: self)
            return nil
        }
        if self.isDateStringExpired(dateString: expireTime) {
            AVAlertController.show(AUIAICallBundle.getString("Token Expire"), vc: self)
            return nil
        }
        
        let agentId = json["TemporaryAIAgentId"] as? String
        guard let agentId = agentId else {
            AVAlertController.show(AUIAICallBundle.getString("Invalid Token"), vc: self)
            return nil
        }
        
        let workflowType = json["WorkflowType"] as? String
        var agentType: ARTCAICallAgentType? = nil
        if workflowType == "AvatarChat3D" {
            agentType = .AvatarAgent
        }
        else if workflowType == "VoiceChat" {
            agentType = .VoiceAgent
        }
        guard let agentType = agentType else {
            AVAlertController.show(AUIAICallBundle.getString("Invalid Token"), vc: self)
            return nil
        }
        
        return (agentId, agentType)
    }
    
    func decodeAndDeserialize(base64String: String) -> [String: Any]? {
        // Base64 Decode
        guard let decodedData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            debugPrint("Failed to decode Base64 string.")
            return nil
        }
        
        // JSON Deserialize
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: decodedData, options: [])
            if let jsonDictionary = jsonObject as? [String: Any] {
                return jsonDictionary
            }
        } catch {
            debugPrint("Failed to deserialize JSON: \(error.localizedDescription)")
        }
        
        return nil
    }

    func isDateStringExpired(dateString: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let date = dateFormatter.date(from: dateString) else {
            debugPrint("Failed to formatted Data String")
            return false
        }
        
        let currentDate = Date()
        return currentDate > date
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
        title.text = AUIAICallBundle.getString("Authorized AI Agent")
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(14)
        return title
    }()
    
    open lazy var scanBtn: AVBlockButton = {
        let scan = AVBlockButton(frame: CGRect(x: self.av_width - 24, y: self.titleLabel.av_bottom + 2, width: 24, height: 42))
        scan.setImage(AUIAICallBundle.getImage("ic_scan"), for: .normal)
        return scan
    }()
    
    open lazy var inputField: UITextField = {
        let input = UITextField(frame: CGRect(x: 0, y: self.titleLabel.av_bottom + 2, width: self.av_width - 24 , height: 42))
        input.textColor = AVTheme.text_strong
        input.keyboardType = .default
        input.returnKeyType = .done
        input.delegate = self
        let placeholderText = AUIAICallBundle.getString("Please Scan Code to Get Authorized Token")
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
