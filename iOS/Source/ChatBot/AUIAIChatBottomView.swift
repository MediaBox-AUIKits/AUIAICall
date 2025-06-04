//
//  AUIAIChatBottomView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAIChatBottomView: UIView {

    public init() {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = AVTheme.bg_weak
        self.addSubview(self.addBtn)
        self.addSubview(self.rightBtn)
        self.addSubview(self.textView)
        self.addSubview(self.audioView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addBtn.frame = CGRect(x: 14, y: 14, width: 40, height: 40)
        self.rightBtn.frame = CGRect(x: self.av_right - 40 - 14, y: 14, width: 40, height: 40)

        let left = self.addBtn.av_right + 6
        var width = self.rightBtn.av_left - 12 - left
        self.textView.frame = CGRect(x: left, y: 14, width: width, height: 40)
        
        width = self.av_width - 20 - left
        self.audioView.frame = CGRect(x: left, y: 14, width: width, height: 40)
    }
    
    open lazy var addBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_add"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_add_selected"), for: .selected)
        btn.setImage(AUIAIChatBundle.getImage("ic_add_disabled"), for: .disabled)

        btn.clickBlock = { [weak self] btn in
            if btn.isSelected {
                self?.reset()
            }
            else {
                self?.expand()
            }
        }
        return btn
    }()
    
    open lazy var textView: AUIAIChatInputTextView = {
        let view = AUIAIChatInputTextView()
        view.onClickedSelectedAudio = {[weak self] textView in
            guard let self = self else {
                return
            }
            self.isAudioMode = true
        }
        view.onClickedStop = {[weak self] sender in
            guard let self = self else {
                return
            }
            self.onClickedStop?(self)
        }
        return view
    }()
        
    open lazy var audioView: AUIAIChatInputAudioView = {
        let view = AUIAIChatInputAudioView()
        view.isHidden = true
        view.onClickedSelectedText = {[weak self] textView in
            guard let self = self else {
                return
            }
            self.isAudioMode = false
        }
        view.onClickedStop = {[weak self] sender in
            guard let self = self else {
                return
            }
            self.onClickedStop?(self)
        }
        return view
    }()
    
    open lazy var rightBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_audio"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_audio_disabled"), for: .disabled)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.isAudioMode = !self.isAudioMode
        }
        return btn
    }()
    
    open var isAudioMode: Bool = false {
        didSet {
            self.audioView.isHidden = !self.isAudioMode
            self.textView.isHidden = self.isAudioMode
        }
    }
    
    open var isStopped: Bool = false {
        didSet {
            self.audioView.isStopped = self.isStopped
            self.textView.isStopped = self.isStopped
            self.addBtn.isEnabled = !self.isStopped
            self.rightBtn.isEnabled = !self.isStopped
        }
    }
    open var onClickedStop: ((_ sender: AUIAIChatBottomView) -> Void)? = nil
    
    
    
    // ==========================展开状态处理==========================
     
    open var enableCall: Bool = true
    
    open lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        self.addSubview(scrollView)
        return scrollView
    }()
    
    open lazy var voiceCallBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAIChatBundle.getString("Voice Call"), iconBgColor: AVTheme.fg_strong, normalIcon: AUIAIChatBundle.getImage("ic_call_voice"))
        btn.iconCorner = 10.0
        btn.iconLength = 70.0
        btn.iconMargin = 18.0
        btn.isHidden = true
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var avatarCallBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAIChatBundle.getString("Avatar Call"), iconBgColor: AVTheme.fg_strong, normalIcon: AUIAIChatBundle.getImage("ic_call_avatar"))
        btn.iconCorner = 10.0
        btn.iconLength = 70.0
        btn.iconMargin = 18.0
        btn.isHidden = true
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var visionCallBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAIChatBundle.getString("Vision Call"), iconBgColor: AVTheme.fg_strong, normalIcon: AUIAIChatBundle.getImage("ic_call_vision"))
        btn.iconCorner = 10.0
        btn.iconLength = 70.0
        btn.iconMargin = 18.0
        btn.isHidden = true
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var videoCallBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAIChatBundle.getString("Video Call"), iconBgColor: AVTheme.fg_strong, normalIcon: AUIAIChatBundle.getImage("ic_call_video"))
        btn.iconCorner = 10.0
        btn.iconLength = 70.0
        btn.iconMargin = 18.0
        btn.isHidden = true
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var addPhotoBtn: AUIAICallButton = {
        let btn = AUIAICallButton.create(title: AUIAIChatBundle.getString("Album"), iconBgColor: AVTheme.fg_strong, normalIcon: AUIAIChatBundle.getImage("ic_photo_picker"))
        btn.iconCorner = 10.0
        btn.iconLength = 70.0
        btn.iconMargin = 18.0
        btn.isHidden = true
        self.scrollView.addSubview(btn)
        return btn
    }()


    func expand() {
        guard self.addBtn.isSelected == false else {
            return
        }
        
        let left = 20.0
        let top = 68.0 + 4.0
        let width = 70.0
        let height = 98.0
        let margin = 18.0
        self.addPhotoBtn.frame = CGRect(x: left, y: 0, width: width, height: height)
        self.voiceCallBtn.frame = CGRect(x: self.addPhotoBtn.av_right + margin, y: 0, width: width, height: height)
        self.avatarCallBtn.frame = CGRect(x: self.voiceCallBtn.av_right + margin, y: 0, width: width, height: height)
        self.visionCallBtn.frame = CGRect(x: self.avatarCallBtn.av_right + margin, y: 0, width: width, height: height)
        self.videoCallBtn.frame = CGRect(x: self.visionCallBtn.av_right + margin, y: 0, width: width, height: height)
        
        self.addPhotoBtn.isHidden = false
        self.voiceCallBtn.isHidden = self.enableCall ? false : true
        self.avatarCallBtn.isHidden = self.enableCall ? false : true
        self.visionCallBtn.isHidden = self.enableCall ? false : true
        self.videoCallBtn.isHidden = self.enableCall ? false : true
        
        self.scrollView.frame = CGRect(x: 0, y: top, width: self.av_width, height: height)
        self.scrollView.contentSize = CGSize(width: self.enableCall ? self.videoCallBtn.av_right + left : self.addPhotoBtn.av_right + left, height: height)

        UIView.animate(withDuration: 0.25) {
            let bot = self.av_bottom
            let height = 68 + 106 + UIView.av_safeBottom
            self.av_height = height
            self.av_bottom = bot
        }
        self.addBtn.isSelected = true
    }
    
    func reset() {
        
        guard self.addBtn.isSelected else {
            return
        }
        
        self.addPhotoBtn.isHidden = true
        self.voiceCallBtn.isHidden = true
        self.avatarCallBtn.isHidden = true
        self.visionCallBtn.isHidden = true
        self.videoCallBtn.isHidden = true

        UIView.animate(withDuration: 0.25) {
            let bot = self.av_bottom
            let height = 68 + UIView.av_safeBottom
            self.av_height = height
            self.av_bottom = bot
        }
        self.addBtn.isSelected = false
    }
}

@objcMembers open class AUIAIChatInputTextView: UIView {
    
    public init() {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = AVTheme.fg_strong
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        self.addSubview(self.placeholderView)
        self.addSubview(self.stopBtn)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.stopBtn.frame = CGRect(x: self.av_width - 40 - 6, y: 0, width: 40, height: 40)
        self.placeholderView.frame = CGRect(x: 12, y: 0, width: self.stopBtn.av_left - 6, height: 40)
    }
    
    fileprivate lazy var placeholderView: AVBlockButton = {
        let view = AVBlockButton()
        view.contentHorizontalAlignment = .left
        view.setTitle(AUIAIChatBundle.getString("Please enter content"), for: .normal)
        view.setTitleColor(AVTheme.text_ultraweak, for: .normal)
        view.titleLabel?.font = AVTheme.regularFont(14)
        view.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onClickedInputText?(self)
        }
        return view
    }()
    
    fileprivate lazy var stopBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_stop"), for: .normal)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onClickedStop?(self)
        }
        return btn
    }()
    
    fileprivate var onClickedSelectedAudio: ((_ sender: AUIAIChatInputTextView) -> Void)? = nil
    fileprivate var isStopped: Bool = false {
        didSet {
            self.stopBtn.isHidden = !self.isStopped
            self.placeholderView.isEnabled = !self.isStopped
        }
    }
    fileprivate var onClickedStop: ((_ sender: AUIAIChatInputTextView) -> Void)? = nil
    
    public var onClickedInputText: ((_ sender: AUIAIChatInputTextView) -> Void)? = nil
    
    public func updatePlaceholderText(text: String?) {
        if let text = text, text.isEmpty == false {
            self.placeholderView.setTitle(text, for: .normal)
        }
        else {
            self.placeholderView.setTitle(AUIAIChatBundle.getString("Please enter content"), for: .normal)
        }
    }
}

@objcMembers open class AUIAIChatInputAudioView: UIView {
    
    public init() {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = AVTheme.fg_strong
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        
        self.addSubview(self.placeholderView)
        self.addSubview(self.rightBtn)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rightBtn.frame = CGRect(x: self.av_width - 40 - 6, y: 0, width: 40, height: 40)
        self.placeholderView.frame = CGRect(x: 12, y: 0, width: self.rightBtn.av_left - 6, height: 40)
    }
    
    fileprivate lazy var placeholderView: AUIAICallDragButton = {
        let view = AUIAICallDragButton()
        view.contentHorizontalAlignment = .center
        view.setTitle(AUIAIChatBundle.getString("Press and hold to speak"), for: .normal)
        view.setTitleColor(AVTheme.text_strong, for: .normal)
        view.setTitleColor(AVTheme.text_ultraweak, for: .disabled)
        view.titleLabel?.font = AVTheme.regularFont(14)
        view.adjustsImageWhenHighlighted = false
        view.touchDownBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onTouchedRecordingArea?(self)
        }
        view.touchDragBlock = { [weak self] btn, inside in
            guard let self = self else {
                return
            }
            self.onTouchingRecordingAreaAndDrag?(self, !inside)
        }
        view.touchUpBlock = { [weak self] btn, inside in
            guard let self = self else {
                return
            }
            self.onTouchUpRecordingArea?(self, inside)
        }
        return view
    }()
    
    fileprivate lazy var rightBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_text"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_stop"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            if btn.isSelected {
                self.onClickedStop?(self)
            }
            else {
                self.onClickedSelectedText?(self)
            }
        }
        return btn
    }()
    
    fileprivate var onClickedSelectedText: ((_ sender: AUIAIChatInputAudioView) -> Void)? = nil
    fileprivate var isStopped: Bool = false {
        didSet {
            self.rightBtn.isSelected = self.isStopped
            self.placeholderView.isEnabled = !self.isStopped
        }
    }
    fileprivate var onClickedStop: ((_ sender: AUIAIChatInputAudioView) -> Void)? = nil
    
    public var onTouchedRecordingArea: ((_ sender: AUIAIChatInputAudioView) -> Void)? = nil
    public var onTouchingRecordingAreaAndDrag: ((_ sender: AUIAIChatInputAudioView,_ isExit: Bool) -> Void)? = nil
    public var onTouchUpRecordingArea: ((_ sender: AUIAIChatInputAudioView,_ isInside: Bool) -> Void)? = nil

}
