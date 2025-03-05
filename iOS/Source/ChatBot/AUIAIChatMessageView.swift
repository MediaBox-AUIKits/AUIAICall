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


@objcMembers open class AUIAIChatMessageReasonView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.iconView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.expandBtn)
        self.addSubview(self.textLabel)
        self.addSubview(self.lineView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconView.frame = CGRect(x: 12, y: 10, width: 16, height: 16)
        
        self.titleLabel.frame = CGRect(x: self.iconView.isHidden ? 12 : self.iconView.av_right + 8, y: 8, width: self.titleLabel.av_width, height: 20)
        self.expandBtn.frame = CGRect(x: self.titleLabel.av_right, y: 8, width: 26, height: 20)
        
        let h = max(self.av_height - 36, 0.0)
        self.lineView.frame = CGRect(x: 15, y: self.iconView.av_bottom + 12.0, width: 1, height: h)
        self.textLabel.frame = CGRect(x: 28, y: 36, width: self.av_width - 28 - 12, height: h)
    }
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_ultraweak
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = AUIAIChatBundle.getString("Reasoning...")
        label.font = AVTheme.regularFont(14)
        label.textColor = AVTheme.text_ultraweak
        label.sizeToFit()
        return label
    }()
    
    open lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = AVTheme.text_ultraweak
        return view
    }()
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.image = AUIAIChatBundle.getImage("ic_msg_reasoning_end")
        return view
    }()
    
    open lazy var expandBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_msg_reasoning_show"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_msg_reasoning_hide"), for: .selected)
        return btn
    }()
    
    open func updateReasonType(type: ReasonType) {
        if type == .Finished {
            self.iconView.isHidden = false
            self.titleLabel.text = AUIAIChatBundle.getString("Reasonging completed")
        }
        else if type == .Interrupted {
            self.iconView.isHidden = true
            self.titleLabel.text = AUIAIChatBundle.getString("Reasoning stopped")
        }
        else {
            self.iconView.isHidden = true
            self.titleLabel.text = AUIAIChatBundle.getString("Reasoning...")
        }
        self.titleLabel.sizeToFit()
        self.setNeedsLayout()
    }
}


extension AUIAIChatMessageReasonView {
    
    public enum ReasonType: Int32 {
        case None
        case Reasoning
        case Finished
        case Interrupted
    }
    
    public static func isEnableReason(item: AUIAIChatMessageItem) -> Bool {
        return item.message.reasoningText != nil
    }

    public static func getReasonType(item: AUIAIChatMessageItem) -> ReasonType {
        if self.isEnableReason(item: item) == false {
            return .None
        }
        if item.message.isReasoningEnd {
            return .Finished
        }
        if item.message.messageState == .Failed || item.message.messageState == .Interrupted {
            return .Interrupted
        }
        return .Reasoning
    }
    
    public static func getHeight(reasoningText: String, maxWidth: CGFloat) -> CGSize {
        let text = reasoningText
        let font = AVTheme.regularFont(14)
        let maxSize = CGSize(width: maxWidth - 28 - 12, height: CGFloat.greatestFiniteMagnitude) // 限制宽度，允许无限制高度
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let boundingBox = (text as NSString).boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        
        let width = boundingBox.width + 28 + 12
        let height = 36 + (boundingBox.height + 0.1)
        return CGSize(width: width, height: height)
    }
    
    public static func getHeight(item: AUIAIChatMessageItem, maxWidth: CGFloat) -> CGSize {
        if self.isEnableReason(item: item) == false {
            return CGSize.zero
        }
        if item.isExpandReasonText == false {
            return CGSize(width: maxWidth, height: 28)
        }
        return self.getHeight(reasoningText: item.message.reasoningText ?? "" , maxWidth: maxWidth)
    }
}
