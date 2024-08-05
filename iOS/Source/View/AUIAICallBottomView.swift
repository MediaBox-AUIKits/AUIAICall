//
//  AUIAICallBottomView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallBottomView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.handupBtn)
        self.addSubview(self.muteAudioBtn)
        self.addSubview(self.switchSpeakerBtn)
        self.addSubview(self.timeLabel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
                
        let bot = self.av_height - 20
        
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
    
    open lazy var handupBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Hang Up"), iconBgColor: AUIAICallBundle.danger_strong, normalIcon: AUIAICallBundle.getCommonImage("ic_handup"))
        btn.av_size = CGSize(width: 68, height: 94)
        return btn
    }()
    
    open lazy var muteAudioBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Mute"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_mute_audio"), selectedTitle:AUIAICallBundle.getString("Unmute"), selectedIcon:AUIAICallBundle.getCommonImage("ic_mute_audio_selected"))
        btn.av_size = CGSize(width: 52, height: 78)
        return btn
    }()
    
    
    open lazy var switchSpeakerBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAICallBundle.getString("Turn Off Speaker"), iconBgColor: AVTheme.tsp_fill_ultraweak, normalIcon: AUIAICallBundle.getCommonImage("ic_speaker"), selectedTitle:AUIAICallBundle.getString("Turn On Speaker"), selectedIcon:AUIAICallBundle.getCommonImage("ic_speaker_selected"))
        btn.av_size = CGSize(width: 52, height: 78)
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
