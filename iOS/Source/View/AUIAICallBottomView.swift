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
        
        self.addSubview(self.pushToTalkBtn)
        
        self.addSubview(self.timeLabel)
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let agentType: ARTCAICallAgentType
    
    public var enablePushToTalk: Bool = false {
        didSet {
            self.muteAudioBtn.isHidden = self.enablePushToTalk
            self.pushToTalkBtn.isHidden = !self.enablePushToTalk
            
            self.setNeedsLayout()
        }
    }
    
    private var enableCamera: Bool {
        return self.agentType == .VisionAgent || self.agentType == .VideoAgent
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
                
        self.gradientlayer.frame = self.bounds
        if self.enableCamera {
            let bot = self.av_height - UIView.av_safeBottom - 8
            
            self.handupBtn.iconMargin = 5
            self.handupBtn.av_size = CGSize(width: 42, height: 68)
            self.handupBtn.av_centerX = self.av_width / 2.0
            self.handupBtn.av_centerY = bot - self.handupBtn.av_height / 2.0
            
            let center = self.handupBtn.av_top - 12 - 68 / 2.0
            
            self.muteAudioBtn.iconMargin = 9
            self.muteAudioBtn.av_size = CGSize(width: 42, height: 68)
            self.muteAudioBtn.av_centerX = 54 + self.muteAudioBtn.av_width / 2.0
            self.muteAudioBtn.av_centerY = center
            
            self.muteCameraBtn.iconMargin = 9
            self.muteCameraBtn.av_size = CGSize(width: 42, height: 68)
            self.muteCameraBtn.av_centerX = self.av_width - 54 - self.muteCameraBtn.av_width / 2.0
            self.muteCameraBtn.av_centerY = center
            
            self.switchCameraBtn.av_size = CGSize(width: 42, height: 42)
            self.switchCameraBtn.av_centerY = self.handupBtn.av_top + 24
            self.switchCameraBtn.av_centerX = self.muteCameraBtn.av_centerX
            
            if self.enablePushToTalk {
                self.switchSpeakerBtn.iconMargin = 9
                self.switchSpeakerBtn.av_size = CGSize(width: 42, height: 68)
                self.switchSpeakerBtn.av_centerX = 54 + self.switchSpeakerBtn.av_width / 2.0
                self.switchSpeakerBtn.av_centerY = center
            }
            else {
                self.switchSpeakerBtn.iconMargin = 9
                self.switchSpeakerBtn.av_size = CGSize(width: 42, height: 68)
                self.switchSpeakerBtn.av_centerX = self.handupBtn.av_centerX
                self.switchSpeakerBtn.av_centerY = center
            }
            
            self.pushToTalkBtn.iconMargin = 12
            self.pushToTalkBtn.av_size = CGSize(width: 116, height: 78)
            self.pushToTalkBtn.av_centerX = self.av_width / 2.0
            self.pushToTalkBtn.av_bottom = self.switchSpeakerBtn.av_bottom
            
            self.timeLabel.frame = CGRect(x: 0, y: self.switchSpeakerBtn.av_top - 22 - 24, width: self.av_width, height: 22)
        }
        else {
            let bot = self.av_height - UIView.av_safeBottom - 40
            
            if self.enablePushToTalk {
                // 挂断
                self.handupBtn.iconMargin = 9
                self.handupBtn.av_size = CGSize(width: 52, height: 78)
                self.handupBtn.av_centerX = self.av_width - 50 - self.handupBtn.av_width / 2.0
                self.handupBtn.av_centerY = bot - self.handupBtn.av_height / 2.0
                
                // 扬声器
                self.switchSpeakerBtn.iconMargin = 14
                self.switchSpeakerBtn.av_size = CGSize(width: 52, height: 78)
                self.switchSpeakerBtn.av_centerX = 50 + self.switchSpeakerBtn.av_width / 2.0
                self.switchSpeakerBtn.av_centerY = bot - self.switchSpeakerBtn.av_height / 2.0
            }
            else {
                // 挂断
                self.handupBtn.iconMargin = 9
                self.handupBtn.av_size = CGSize(width: 68, height: 94)
                self.handupBtn.av_centerX = self.av_width / 2.0
                self.handupBtn.av_centerY = bot - self.handupBtn.av_height / 2.0
                
                // 扬声器
                self.switchSpeakerBtn.iconMargin = 14
                self.switchSpeakerBtn.av_size = CGSize(width: 52, height: 78)
                self.switchSpeakerBtn.av_centerX = self.av_width - 50 - self.switchSpeakerBtn.av_width / 2.0
                self.switchSpeakerBtn.av_centerY = bot - self.switchSpeakerBtn.av_height / 2.0
            }
            
            // 静音
            self.muteAudioBtn.iconMargin = 14
            self.muteAudioBtn.av_size = CGSize(width: 52, height: 78)
            self.muteAudioBtn.av_centerX = 50 + self.muteAudioBtn.av_width / 2.0
            self.muteAudioBtn.av_centerY = bot - self.muteAudioBtn.av_height / 2.0
            
            // 按住说话
            self.pushToTalkBtn.iconMargin = 12
            self.pushToTalkBtn.av_size = CGSize(width: 116, height: 78)
            self.pushToTalkBtn.av_centerX = self.av_width / 2.0
            self.pushToTalkBtn.av_centerY = bot - self.handupBtn.av_height / 2.0
            
            // 通话时间
            self.timeLabel.frame = CGRect(x: 0, y: self.handupBtn.av_top - 22 - 24, width: self.av_width, height: 22)
        }
    }
    
    open lazy var gradientlayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        return layer
    }()
    
    open lazy var handupBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Hang Up"), iconBgColor: AUIAICallBundle.danger_strong, normalIcon: AUIAICallBundle.getCommonImage("ic_handup"))
        return btn
    }()
    
    open lazy var muteAudioBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Mute"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_mute_audio"), selectedTitle:AUIAICallBundle.getString("Unmute"), selectedIcon:AUIAICallBundle.getCommonImage("ic_mute_audio_selected"))
        return btn
    }()
    
    open lazy var muteCameraBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Turn Off Camera"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_mute_camera"), selectedTitle:AUIAICallBundle.getString("Turn On Camera"), selectedIcon:AUIAICallBundle.getCommonImage("ic_mute_camera_selected"))
        return btn
    }()
    
    open lazy var switchSpeakerBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Turn Off Speaker"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_speaker"), selectedTitle:AUIAICallBundle.getString("Turn On Speaker"), selectedIcon:AUIAICallBundle.getCommonImage("ic_speaker_selected"))
        return btn
    }()
    
    lazy var switchCameraBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAICallBundle.getCommonImage("ic_switch_camera"), for: .normal)
        return btn
    }()
    
    open lazy var pushToTalkBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Push to Talk"),
                                         iconBgColor: AVTheme.fill_infrared,
                                         normalIcon: AUIAICallBundle.getCommonImage("ic_ptt_press"),
                                         selectedBgColor: AVTheme.colourful_fill_strong,
                                         selectedTitle:AUIAICallBundle.getString("Release to Send"),
                                         selectedIcon:AUIAICallBundle.getCommonImage("ic_ptt_release"))
        btn.isHidden = true
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
