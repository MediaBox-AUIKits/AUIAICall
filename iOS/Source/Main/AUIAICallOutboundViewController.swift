//
//  AUIAICallOutboundViewController.swift
//  Pods
//
//  Created by Bingo on 2025/6/20.
//

import UIKit
import AUIFoundation
import ARTCAICallKit


@objcMembers open class AUIAICallOutboundViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AUIAIMainBundle.color_bg
        
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.numberLabel)
        self.view.addSubview(self.inputFieldContainer)
        self.view.addSubview(self.numberTipsLabel)
        self.view.addSubview(self.interruptSwitch)
        self.view.addSubview(self.self.createLineView(underView: self.interruptSwitch))
        self.view.addSubview(self.voiceIdLabel)
        self.view.addSubview(self.selectVoiceIdBtn)
        self.view.addSubview(self.self.createLineView(underView: self.voiceIdLabel))
        self.view.addSubview(self.callTipsBtn)
        self.view.addSubview(self.aiGenTipsLabel)
        self.view.addSubview(self.startCallBtn)
        self.updateVoiceId()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBgTap)))
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
        btn.setTitle(AUIAIMainBundle.getString("AI Call Out"), for: .normal)
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
        label.text = AUIAIMainBundle.getString("Calling Number")
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
        
        self.inputField.frame = CGRect(x: 16, y: 0, width: view.av_width - 16 - 16, height: view.av_height)
        view.addSubview(self.inputField)
        
        
        return view
    }()
    
    open lazy var inputField: UITextField = {
        let input = UITextField(frame: CGRect.zero)
        input.textColor = AUIAIMainBundle.color_text
        input.keyboardType = .phonePad
        input.font = AVTheme.regularFont(14)
        input.tintColor = AUIAIMainBundle.color_primary
        let placeholderText = AUIAIMainBundle.getString("Input your phone number")
        let placeholderColor = AUIAIMainBundle.color_text_tertiary
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: AVTheme.regularFont(14)
        ]
        input.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        input.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return input
    }()
    
    open lazy var numberTipsLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = AUIAIMainBundle.getString("Only mainland China phone numbers are supported.")
        label.textColor = AUIAIMainBundle.color_text_tertiary
        label.font = AVTheme.regularFont(14)
        label.sizeToFit()
        label.av_left = 24
        label.av_top = self.inputFieldContainer.av_bottom + 8
        return label
    }()
    
    open lazy var interruptSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAIMainBundle.getString("Interrupt Agent Based on Sound and Environment")
        view.frame = CGRect(x: 24, y: self.numberTipsLabel.av_bottom + 12, width: self.view.av_width - 48, height: 76)
        view.switchBtn.isOn = true
        view.onSwitchValueChangedBlock = { [weak self] bar in
            self?.inputField.resignFirstResponder()
        }
        return view
    }()
    
    open lazy var voiceIdLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = AUIAIMainBundle.getString("Choose Voice Tone")
        label.textColor = AUIAIMainBundle.color_text
        label.font = AVTheme.regularFont(16)
        label.sizeToFit()
        label.av_left = 24
        label.av_height = 56
        label.av_top = self.interruptSwitch.av_bottom + 12
        return label
    }()
    
    
    open lazy var selectVoiceIdBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setTitle("", for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_right"), for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.clickBlock = { [weak self] btn in
            self?.inputField.resignFirstResponder()
            let top = UIViewController.av_top()
            let panel = AUIAIChatSettingPanel(frame: CGRect(x: 0, y: 0, width: top.view.av_width, height: 0))
            panel.setup(voiceIdList: self!.voiceIdList, selectItemId: self!.voiceItem?.voiceId ?? "")
            panel.titleView.text = AUIAIMainBundle.getString("Choose Voice Tone")
            panel.voiceIdSwitch.isHidden = true
            panel.issueReportView.isHidden = true
            panel.applyPlayBlock = { [weak panel] item in
                self?.voiceItem = item
                panel?.hide()
            }
            panel.show(on: top.view, with: .clickToClose)
        }
        return btn
    }()
    
    open lazy var callTipsBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: 24, y: self.voiceIdLabel.av_bottom + 12, width: self.view.av_width - 24 - 24, height: 56))
        btn.setTitle(AUIAIMainBundle.getString("The system will place an AI call to the recipient after you proceed. Please be ready to receive it."), for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_tertiary, for: .normal)
        btn.setImage(AUIAIMainBundle.getCommonImage("ic_tips"), for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.titleLabel?.numberOfLines = 0
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        btn.contentVerticalAlignment = .top
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    open func updateSelectVoiceBtnLayout() {
        let btn = self.selectVoiceIdBtn
        btn.sizeToFit()
        let imageSize: CGFloat = 18.0
        let spacing: CGFloat = 8.0
        let titleWidth = (btn.titleLabel?.intrinsicContentSize.width ?? 0)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleWidth + spacing, bottom: 0, right: 0)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize - spacing, bottom: 0, right: 0)
        btn.av_right = self.view.av_width - 24
        btn.av_height = 56
        btn.av_top = self.voiceIdLabel.av_top
    }
    
    open func createLineView(underView: UIView) -> UIView {
        let line = UIView(frame: CGRect(x: 24, y: underView.av_bottom, width: self.view.av_width - 24 - 24, height: 1))
        line.backgroundColor = AUIAIMainBundle.color_border_secondary
        return line
    }
    
    open lazy var startCallBtn: UIButton = {
        let btn = AVBlockButton(frame: CGRect(x: 25.0, y: self.aiGenTipsLabel.av_top - 12.0 - 44.0, width: self.view.av_width - 25.0 - 25.0, height: 44.0))
        btn.layer.cornerRadius = 2.0
        btn.layer.masksToBounds = true
        btn.setTitle(AUIAIMainBundle.getString("Start"), for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_Inverse, for: .normal)
        btn.setBackgroundColor(AUIAIMainBundle.color_fill_disabled, for: .disabled)
        btn.setTitleColor(AUIAIMainBundle.color_text_disabled, for: .disabled)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.isEnabled = false
        btn.clickBlock = { [weak self] sender in
            
            guard let self = self else {
                return
            }
            guard let phoneNumber = self.phoneNumber else { return }
            AUIAICallManager.defaultManager.startOutboundCall(phoneNumber: phoneNumber, voiceId: self.voiceItem?.voiceId ?? "", enableVoiceInterrupt: self.isVoiceInterrupted, viewController: self)
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
    
    @objc func onBgTap() {
        self.inputField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let enable = self.phoneNumber?.isEmpty == false
        self.startCallBtn.isEnabled = enable
    }
    
    open var phoneNumber: String? {
        get {
            return self.inputField.text
        }
    }
    
    open var isVoiceInterrupted: Bool {
        return self.interruptSwitch.switchBtn.isOn
    }
    
    public let voiceIdList = ["1185:云峰", "11:云穹", "1397:云薇", "1151:云玲"]
    open var voiceItem: AUIAICallVoiceItem? = nil {
        didSet {
            self.updateVoiceId()
        }
    }
    
    open func updateVoiceId() {
        var title = self.voiceItem?.voiceName
        if title?.isEmpty != false {
            title = AUIAIChatBundle.getString("Default")
        }
        self.selectVoiceIdBtn.setTitle(title, for: .normal)
        self.updateSelectVoiceBtnLayout()
    }
}
