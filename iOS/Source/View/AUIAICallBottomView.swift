//
//  AUIAICallBottomView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallBottomView: UIView {

    public init(agentType: ARTCAICallAgentType) {
        self.agentType = agentType
        super.init(frame: CGRect.zero)
        
        self.layer.addSublayer(self.gradientlayer)
        self.addSubview(self.handupBtn)
        self.addSubview(self.muteAudioBtn)
        self.addSubview(self.switchSpeakerBtn)
        
        if self.enableCamera {
            self.addSubview(self.muteCameraBtn)
            self.addSubview(self.switchCameraBtn)
        }
        
        self.addSubview(self.timeLabel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let agentType: ARTCAICallAgentType
    
    private var enableCamera: Bool {
        return self.agentType == .VisionAgent
    }
    
    private func getBtnSize() -> CGSize {
        return self.enableCamera ? CGSize(width: 42, height: 68) : CGSize(width: 52, height: 78)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
                
        self.gradientlayer.frame = self.bounds
        if self.enableCamera {
            var bot = self.av_height - UIView.av_safeBottom - 8
            self.handupBtn.av_centerX = self.av_width / 2.0
            self.handupBtn.av_centerY = bot - self.handupBtn.av_height / 2.0
            
            bot = self.handupBtn.av_top - 12
            self.switchSpeakerBtn.av_centerX = self.handupBtn.av_centerX
            self.switchSpeakerBtn.av_centerY = bot - self.switchSpeakerBtn.av_height / 2.0
            self.muteAudioBtn.av_centerX = 54 + self.muteAudioBtn.av_width / 2.0
            self.muteAudioBtn.av_centerY = self.switchSpeakerBtn.av_centerY
            self.muteCameraBtn.av_centerX = self.av_width - 54 - self.muteAudioBtn.av_width / 2.0
            self.muteCameraBtn.av_centerY = self.switchSpeakerBtn.av_centerY
            
            self.switchCameraBtn.av_centerY = self.handupBtn.av_top + 24
            self.switchCameraBtn.av_centerX = self.muteCameraBtn.av_centerX
            
            self.timeLabel.frame = CGRect(x: 0, y: self.switchSpeakerBtn.av_top - 22 - 8, width: self.av_width, height: 22)
        }
        else {
            let bot = self.av_height - UIView.av_safeBottom - 40
            // 挂断
            self.handupBtn.av_centerX = self.av_width / 2.0
            self.handupBtn.av_centerY = bot - self.handupBtn.av_height / 2.0
            // 静音
            self.muteAudioBtn.av_centerX = 50 + self.muteAudioBtn.av_width / 2.0
            self.muteAudioBtn.av_centerY = bot - self.muteAudioBtn.av_height / 2.0
            // 扬声器
            self.switchSpeakerBtn.av_centerX = self.av_width - 50 - self.switchSpeakerBtn.av_width / 2.0
            self.switchSpeakerBtn.av_centerY = bot - self.switchSpeakerBtn.av_height / 2.0
            // 通话时间
            self.timeLabel.frame = CGRect(x: 0, y: self.handupBtn.av_top - 22 - 12, width: self.av_width, height: 22)
        }
    }
    
    open lazy var gradientlayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        if self.agentType == .AvatarAgent {
            layer.locations = [0.27, 0.99]
            layer.startPoint = CGPoint(x: 0.5, y: 0.06)
            layer.endPoint = CGPoint(x: 0.5, y: 0.4)
            layer.colors = [UIColor.av_color(withHexString: "#001146", alpha: 0.0).cgColor, UIColor.av_color(withHexString: "#00040F", alpha: 1.0).cgColor]

        }
        else if self.agentType == .VisionAgent {
            layer.startPoint = CGPoint(x: 0.5, y: 0.0)
            layer.endPoint = CGPoint(x: 0.5, y: 1.0)
            layer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        }

        return layer
    }()
    
    open lazy var handupBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Hang Up"), iconBgColor: AUIAICallBundle.danger_strong, normalIcon: AUIAICallBundle.getCommonImage("ic_handup"))
        if self.enableCamera {
            btn.av_size = CGSize(width: 48, height: 74)
        }
        else {
            btn.av_size = CGSize(width: 68, height: 94)
        }
        return btn
    }()
    
    open lazy var muteAudioBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Mute"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_mute_audio"), selectedTitle:AUIAICallBundle.getString("Unmute"), selectedIcon:AUIAICallBundle.getCommonImage("ic_mute_audio_selected"))
        btn.av_size = self.getBtnSize()
        return btn
    }()
    
    open lazy var muteCameraBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Turn Off Camera"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_mute_camera"), selectedTitle:AUIAICallBundle.getString("Turn On Camera"), selectedIcon:AUIAICallBundle.getCommonImage("ic_mute_camera_selected"))
        btn.av_size = self.getBtnSize()
        return btn
    }()
    
    open lazy var switchSpeakerBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Turn Off Speaker"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_speaker"), selectedTitle:AUIAICallBundle.getString("Turn On Speaker"), selectedIcon:AUIAICallBundle.getCommonImage("ic_speaker_selected"))
        btn.av_size = self.getBtnSize()
        return btn
    }()
    
    lazy var switchCameraBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAICallBundle.getCommonImage("ic_switch_camera"), for: .normal)
        let size = self.getBtnSize()
        btn.av_size = CGSize(width: size.width, height: size.width)
        return btn
    }()
    
    open lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.regularFont(14)
        label.text = ""
        return label
    }()
}
