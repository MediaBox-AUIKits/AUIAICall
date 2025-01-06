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

let VoiceAgentEmotionalId = ""
let AvatarAgentEmotionalId = ""
let VisionAgentEmotionalId = ""

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
    
    public func getAgentID(agentType: ARTCAICallAgentType) -> String? {
        var ret: String? = nil
        switch agentType {
        case .VoiceAgent:
            ret = self.emotional ? VoiceAgentEmotionalId : VoiceAgentId
        case .AvatarAgent:
            ret = self.emotional ? AvatarAgentEmotionalId : AvatarAgentId
        case .VisionAgent:
            ret = self.emotional ? VisionAgentEmotionalId : VisionAgentId
        }
        
        // 为空值的情况下，使用在AppServer上配置的智能体Id
        if ret != nil && ret!.isEmpty == true {
            return nil
        }
        return ret
    }
}


@objcMembers open class AUIAICallAgentConfigPanel: AVBaseControllPanel {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleView.text = AUIAICallBundle.getString("Configuration")
        self.contentView.addSubview(self.emotionLabel)
        self.contentView.addSubview(self.emotionInfoLabel)
        self.contentView.addSubview(self.unemotionalBtn)
        self.contentView.addSubview(self.emotionalBtn)
        
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
        return 156 + 46
    }
    
    private func updateLayout() {
        
        var top: CGFloat = 16
        self.emotionLabel.frame = CGRect(x: 20, y: top, width: self.contentView.av_width - 40, height: 22)
        
        top = self.emotionLabel.av_bottom + 4
        self.emotionInfoLabel.frame = CGRect(x: self.emotionLabel.av_left, y: top, width: self.emotionLabel.av_width, height: 16)
        
        top = self.emotionInfoLabel.av_bottom + 12
        self.unemotionalBtn.sizeToFit()
        self.unemotionalBtn.frame = CGRect(x: 20, y: top, width: self.unemotionalBtn.av_width, height: 32)
        self.emotionalBtn.sizeToFit()
        self.emotionalBtn.frame = CGRect(x: self.unemotionalBtn.av_right + 16, y: top, width: self.emotionalBtn.av_width, height: 32)
    }
    
    lazy var emotionLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_strong
        label.text = AUIAICallBundle.getString("Emotion Support")
        return label
    }()
    
    lazy var emotionInfoLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(10)
        label.textColor = AVTheme.text_weak
        label.text = AUIAICallBundle.getString("Does agent support emotional label output?")
        return label
    }()
    
    lazy var unemotionalBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitle(AUIAICallBundle.getString("Unemotional"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .selected)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.setBorderColor(AVTheme.border_weak, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_weak, for: .selected)
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
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setTitle(AUIAICallBundle.getString("Emotional"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .selected)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.setBorderColor(AVTheme.border_weak, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_weak, for: .selected)
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
