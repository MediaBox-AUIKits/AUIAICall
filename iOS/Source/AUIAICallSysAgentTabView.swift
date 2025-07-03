//
//  AUIAICallSysAgentTabView.swift
//  ARTCAICallKit
//
//  Created by Bingo on 2025/6/20.
//

import UIKit
import AUIFoundation

let VoiceAgentTypeIndex: Int = 0
let AvatarAgentTypeIndex: Int = 1
let VisionAgentTypeIndex: Int = 2
let VideoAgentTypeIndex: Int = 3
let ChatAgentTypeIndex: Int = 100
let OutboundCallTypeIndex: Int = 101

@objcMembers open class AUIAICallSysAgentTabView: UIScrollView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
                
        var right = 28.0
        self.audioCallBtn.sizeToFit()
        self.audioCallBtn.av_left = right
        self.addSubview(self.audioCallBtn)
        right = self.audioCallBtn.av_right + 20
        
        self.avatarCallBtn.sizeToFit()
        self.avatarCallBtn.av_left = right
        self.addSubview(self.avatarCallBtn)
        right = self.avatarCallBtn.av_right + 20
        
        self.visionCallBtn.sizeToFit()
        self.visionCallBtn.av_left = right
        self.addSubview(self.visionCallBtn)
        right = self.visionCallBtn.av_right + 20

        self.chatBtn.sizeToFit()
        self.chatBtn.av_left = right
        self.addSubview(self.chatBtn)
        right = self.chatBtn.av_right + 20
        
        self.videoCallBtn.sizeToFit()
        self.videoCallBtn.av_left = right
        self.addSubview(self.videoCallBtn)
        right = self.videoCallBtn.av_right + 28
        
        if AUIAICallAgentConfig.shared.enableOutboundCall {
            self.outboundCallBtn.sizeToFit()
            self.outboundCallBtn.av_left = right
            self.addSubview(self.outboundCallBtn)
            right = self.outboundCallBtn.av_right + 28
        }
        
        self.addSubview(self.lineView)
        self.contentSize = CGSize(width: right, height: self.av_height)
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
        btn.tag = VoiceAgentTypeIndex
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int = sender.tag
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
        btn.tag = AvatarAgentTypeIndex
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int = sender.tag
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
        btn.tag = VisionAgentTypeIndex
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int = sender.tag
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
        btn.tag = ChatAgentTypeIndex
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int = sender.tag
            self?.agentIndex = agentIndex
            self?.agentWillChanged?(agentIndex)
        }
        return btn
    }()
    
    open lazy var videoCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.chatBtn.av_right + 20.0, y: 0, width: 0, height: 0))
        btn.setTitle(AUIAIMainBundle.getString("AI Video Call"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.mediumFont(12)
        btn.tag = VideoAgentTypeIndex
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int = sender.tag
            self?.agentIndex = agentIndex
            self?.agentWillChanged?(agentIndex)
        }
        return btn
    }()
    
    open lazy var outboundCallBtn: AVBlockButton = {
        let btn = AVBlockButton(frame: CGRect(x: self.videoCallBtn.av_right + 20.0, y: 0, width: 0, height: 0))
        btn.setTitle(AUIAIMainBundle.getString("AI Call Out"), for: .normal)
        btn.setTitleColor(AVTheme.text_weak, for: .normal)
        btn.setTitleColor(AVTheme.colourful_text_strong, for: .selected)
        btn.titleLabel?.font = AVTheme.mediumFont(12)
        btn.tag = OutboundCallTypeIndex
        btn.clickBlock = { [weak self] sender in
            let agentIndex: Int = sender.tag
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
    
    open var agentIndex: Int = VoiceAgentTypeIndex {
        didSet {
            self.updateAgent()
        }
    }
    
    func updateAgent() {
        let agentIndex = self.agentIndex
        var rect = self.lineView.frame
        if agentIndex == VoiceAgentTypeIndex {
            self.audioCallBtn.isSelected = true
            self.audioCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.videoCallBtn.isSelected = false
            self.videoCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.outboundCallBtn.isSelected = false
            self.outboundCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.audioCallBtn.av_left, y: self.audioCallBtn.av_bottom + 4, width: self.audioCallBtn.av_width, height: 1)
        }
        else if agentIndex == AvatarAgentTypeIndex {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = true
            self.avatarCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.videoCallBtn.isSelected = false
            self.videoCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.outboundCallBtn.isSelected = false
            self.outboundCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.avatarCallBtn.av_left, y: self.avatarCallBtn.av_bottom + 4, width: self.avatarCallBtn.av_width, height: 1)
        }
        else if agentIndex == VisionAgentTypeIndex {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = true
            self.visionCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.videoCallBtn.isSelected = false
            self.videoCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.outboundCallBtn.isSelected = false
            self.outboundCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.visionCallBtn.av_left, y: self.visionCallBtn.av_bottom + 4, width: self.visionCallBtn.av_width, height: 1)
        }
        else if agentIndex == VideoAgentTypeIndex {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.videoCallBtn.isSelected = true
            self.videoCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.outboundCallBtn.isSelected = false
            self.outboundCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.videoCallBtn.av_left, y: self.videoCallBtn.av_bottom + 4, width: self.videoCallBtn.av_width, height: 1)
        }
        else if agentIndex == ChatAgentTypeIndex {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = true
            self.chatBtn.titleLabel?.font = AVTheme.mediumFont(12)
            self.videoCallBtn.isSelected = false
            self.videoCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.outboundCallBtn.isSelected = false
            self.outboundCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            rect = CGRect(x: self.chatBtn.av_left, y: self.chatBtn.av_bottom + 4, width: self.chatBtn.av_width, height: 1)
        }
        else if agentIndex == OutboundCallTypeIndex {
            self.audioCallBtn.isSelected = false
            self.audioCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.avatarCallBtn.isSelected = false
            self.avatarCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.visionCallBtn.isSelected = false
            self.visionCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.chatBtn.isSelected = false
            self.chatBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.videoCallBtn.isSelected = false
            self.videoCallBtn.titleLabel?.font = AVTheme.regularFont(12)
            self.outboundCallBtn.isSelected = false
            self.outboundCallBtn.titleLabel?.font = AVTheme.mediumFont(12)
            rect = CGRect(x: self.outboundCallBtn.av_left, y: self.outboundCallBtn.av_bottom + 4, width: self.outboundCallBtn.av_width, height: 1)
        }
        UIView.animate(withDuration: 0.3) {
            self.lineView.frame = rect
        }
    }
    
    open var agentWillChanged: ((_ agentIndex: Int) -> Void)? = nil
}
