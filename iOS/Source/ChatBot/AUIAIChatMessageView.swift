//
//  AUIAIChatMessageView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAIChatMessageBgView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAIChatBundle.chat_bg
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let corners: UIRectCorner = self.isLeft ? [.topLeft, .topRight, .bottomRight] : [.topLeft, .topRight, .bottomLeft]
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 12, height: 12))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    open var isLeft: Bool = false {
        didSet {
            self.setNeedsLayout()
            self.backgroundColor = self.isLeft ? AVTheme.fill_weak : AUIAIChatBundle.chat_bg
        }
    }
    
}

// 高度为：24
// 宽度填满他的父view
@objcMembers open class AUIAIChatMessageActionView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.playBtn)
        self.addSubview(self.copyBtn)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let y = (self.av_height - 32.0) / 2.0
        let w = 32.0
        if self.isLeft {
            var left = 6.0
            self.copyBtn.frame = CGRect(x: left, y: y, width: w, height: w)
            left = self.copyBtn.av_right
            self.playBtn.frame = CGRect(x: left, y: y, width: w, height: w)
        }
        else {
            var right = self.av_width - 6.0
            self.copyBtn.frame = CGRect(x: right - w, y: y, width: w, height: w)
            right = self.copyBtn.av_left - 8.0
            self.playBtn.frame = CGRect(x: right - w, y: y, width: w, height: w)
        }
    }
    
    lazy var copyBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(self.isLeft ? AUIAIChatBundle.getImage("ic_msg_copy_left") : AUIAIChatBundle.getImage("ic_msg_copy_right"), for: .normal)
        return btn
    }()
    
    lazy var playBtn: AUIAIChatMessagePlayButton = {
        let btn = AUIAIChatMessagePlayButton()
        btn.displayImg = self.isLeft ? AUIAIChatBundle.getImage("ic_msg_play_left") : AUIAIChatBundle.getImage("ic_msg_play_right")
        return btn
    }()
    
    open var isLeft: Bool = false {
        didSet {
            self.setNeedsLayout()
            self.copyBtn.setImage(self.isLeft ? AUIAIChatBundle.getImage("ic_msg_copy_left") : AUIAIChatBundle.getImage("ic_msg_copy_right"), for: .normal)
            self.playBtn.displayImg = self.isLeft ? AUIAIChatBundle.getImage("ic_msg_play_left") : AUIAIChatBundle.getImage("ic_msg_play_right")
        }
    }
}

@objcMembers open class AUIAIChatMessagePlayButton: AVBlockButton {
    
    open var displayImg: UIImage? = nil {
        didSet {
            if self.isPlaying == false {
                self.setImage(self.displayImg, for: .normal)
            }
        }
    }
    open var isPlaying: Bool = false {
        didSet {
            if self.isPlaying {
                self.startPlaying()
            }
            else {
                self.stopPlaying()
            }
        }
    }
    
    var timer: Timer? = nil
    var currentIndex: Int = 0
    func startPlaying() {
        self.stopPlaying()
        self.showPlayingImg()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            self.showPlayingImg()
        })
        self.timer = timer
    }
    
    func stopPlaying() {
        self.timer?.invalidate()
        self.timer = nil
        self.currentIndex = 0
        self.setImage(self.displayImg, for: .normal)
    }
    
    func showPlayingImg() {
        let img = AUIAIChatBundle.getImage("ic_msg_play_ani_\(self.currentIndex)")
        self.setImage(img, for: .normal)
        self.currentIndex += 1
        if self.currentIndex > 2 {
            self.currentIndex = 0
        }
    }
}
