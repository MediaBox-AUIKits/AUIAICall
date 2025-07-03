//
//  AUIAICallOutboundCallContentView.swift
//  Pods
//
//  Created by Bingo on 2025/6/20.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallOutboundCallContentView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.numberLabel)
        self.addSubview(self.splitView)
        self.addSubview(self.inputField)
        self.addSubview(self.self.createLineView(underView: self.numberLabel))
        self.addSubview(self.numberTipsLabel)
        self.addSubview(self.interruptSwitch)
        self.addSubview(self.self.createLineView(underView: self.interruptSwitch))
        self.addSubview(self.voiceIdLabel)
        self.addSubview(self.selectVoiceIdBtn)
        self.addSubview(self.self.createLineView(underView: self.voiceIdLabel))
        self.addSubview(self.callTipsBtn)
        
        self.updateVoiceId()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var numberLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = AUIAIMainBundle.getString("Calling Number")
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(16)
        title.sizeToFit()
        title.av_height = 56
        title.av_top = -12
        return title
    }()
    
    open lazy var splitView: UIView = {
        let line = UIView(frame: CGRect(x: self.numberLabel.av_right + 12, y: 0, width: 1, height: 20))
        line.backgroundColor = AVTheme.border_weak
        line.av_centerY = self.numberLabel.av_centerY
        return line
    }()
    
    open lazy var inputField: UITextField = {
        let input = UITextField(frame: CGRect(x: self.splitView.av_right + 12, y: 0, width: self.av_width - self.splitView.av_right - 12 , height: 24))
        input.textAlignment = .right
        input.textColor = AVTheme.text_strong
        input.keyboardType = .phonePad
        input.font = AVTheme.regularFont(16)
        let placeholderText = AUIAIMainBundle.getString("Input your phone number")
        let placeholderColor = AVTheme.text_ultraweak
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: AVTheme.regularFont(16)
        ]
        input.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        input.av_centerY = self.numberLabel.av_centerY
        
        input.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return input
    }()
    
    open lazy var numberTipsLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = AUIAIMainBundle.getString("Only mainland China phone numbers are supported.")
        title.textColor = AVTheme.text_weak
        title.font = AVTheme.regularFont(14)
        title.sizeToFit()
        title.av_top = self.numberLabel.av_bottom + 4
        return title
    }()
    
    open lazy var interruptSwitch: AVSwitchBar = {
        let view = AVSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAIMainBundle.getString("Interrupt Agent Based on Sound and Environment")
        view.lineView.isHidden = true
        view.frame = CGRect(x: -20, y: self.numberTipsLabel.av_bottom + 12, width: self.av_width + 40, height: 56)
        view.titleLabel.font = AVTheme.regularFont(16)
        view.switchBtn.isOn = true
        return view
    }()
    
    open lazy var voiceIdLabel: UILabel = {
        let title = UILabel(frame: CGRect.zero)
        title.text = AUIAIMainBundle.getString("Choose Voice Tone")
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(16)
        title.sizeToFit()
        title.av_height = 56
        title.av_top = self.interruptSwitch.av_bottom + 12
        return title
    }()
    
    
    open lazy var selectVoiceIdBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setTitle("xxxxx", for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setImage(AUIAIMainBundle.getImage("ic_right"), for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(16)
        btn.clickBlock = { [weak self] btn in
            let top = UIViewController.av_top()
            let panel = AUIAIChatSettingPanel(frame: CGRect(x: 0, y: 0, width: top.view.av_width, height: 0))
            panel.setup(voiceIdList: self!.voiceIdList, selectItemId: self!.voiceId)
            panel.titleView.text = AUIAIMainBundle.getString("Choose Voice Tone")
            panel.voiceIdSwitch.isHidden = true
            panel.applyPlayBlock = { [weak panel] item in
                self?.voiceId = item.voiceId
                panel?.hide()
            }
            panel.show(on: top.view, with: .clickToClose)
        }
        return btn
    }()
    
    open lazy var callTipsBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: 0, y: self.voiceIdLabel.av_bottom + 12, width: self.av_width, height: 56))
        btn.setTitle(AUIAIMainBundle.getString("The system will place an AI call to the recipient after you proceed. Please be ready to receive it."), for: .normal)
        btn.setTitleColor(AVTheme.text_ultraweak, for: .normal)
        btn.setImage(AUIAIMainBundle.getImage("ic_tips"), for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(13)
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
        btn.av_right = self.av_width
        btn.av_height = 56
        btn.av_top = self.voiceIdLabel.av_top
    }
    
    open func createLineView(underView: UIView) -> UIView {
        let line = UIView(frame: CGRect(x: 0, y: underView.av_bottom, width: self.av_width, height: 1))
        line.backgroundColor = AVTheme.border_weak
        return line
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if self.inputField.isFirstResponder && view != self.inputField {
            self.inputField.resignFirstResponder()
        }
        return view
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.onInputPhoneNumberChanged?()
    }
    
    open var onInputPhoneNumberChanged: (() -> Void)? = nil
    
    open var phoneNumber: String? {
        get {
            return self.inputField.text
        }
    }
    
    open var isVoiceInterrupted: Bool {
        return self.interruptSwitch.switchBtn.isOn
    }
    
    public let voiceIdList = ["longcheng_v2", "longhua_v2", "longshu_v2", "loongbella_v2", "longwan_v2", "longxiaochun_v2", "longxiaoxia_v2", "loongstella"]
    open var voiceId: String = "" {
        didSet {
            self.updateVoiceId()
        }
    }
    
    open func updateVoiceId() {
        var title = self.voiceId
        if title.isEmpty == true {
            title = AUIAIChatBundle.getString("Default")
        }
        self.selectVoiceIdBtn.setTitle(title, for: .normal)
        self.updateSelectVoiceBtnLayout()
    }
}
