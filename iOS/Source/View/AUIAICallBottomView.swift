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
        
        self.addSubview(self.handupBtn)
        self.addSubview(self.muteAudioBtn)
        self.addSubview(self.switchSpeakerBtn)
        
        if self.enableCamera {
            self.addSubview(self.muteCameraBtn)
            self.addSubview(self.switchCameraBtn)
        }
        
        self.addSubview(self.pushToTalkBtn)
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
                
        var bot = self.av_height - UIView.av_safeBottom - 52.0
        if self.enablePushToTalk {
            bot = self.av_height - UIView.av_safeBottom - 82.0
        }
        
        var maxMargin = 40.0
        var btnArray: [UIView] = [
            self.muteAudioBtn,
            self.handupBtn,
            self.switchSpeakerBtn
        ]
        if self.enableCamera {
            if self.enablePushToTalk {
                maxMargin = 26.0
                btnArray = [
                    self.switchSpeakerBtn,
                    self.muteCameraBtn,
                    self.handupBtn,
                    self.switchCameraBtn,
                ]
            }
            else {
                maxMargin = 26.0
                btnArray = [
                    self.muteAudioBtn,
                    self.switchSpeakerBtn,
                    self.handupBtn,
                    self.muteCameraBtn,
                    self.switchCameraBtn
                ]
            }
        }
        else {
            if self.enablePushToTalk {
                maxMargin = 80.0
                btnArray = [
                    self.switchSpeakerBtn,
                    self.handupBtn,
                ]
            }
            else {
                maxMargin = 40.0
                btnArray = [
                    self.muteAudioBtn,
                    self.handupBtn,
                    self.switchSpeakerBtn
                ]
            }
        }
        let margin = min((self.av_width - 48.0 - CGFloat(btnArray.count) * 60.0) / CGFloat(btnArray.count - 1), maxMargin)
        var x = (self.av_width - CGFloat(btnArray.count) * 60.0 - CGFloat(btnArray.count - 1) * margin) / 2.0
        btnArray.forEach { btn in
            btn.av_left = x
            btn.av_bottom = bot
            x = btn.av_right + margin
        }
        
        // 按住说话
        self.pushToTalkBtn.av_size = CGSize(width: self.av_width - 48, height: 42)
        self.pushToTalkBtn.av_centerX = self.av_width / 2.0
        self.pushToTalkBtn.av_bottom = self.av_height - UIView.av_safeBottom - 24.0
    }
    
    open lazy var handupBtn: AUIAICallButton = {
        let btn = AUIAICallButton()
        btn.normalBgColor = AUIAICallBundle.color_error
        btn.normalImage = AUIAICallBundle.getTemplateImage("ic_handup")
        btn.normalTintColor = AUIAICallBundle.color_icon_identical
        btn.iconLength = 60.0
        btn.iconMargin = 16.0
        btn.av_size = CGSize(width: 60, height: 60)
        btn.isSelected = false
        return btn
    }()
    
    open lazy var muteAudioBtn: AUIAICallButton = {
        let btn = AUIAICallButton()
        btn.normalBgColor = AUIAICallBundle.color_fill_secondary
        btn.selectedBgColor = AUIAICallBundle.color_fill_selection
        btn.normalImage = AUIAICallBundle.getTemplateImage("ic_mute_audio")
        btn.selectedImage = AUIAICallBundle.getTemplateImage("ic_mute_audio_selected")
        btn.normalTintColor = AUIAICallBundle.color_icon
        btn.selectedTintColor = AUIAICallBundle.color_icon_Inverse
        btn.normalBorderColor = AUIAICallBundle.color_border_secondary
        btn.selectedBorderColor = AUIAICallBundle.color_border_selection
        btn.iconLength = 60.0
        btn.iconMargin = 18.0
        btn.iconBorderWidth = 0.5
        btn.av_size = CGSize(width: 60, height: 60)
        btn.isSelected = false
        return btn
    }()
    
    open lazy var muteCameraBtn: AUIAICallButton = {
        let btn = AUIAICallButton()
        btn.normalBgColor = AUIAICallBundle.color_fill_secondary
        btn.selectedBgColor = AUIAICallBundle.color_fill_selection
        btn.normalImage = AUIAICallBundle.getTemplateImage("ic_mute_camera")
        btn.selectedImage = AUIAICallBundle.getTemplateImage("ic_mute_camera_selected")
        btn.normalTintColor = AUIAICallBundle.color_icon
        btn.selectedTintColor = AUIAICallBundle.color_icon_Inverse
        btn.normalBorderColor = AUIAICallBundle.color_border_secondary
        btn.selectedBorderColor = AUIAICallBundle.color_border_selection
        btn.iconLength = 60.0
        btn.iconMargin = 18.0
        btn.iconBorderWidth = 0.5
        btn.av_size = CGSize(width: 60, height: 60)
        btn.isSelected = false
        return btn
    }()
    
    open lazy var switchSpeakerBtn: AUIAICallButton = {
        let btn = AUIAICallButton()
        btn.normalBgColor = AUIAICallBundle.color_fill_secondary
        btn.selectedBgColor = AUIAICallBundle.color_fill_selection
        btn.normalImage = AUIAICallBundle.getTemplateImage("ic_speaker")
        btn.selectedImage = AUIAICallBundle.getTemplateImage("ic_speaker_selected")
        btn.normalTintColor = AUIAICallBundle.color_icon
        btn.selectedTintColor = AUIAICallBundle.color_icon_Inverse
        btn.normalBorderColor = AUIAICallBundle.color_border_secondary
        btn.selectedBorderColor = AUIAICallBundle.color_border_selection
        btn.iconLength = 60.0
        btn.iconMargin = 18.0
        btn.iconBorderWidth = 0.5
        btn.av_size = CGSize(width: 60, height: 60)
        btn.isSelected = false
        return btn
    }()
    
    open lazy var switchCameraBtn: AUIAICallButton = {
        let btn = AUIAICallButton()
        btn.normalBgColor = AUIAICallBundle.color_fill_secondary
        btn.normalImage = AUIAICallBundle.getTemplateImage("ic_switch_camera")
        btn.normalTintColor = AUIAICallBundle.color_icon
        btn.normalBorderColor = AUIAICallBundle.color_border_secondary
        btn.iconLength = 60.0
        btn.iconMargin = 18.0
        btn.iconBorderWidth = 0.5
        btn.av_size = CGSize(width: 60, height: 60)
        btn.isSelected = false
        return btn
    }()
    
    open lazy var pushToTalkBtn: AUIAICallPushToTalkButton = {
        let btn = AUIAICallPushToTalkButton(frame: CGRect.zero)
        btn.isHidden = true
        return btn
    }()
}
