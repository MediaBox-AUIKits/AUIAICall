//
//  AUIAICallAgentConfig.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/23.
//


import UIKit
import AUIFoundation
import ARTCAICallKit

let VoiceAgentId = ""
let AvatarAgentId = ""
let VisionAgentId = ""
let VideoAgentId = ""
let ChatAgentId = ""
let OutboundAgentId = ""
let InboundAgentId = ""

let VoiceAgentEmotionalId = ""
let AvatarAgentEmotionalId = ""
let VisionAgentEmotionalId = ""
let VideoAgentEmotionalId = ""

let Region = "cn-shanghai"

@objcMembers open class AUIAICallAgentConfig: NSObject {
    
    public static let shared: AUIAICallAgentConfig = AUIAICallAgentConfig()
    
    override init() {
        
        let emotional = UserDefaults.standard.object(forKey: "agent_config_emotional") as? Bool
        self.emotional = emotional ?? false
    }
    
    var emotional: Bool = false {
        didSet {
            UserDefaults.standard.set(self.emotional, forKey: "agent_config_emotional")
        }
    }
    
    let enableOutboundCall = false
    let enableInboundCall = false

    public func getAgentID(agentType: ARTCAICallAgentType, emotional: Bool = true) -> String? {
        var ret: String? = nil
        switch agentType {
        case .VoiceAgent:
            ret = emotional && self.emotional ? VoiceAgentEmotionalId : VoiceAgentId
        case .AvatarAgent:
            ret = emotional && self.emotional ? AvatarAgentEmotionalId : AvatarAgentId
        case .VisionAgent:
            ret = emotional && self.emotional ? VisionAgentEmotionalId : VisionAgentId
        case .VideoAgent:
            ret = emotional && self.emotional ? VideoAgentEmotionalId : VideoAgentId
        }
        
        // 为空值的情况下，使用在AppServer上配置的智能体Id
        if ret != nil && ret!.isEmpty == true {
            return nil
        }
        return ret
    }
    
    public func getChatAgentId() -> String {
        return ChatAgentId
    }
    
    public func getRegion() -> String {
        return Region
    }
}


@objcMembers open class AUIAICallAgentConfigPanel: AVBaseControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAICallBundle.color_bg_elevated
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.headerView.isHidden = true
        self.titleView.text = AUIAICallBundle.getString("Options")
        self.titleView.textAlignment = .left
        self.titleView.font = AVTheme.mediumFont(16)
        self.titleView.frame = CGRect(x: 24, y: 20, width: self.av_width - 54, height: 24)
        self.titleView.removeFromSuperview()
        self.addSubview(self.titleView)
        
        let exitBtn = AVBlockButton(frame: CGRect(x: self.av_width - 44 - 10, y: 10, width: 44, height: 44))
        exitBtn.setImage(AUIAICallBundle.getTemplateImage("ic_exit"), for: .normal)
        exitBtn.tintColor = AUIAICallBundle.color_icon
        exitBtn.clickBlock = {[weak self] sender in
            self?.hide()
        }
        self.addSubview(exitBtn)
        
        
        self.contentView.addSubview(self.voiceprintSettingView)
        self.contentView.addSubview(self.emotionLabel)
        self.contentView.addSubview(self.emotionInfoLabel)
        self.contentView.addSubview(self.unemotionalBtn)
        self.contentView.addSubview(self.emotionalBtn)
        
        self.updateVoiceprintState()
        self.emotionalBtn.isSelected = AUIAICallAgentConfig.shared.emotional
        self.unemotionalBtn.isSelected = !self.emotionalBtn.isSelected
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class func panelHeight() -> CGFloat {
        let vp = 76.0 + 56.0
        return 208 + 46 + vp
    }
    
    open override class func present(_ cp: AVBaseControllPanel, on onView: UIView, backgroundType bgType: AVControllPanelBackgroundType) {
        super.present(cp, on: onView, backgroundType: bgType)
        cp.bgViewOnShowing?.backgroundColor = AUIAICallBundle.color_bg_mask
    }
    
    private func updateLayout() {
        
        var top: CGFloat = 16
        
        let vp = 76.0 + (self.voiceprintSettingView.voiceprintIsApply ? 56.0 : 0.0)
        self.voiceprintSettingView.frame = CGRect(x: 0, y: top, width: self.contentView.av_width, height: vp)
        top = self.voiceprintSettingView.av_bottom + 28
        
        self.emotionLabel.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 24)
        
        top = self.emotionLabel.av_bottom + 8
        self.emotionInfoLabel.frame = CGRect(x: self.emotionLabel.av_left, y: top, width: self.emotionLabel.av_width, height: 20)
        
        top = self.emotionInfoLabel.av_bottom + 20
        let btnWidth = (self.av_width - 48 - 12) / 2.0
        self.unemotionalBtn.frame = CGRect(x: 24, y: top, width: btnWidth, height: 48)
        self.emotionalBtn.frame = CGRect(x: self.unemotionalBtn.av_right + 12, y: top, width: btnWidth, height: 48)
    }
    
    private func updateVoiceprintState() {
        self.voiceprintSettingView.voiceprintSwitch.switchBtn.isOn = AUIAICallVoiceprintManager.shared.isEnable
        self.voiceprintSettingView.voiceprintIsApply = AUIAICallVoiceprintManager.shared.isEnable
        if AUIAICallVoiceprintManager.shared.isRegistedVoiceprint() {
            self.voiceprintSettingView.updateTextAfterRegstered()
        }
        self.setNeedsLayout()
    }
    
    open lazy var voiceprintSettingView: AUIAICallVoiceprintSettingView = {
        let view = AUIAICallVoiceprintSettingView()
        view.voiceprintSwitch.switchBtn.isOn = AUIAICallVoiceprintManager.shared.isEnable
        view.voiceprintSwitch.onSwitchValueChangedBlock = { [weak self] bar in
            AUIAICallVoiceprintManager.shared.enableVoiceprint(bar.switchBtn.isOn)
            view.voiceprintSwitch.switchBtn.isOn = AUIAICallVoiceprintManager.shared.isEnable
            self?.updateVoiceprintState()
        }
        return view
    }()
    
    lazy var emotionLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(16)
        label.textColor = AUIAICallBundle.color_text
        label.text = AUIAICallBundle.getString("Emotion Support")
        return label
    }()
    
    lazy var emotionInfoLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AUIAICallBundle.color_text_tertiary
        label.text = AUIAICallBundle.getString("Does agent support emotional label output?")
        return label
    }()
    
    lazy var unemotionalBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.backgroundColor = AUIAICallBundle.color_fill_secondary
        btn.setTitle(AUIAICallBundle.getString("Unemotional"), for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text_secondary, for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text_selection, for: .selected)
        btn.setBorderColor(AUIAICallBundle.color_border_secondary, for: .normal)
        btn.setBorderColor(AUIAICallBundle.color_border_selection, for: .selected)
        btn.layer.cornerRadius = 2
        btn.layer.borderWidth = 0.5
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else { return }
            self.unemotionalBtn.isSelected = !self.unemotionalBtn.isSelected
            self.emotionalBtn.isSelected = !self.unemotionalBtn.isSelected
            AUIAICallAgentConfig.shared.emotional = self.emotionalBtn.isSelected
        }
        return btn
    }()
    
    lazy var emotionalBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.backgroundColor = AUIAICallBundle.color_fill_secondary
        btn.setTitle(AUIAICallBundle.getString("Emotional"), for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text_secondary, for: .normal)
        btn.setTitleColor(AUIAICallBundle.color_text_selection, for: .selected)
        btn.setBorderColor(AUIAICallBundle.color_border_secondary, for: .normal)
        btn.setBorderColor(AUIAICallBundle.color_border_selection, for: .selected)
        btn.layer.cornerRadius = 2
        btn.layer.borderWidth = 0.5
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else { return }
            self.emotionalBtn.isSelected = !self.emotionalBtn.isSelected
            self.unemotionalBtn.isSelected = !self.emotionalBtn.isSelected
            AUIAICallAgentConfig.shared.emotional = self.emotionalBtn.isSelected
        }
        return btn
    }()
}



@objcMembers open class AUIAICallVoiceprintSettingView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.addSubview(voiceprintSwitch)
        self.addSubview(self.stateView)
        self.stateView.addSubview(self.titleLabel)
        self.stateView.addSubview(self.registerBar)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.voiceprintSwitch.frame = CGRect(x: 24, y: 0, width: self.av_width - 48, height: 76)
        self.stateView.frame = CGRect(x: 24, y: self.voiceprintSwitch.av_bottom + 8, width: self.av_width - 48, height: 48)

        self.registerBar.sizeToFit()
        self.registerBar.frame = CGRect(x: self.stateView.av_width - 16 - self.registerBar.av_width, y: 0, width: self.registerBar.av_width, height: self.stateView.av_height)
        self.titleLabel.frame = CGRect(x: 16, y: 0, width: self.registerBar.av_left - 16 - 16, height: self.stateView.av_height)
    }
    
    open var voiceprintIsApply: Bool = false {
        didSet {
            self.stateView.isHidden = !self.voiceprintIsApply
        }
    }
    
    open lazy var voiceprintSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAICallBundle.getString("Voiceprint")
        view.infoLabel.text = AUIAICallBundle.getString("The AI only uses your voice as input.")
        return view
    }()
    
    open lazy var stateView: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAICallBundle.color_fill_secondary
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.av_setLayerBorderColor(AUIAICallBundle.color_border_secondary)
        return view
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AUIAICallBundle.color_text
        label.numberOfLines = 0
        label.text = AUIAICallBundle.getString("Voiceprint Feature Information") + "(\(AUIAICallBundle.getString("Unavailable in calls unless registered")))"
        return label
    }()
    
    open lazy var registerBar: AUIAICallRightClickBar = {
        let bar = AUIAICallRightClickBar()
        bar.titleLabel.font = AVTheme.regularFont(14)
        bar.titleLabel.text = AUIAICallBundle.getString("Register")
        return bar
    }()
    
    open func updateTextAfterRegstered() {
        self.titleLabel.text = AUIAICallBundle.getString("Voiceprint Feature Information") + "(\(AUIAICallBundle.getString("Registered")))"
        self.registerBar.titleLabel.text = AUIAICallBundle.getString("Re-register")
        self.setNeedsLayout()
    }
}
