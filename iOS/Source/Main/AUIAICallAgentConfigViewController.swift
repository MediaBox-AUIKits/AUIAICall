//
//  AUIAICallAgentConfigViewController.swift
//  Pods
//
//  Created by Bingo on 2026/1/16.
//

import UIKit
import AUIFoundation
import ARTCAICallKit


@objcMembers open class AUIAICallAgentConfigViewController: UIViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AUIAIMainBundle.color_bg
        
        self.view.addSubview(self.backBtn)
        self.view.addSubview(self.contentView)
        
        self.contentView.addSubview(self.voiceprintSettingView)
        self.contentView.addSubview(self.createLineView())
        
        self.contentView.addSubview(self.semanticSwitch)
        self.contentView.addSubview(self.semanticLevelBar)
        self.contentView.addSubview(self.createLineView())
        
        self.contentView.addSubview(self.interruptSwitch)
        self.contentView.addSubview(self.backChannelingSwitch)
        self.contentView.addSubview(self.createLineView())
        
        self.contentView.addSubview(self.autoSpeechUserIdleSwitch)
        self.contentView.addSubview(self.autoSpeechUserIdleWaitTimeBar)
        self.contentView.addSubview(self.autoSpeechUserIdleMaxRepeatsBar)
        self.contentView.addSubview(self.createLineView())
        
        self.contentView.addSubview(self.ambientVolumeBar)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.backBtn.sizeToFit()
        self.backBtn.frame = CGRect(x: 24, y: UIView.av_safeTop, width: self.backBtn.av_width + 12, height: 48)
        
        self.contentView.frame = CGRect(x: 0, y: self.backBtn.av_bottom, width: self.view.av_width, height: self.view.av_height - self.backBtn.av_bottom - 24)
        
        
        var top: CGFloat = 12
        let vp = self.voiceprintSettingView.getCurrentHight()
        self.voiceprintSettingView.frame = CGRect(x: 0, y: top, width: self.contentView.av_width, height: vp)
        top = self.voiceprintSettingView.av_bottom + 12
        
        
        /** Line 1  */
        self.lineViews[0].av_top = top + 12
        self.lineViews[0].av_width = self.contentView.av_width - 48
        top = self.lineViews[0].av_bottom + 12
        
        self.semanticSwitch.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        top = self.semanticSwitch.av_bottom + 12
        self.semanticLevelBar.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        if self.semanticLevelBar.isHidden == false {
            top = self.semanticLevelBar.av_bottom + 12
        }
        
        /** Line 2  */
        self.lineViews[1].av_top = top
        self.lineViews[1].av_width = self.contentView.av_width - 48
        top = self.lineViews[1].av_bottom + 12
        
        self.interruptSwitch.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        top = self.interruptSwitch.av_bottom + 12
        self.backChannelingSwitch.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        top = self.backChannelingSwitch.av_bottom + 12
        
        
        /** Line 3  */
        self.lineViews[2].av_top = top
        self.lineViews[2].av_width = self.contentView.av_width - 48
        top = self.lineViews[2].av_bottom + 12
        
        self.autoSpeechUserIdleSwitch.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        top = self.autoSpeechUserIdleSwitch.av_bottom + 12
        self.autoSpeechUserIdleWaitTimeBar.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        if self.autoSpeechUserIdleWaitTimeBar.isHidden == false {
            top = self.autoSpeechUserIdleWaitTimeBar.av_bottom + 12
        }
        self.autoSpeechUserIdleMaxRepeatsBar.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        if self.autoSpeechUserIdleMaxRepeatsBar.isHidden == false {
            top = self.autoSpeechUserIdleMaxRepeatsBar.av_bottom + 12
        }
        
        /** Line 4  */
        self.lineViews[3].av_top = top
        self.lineViews[3].av_width = self.contentView.av_width - 48
        top = self.lineViews[3].av_bottom + 12
        
        
        self.ambientVolumeBar.frame = CGRect(x: 24, y: top, width: self.contentView.av_width - 48, height: 76)
        top = self.ambientVolumeBar.av_bottom + 12
        
        self.contentView.contentSize = CGSize(width: self.contentView.av_width, height: top)
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
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.voiceprintSettingView.updateLayout()
    }
    
    open lazy var backBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect.zero)
        btn.setImage(AUIAIMainBundle.getTemplateImage("ic_back"), for: .normal)
        btn.tintColor = AUIAIMainBundle.color_icon
        btn.setTitle(AUIAIMainBundle.getString("Options"), for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        btn.titleLabel?.font = AVTheme.mediumFont(16)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        btn.clickBlock = { [weak self] sender in
            self?.navigationController?.popViewController(animated: true)
        }
        return btn
    }()
    
    open lazy var contentView: UIScrollView = {
        let view = UIScrollView(frame: CGRect(x: 0, y: self.backBtn.av_bottom + 24, width: self.view.av_width, height: self.view.av_height - self.backBtn.av_bottom - 24))
        return view
    }()
    
    open var lineViews: [UIView] = []
    open func createLineView() -> UIView {
        let line = UIView(frame: CGRect(x: 24, y: 0, width: 0, height: 1))
        line.backgroundColor = AUIAIMainBundle.color_border_secondary
        self.lineViews.append(line)
        return line
    }
    
    open lazy var voiceprintSettingView: AUIAICallVoiceprintSettingView = {
        let view = AUIAICallVoiceprintSettingView()
        view.onLayoutChangedBlock = { [weak self] in
            self?.view.setNeedsLayout()
        }
        view.registerBar.tappedAction = { [weak self] bar in
            self?.navigationController?.pushViewController(AUIAICallVoiceprintViewController(), animated: true)
        }
        return view
    }()
    
    
    open lazy var semanticSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Semantic Mode")
        view.infoLabel.text = AUIAIMainBundle.getString("Using AI to determine whether a speech has ended based on contextual semantics")
        view.switchBtn.isOn = AUIAICallAgentManager.shared.enableSemanticMode
        view.onSwitchValueChangedBlock = { [weak self] bar in
            AUIAICallAgentManager.shared.enableSemanticMode = bar.switchBtn.isOn
            self?.semanticLevelBar.isHidden = !bar.switchBtn.isOn
            self?.view.setNeedsLayout()
        }
        return view
    }()
    
    private let semanticLevel = ["Low", "Medium", "High"]
    private var semanticLevelIndex = 2
    open lazy var semanticLevelBar: AUIAICallRightClickBar = {
        self.semanticLevelIndex = self.semanticLevel.firstIndex(of: AUIAICallAgentManager.shared.semanticEagerness) ?? 2
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Eagerness")
        view.infoLabel.text = AUIAIMainBundle.getString("Controls how fast AI responds after detecting pause")
        view.infoLabel.isHidden = false
        view.rightLabel.text = self.semanticLevel[self.semanticLevelIndex]
        view.rightLabel.isHidden = false
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            let panel = AUIAICallListPicker(width: self.view.av_width, title: AUIAIMainBundle.getString("Eagerness"), list: self.semanticLevel, selected: self.semanticLevelIndex)
            panel.onPickerSelected = { index, text in
                AUIAICallAgentManager.shared.semanticEagerness = text
                self.semanticLevelIndex = index
                view.rightLabel.text = text
                view.setNeedsLayout()
            }
            panel.show(on: self.view, with: .clickToClose)
        }
        view.isHidden = !AUIAICallAgentManager.shared.enableSemanticMode
        return view
    }()
    
    open lazy var interruptSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Smart Interrupt")
        view.infoLabel.text = AUIAIMainBundle.getString("Interrupt Agent Based on Sound and Environment")
        view.switchBtn.isOn = AUIAICallAgentManager.shared.enableVoiceInterrupt
        view.onSwitchValueChangedBlock = { [weak self] bar in
            AUIAICallAgentManager.shared.enableVoiceInterrupt = bar.switchBtn.isOn
        }
        return view
    }()
    
    open lazy var backChannelingSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Back-channel Words")
        view.infoLabel.text = AUIAIMainBundle.getString("Light responses when agent naturally responds during pauses")
        view.switchBtn.isOn = AUIAICallAgentManager.shared.enableBackChanneling
        view.onSwitchValueChangedBlock = { [weak self] bar in
            AUIAICallAgentManager.shared.enableBackChanneling = bar.switchBtn.isOn
        }
        return view
    }()
    
    open lazy var autoSpeechUserIdleSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Auto Speech")
        view.infoLabel.text = AUIAIMainBundle.getString("When you remain silent for a long time, the agent initiates conversation")
        view.switchBtn.isOn = AUIAICallAgentManager.shared.enableAutoSpeechUserIdle
        view.onSwitchValueChangedBlock = { [weak self] bar in
            AUIAICallAgentManager.shared.enableAutoSpeechUserIdle = bar.switchBtn.isOn
            self?.autoSpeechUserIdleWaitTimeBar.isHidden = !bar.switchBtn.isOn
            self?.autoSpeechUserIdleMaxRepeatsBar.isHidden = !bar.switchBtn.isOn
            self?.view.setNeedsLayout()
        }
        return view
    }()
    
    open lazy var autoSpeechUserIdleWaitTimeBar: AUIAICallRightClickBar = {
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Waiting Time")
        view.infoLabel.text = AUIAIMainBundle.getString("After long waiting time, the agent will initiate inquiry")
        view.infoLabel.isHidden = false
        view.rightLabel.text = "\(AUIAICallAgentManager.shared.autoSpeechUserIdleWaitTime)ms"
        view.rightLabel.isHidden = false
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            AVAlertController.showInput(AUIAIMainBundle.getString("Waiting Time (Range: 5000–600000ms)"), vc: self) { input in
                if input.count > 0 {
                    if let value = Int32(input) {
                        if value < 5000 || value > 600000 {
                            AVAlertController.show(AUIAIMainBundle.getString("Invalid input, please enter value within 5000–600000ms range"), vc: self)
                            return
                        }
                        AUIAICallAgentManager.shared.autoSpeechUserIdleWaitTime = value
                        view.rightLabel.text = "\(value)ms"
                        view.setNeedsLayout()
                    }
                }
            }
        }
        view.isHidden = !AUIAICallAgentManager.shared.enableAutoSpeechUserIdle
        return view
    }()
    
    open lazy var autoSpeechUserIdleMaxRepeatsBar: AUIAICallRightClickBar = {
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Auto Speech Count")
        view.infoLabel.text = AUIAIMainBundle.getString("Maximum number of proactive inquiries by agent")
        view.infoLabel.isHidden = false
        view.rightLabel.text = "\(AUIAICallAgentManager.shared.autoSpeechUserIdleMaxRepeats) \(AUIAIMainBundle.getString("Times"))"
        view.rightLabel.isHidden = false
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            AVAlertController.showInput(AUIAIMainBundle.getString("Inquiry Count (Range: 1–10 times)"), vc: self) { input in
                if input.count > 0 {
                    if let value = Int32(input) {
                        if value < 1 || value > 10 {
                            AVAlertController.show(AUIAIMainBundle.getString("Invalid input, please enter value within 1–10 range"), vc: self)
                            return
                        }
                        AUIAICallAgentManager.shared.autoSpeechUserIdleMaxRepeats = value
                        view.rightLabel.text = "\(value)\(AUIAIMainBundle.getString("Times"))"
                        view.setNeedsLayout()
                    }
                }
            }
        }
        view.isHidden = !AUIAICallAgentManager.shared.enableAutoSpeechUserIdle
        return view
    }()
    
    private let ambientVolumeType = [
        "\(AUIAIMainBundle.getString("No Background Sound"))",
        "\(AUIAIMainBundle.getString("Voice Conversation"))",
        "\(AUIAIMainBundle.getString("Customer Service"))",
        "\(AUIAIMainBundle.getString("Outdoor Park"))"
    ]
    private let ambientVolumeIds = ["", "public_conversation", "public_customer_service", "public_park"]
    private var ambientVolumeIndex = 0
    open lazy var ambientVolumeBar: AUIAICallRightClickBar = {
        self.ambientVolumeIndex = self.ambientVolumeIds.firstIndex(of: AUIAICallAgentManager.shared.ambientResourceId) ?? 0
        let view = AUIAICallRightClickBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Call Background Sound")
        view.infoLabel.text = AUIAIMainBundle.getString("Set a background sound for the call, played during the call")
        view.infoLabel.isHidden = false
        view.rightLabel.text = self.ambientVolumeType[self.ambientVolumeIndex]
        view.rightLabel.isHidden = false
        view.tappedAction = { [weak self] bar in
            guard let self = self else {return}
            let panel = AUIAICallListPicker(width: self.view.av_width, title: AUIAIMainBundle.getString("Call Background Sound"), list: self.ambientVolumeType, selected: self.ambientVolumeIndex)
            panel.onPickerSelected = { index, text in
                self.ambientVolumeIndex = index
                AUIAICallAgentManager.shared.ambientResourceId = self.ambientVolumeIds[index]
                view.rightLabel.text = text
                view.setNeedsLayout()
            }
            panel.show(on: self.view, with: .clickToClose)
        }
        return view
    }()
}



@objcMembers open class AUIAICallVoiceprintSettingView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
                
        self.addSubview(self.voiceprintSwitch)
        self.addSubview(self.preRegisterBtn)
        self.addSubview(self.autoRegisterBtn)
        self.addSubview(self.registerDetailLabel)
        self.addSubview(self.stateView)
        self.stateView.addSubview(self.voiceprintLabel)
        self.stateView.addSubview(self.registerBar)
        self.addSubview(self.removeBtn)
        
        self.preRegisterBtn.isSelected = !AUIAICallVoiceprintManager.shared.isAutoRegister
        self.autoRegisterBtn.isSelected = AUIAICallVoiceprintManager.shared.isAutoRegister
        self.updateLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.voiceprintSwitch.frame = CGRect(x: 24, y: 0, width: self.av_width - 48, height: 76)
        
        let btnWidth = (self.av_width - 48 - 12) / 2.0
        self.preRegisterBtn.frame = CGRect(x: 24, y: self.voiceprintSwitch.av_bottom, width: btnWidth, height: 48)
        self.autoRegisterBtn.frame = self.preRegisterBtn.frame
        self.autoRegisterBtn.av_left = self.preRegisterBtn.av_right + 12
        
        self.registerDetailLabel.frame = CGRect(x: 24, y: self.preRegisterBtn.av_bottom + 12, width: self.av_width - 48, height: 40)
        
        self.removeBtn.sizeToFit()
        self.removeBtn.frame = CGRect(x: self.av_width - 24 - self.removeBtn.av_width, y: self.registerDetailLabel.av_bottom + 8, width: self.removeBtn.av_width, height: 48)
        
        let stateViewWidth = self.removeBtn.isHidden ? self.av_width - 48 : self.removeBtn.av_left - 24 - 12
        self.stateView.frame = CGRect(x: 24, y: self.registerDetailLabel.av_bottom + 8, width: stateViewWidth, height: 48)
        
        self.registerBar.sizeToFit()
        self.registerBar.frame = CGRect(x: self.stateView.av_width - 16 - self.registerBar.av_width, y: 0, width: self.registerBar.av_width, height: self.stateView.av_height)
        
        let voiceprintLabelWidth = self.registerBar.isHidden ? self.stateView.av_width - 16 - 16 : self.registerBar.av_left - 16 - 16
        self.voiceprintLabel.frame = CGRect(x: 16, y: 0, width: voiceprintLabelWidth, height: self.stateView.av_height)
    }
    
    open func getCurrentHight() -> CGFloat  {
        let manager = AUIAICallVoiceprintManager.shared
        var vp = 76.0
        if manager.isEnable {
            vp += 48.0 + 12.0 + 40.0
            if manager.isAutoRegister == false || manager.isRegistedVoiceprint() {
                vp += 8.0 + 48.0
            }
        }
        
        return vp
    }
    
    open lazy var voiceprintSwitch: AUIAICallSwitchBar = {
        let view = AUIAICallSwitchBar()
        view.titleLabel.text = AUIAIMainBundle.getString("Voiceprint")
        view.infoLabel.text = AUIAIMainBundle.getString("The AI only uses your voice as input.")
        view.switchBtn.isOn = AUIAICallVoiceprintManager.shared.isEnable
        view.onSwitchValueChangedBlock = { [weak self] bar in
            AUIAICallVoiceprintManager.shared.enableVoiceprint(bar.switchBtn.isOn)
            self?.updateLayout()
        }
        return view
    }()
    
    open lazy var preRegisterBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAIMainBundle.getString("Pre-registration"), for: .normal)
        btn.backgroundColor = AUIAIMainBundle.color_fill_tertiary
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.setTitleColor(AUIAIMainBundle.color_text_secondary, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_selection, for: .selected)
        btn.setBorderColor(AUIAIMainBundle.color_border_secondary, for: .normal)
        btn.setBorderColor(AUIAIMainBundle.color_border_selection, for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 2
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            AUIAICallVoiceprintManager.shared.switchVoiceprintMode(isAutoRegister: false)
            self?.preRegisterBtn.isSelected = !AUIAICallVoiceprintManager.shared.isAutoRegister
            self?.autoRegisterBtn.isSelected = AUIAICallVoiceprintManager.shared.isAutoRegister
            self?.updateLayout()
        }
        return btn
    }()
    
    open lazy var autoRegisterBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAIMainBundle.getString("Seamless Registration"), for: .normal)
        btn.backgroundColor = AUIAIMainBundle.color_fill_tertiary
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.setTitleColor(AUIAIMainBundle.color_text_secondary, for: .normal)
        btn.setTitleColor(AUIAIMainBundle.color_text_selection, for: .selected)
        btn.setBorderColor(AUIAIMainBundle.color_border_secondary, for: .normal)
        btn.setBorderColor(AUIAIMainBundle.color_border_selection, for: .selected)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 2
        btn.clickBlock = {[weak self] btn in
            if btn.isSelected {
                return
            }
            AUIAICallVoiceprintManager.shared.switchVoiceprintMode(isAutoRegister: true)
            self?.preRegisterBtn.isSelected = !AUIAICallVoiceprintManager.shared.isAutoRegister
            self?.autoRegisterBtn.isSelected = AUIAICallVoiceprintManager.shared.isAutoRegister
            self?.updateLayout()
        }
        return btn
    }()
    
    open lazy var registerDetailLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AUIAIMainBundle.color_text_tertiary
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    open lazy var stateView: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAIMainBundle.color_fill_secondary
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.av_setLayerBorderColor(AUIAIMainBundle.color_border_secondary)
        return view
    }()
    
    open lazy var voiceprintLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AUIAIMainBundle.color_text
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    open lazy var registerBar: AUIAICallRightClickBar = {
        let bar = AUIAICallRightClickBar()
        bar.titleLabel.font = AVTheme.regularFont(14)
        bar.titleLabel.text = ""
        return bar
    }()
    
    open lazy var removeBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAIMainBundle.getString("Delete"), for: .normal)
        btn.backgroundColor = AUIAIMainBundle.color_fill_secondary
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.setTitleColor(AUIAIMainBundle.color_text, for: .normal)
        btn.setBorderColor(AUIAIMainBundle.color_border_secondary, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 2
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        btn.clickBlock = {[weak self] btn in
            AUIAICallVoiceprintManager.shared.removeAutoRegister()
            self?.updateLayout()
        }
        return btn
    }()
    
    open func updateLayout() {
        
        let manager = AUIAICallVoiceprintManager.shared

        self.preRegisterBtn.isHidden = !manager.isEnable
        self.autoRegisterBtn.isHidden = !manager.isEnable
        self.registerDetailLabel.isHidden = !manager.isEnable
        self.registerBar.isHidden = manager.isAutoRegister == true
        if manager.isEnable && (manager.isAutoRegister == false || manager.isRegistedVoiceprint()) {
            self.stateView.isHidden = false
            self.removeBtn.isHidden = !(manager.isAutoRegister == true && manager.isRegistedVoiceprint())
        }
        else {
            self.stateView.isHidden = true
            self.removeBtn.isHidden = true
        }
        

        if manager.isAutoRegister {
            self.registerDetailLabel.text = AUIAIMainBundle.getString("Collects voiceprint information during calls, requiring loud and clear speech for more than 15s in a quiet environment")
        }
        else {
            self.registerDetailLabel.text = AUIAIMainBundle.getString("Record and save voiceprint information before the call starts")
        }
        
        if manager.isRegistedVoiceprint() {
            self.voiceprintLabel.text = AUIAIMainBundle.getString("Voiceprint Feature Information") + "(\(AUIAIMainBundle.getString("Registered")))"
            self.registerBar.titleLabel.text = AUIAIMainBundle.getString("Re-register")
        }
        else {
            self.voiceprintLabel.text = AUIAIMainBundle.getString("Voiceprint Feature Information") + "(\(AUIAIMainBundle.getString("Unavailable in calls unless registered")))"
            self.registerBar.titleLabel.text = AUIAIMainBundle.getString("Register")
        }
        
        self.setNeedsLayout()
        
        self.onLayoutChangedBlock?()
    }
    
    open var onLayoutChangedBlock: (()->Void)? = nil
}
