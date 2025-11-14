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
        
        self.backgroundColor = AUIAIChatBundle.color_bg_elevated
        self.addSubview(self.topLineView)
        self.addSubview(self.dragLineView)
        self.addSubview(self.inputContainer)
        self.inputContainer.addSubview(self.addBtn)
        self.inputContainer.addSubview(self.textView)
        self.inputContainer.addSubview(self.audioView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topLineView.frame = CGRect(x: 0, y: 0, width: self.av_width, height: 1)
        self.dragLineView.frame = CGRect(x: 0, y: 8, width: 26, height: 3)
        self.dragLineView.av_centerX = self.av_width / 2.0
        
        self.inputContainer.frame = CGRect(x: 24, y: 16 + self.dragLineView.av_bottom, width: self.av_width - 48, height: 50)
        
        self.addBtn.frame = CGRect(x: 8, y: 0, width: 40, height: 50)

        let left = self.addBtn.av_right
        let width = self.inputContainer.av_width - left
        self.textView.frame = CGRect(x: left, y: 0, width: width, height: 50)
        self.audioView.frame = CGRect(x: left, y: 0, width: width, height: 50)
    }
    
    open lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAIChatBundle.color_border_tertiary
        return view
    }()
    
    open lazy var dragLineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = AUIAIChatBundle.color_fill_quaternary
        return view
    }()
    
    open lazy var inputContainer: UIView = {
        let btn = UIView()
        btn.backgroundColor = AUIAIChatBundle.color_fill_secondary
        btn.av_setLayerBorderColor(AUIAIChatBundle.color_border_secondary)
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()
    
    open lazy var addBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_add"), for: .normal)
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_add_selected"), for: .selected)
        btn.tintColor = AUIAIChatBundle.color_icon
        btn.clickBlock = { [weak self] btn in
            if btn.isSelected {
                self?.reset()
            }
            else {
                self?.isAudioMode = false
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
            self.reset()
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
        }
    }
    open var onClickedStop: ((_ sender: AUIAIChatBottomView) -> Void)? = nil
    
    
    
    // ==========================展开状态处理==========================
     
    open var enableCall: Bool = true
    
    open lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        return scrollView
    }()
    
    open lazy var voiceCallBtn: AUIAIChatMenuButton = {
        let btn = AUIAIChatMenuButton()
        btn.titleLabel.text = AUIAIChatBundle.getString("Voice Call")
        btn.imageView.image = AUIAIChatBundle.getTemplateImage("ic_call_voice")
        btn.av_size = CGSize(width: 86, height: 86)
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var avatarCallBtn: AUIAIChatMenuButton = {
        let btn = AUIAIChatMenuButton()
        btn.titleLabel.text = AUIAIChatBundle.getString("Avatar Call")
        btn.imageView.image = AUIAIChatBundle.getTemplateImage("ic_call_avatar")
        btn.av_size = CGSize(width: 86, height: 86)
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var visionCallBtn: AUIAIChatMenuButton = {
        let btn = AUIAIChatMenuButton()
        btn.titleLabel.text = AUIAIChatBundle.getString("Vision Call")
        btn.imageView.image = AUIAIChatBundle.getTemplateImage("ic_call_vision")
        btn.av_size = CGSize(width: 86, height: 86)
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var videoCallBtn: AUIAIChatMenuButton = {
        let btn = AUIAIChatMenuButton()
        btn.titleLabel.text = AUIAIChatBundle.getString("Video Call")
        btn.imageView.image = AUIAIChatBundle.getTemplateImage("ic_call_video")
        btn.av_size = CGSize(width: 86, height: 86)
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    open lazy var addPhotoBtn: AUIAIChatMenuButton = {
        let btn = AUIAIChatMenuButton()
        btn.titleLabel.text = AUIAIChatBundle.getString("Album")
        btn.imageView.image = AUIAIChatBundle.getTemplateImage("ic_photo_picker")
        btn.av_size = CGSize(width: 86, height: 86)
        self.scrollView.addSubview(btn)
        return btn
    }()
    
    var expandHeight: CGFloat {
        get {
            let height = 8 + 3 + 8 + 66 + 8 + 86 + 16 + UIView.av_safeBottom
            return height
        }
    }

    func expand() {
        guard self.addBtn.isSelected == false else {
            return
        }
        
        let margin = 9.0
        self.addPhotoBtn.av_left = 24.0
        self.voiceCallBtn.av_left = self.addPhotoBtn.av_right + margin
        self.avatarCallBtn.av_left = self.voiceCallBtn.av_right + margin
        self.visionCallBtn.av_left = self.avatarCallBtn.av_right + margin
        self.videoCallBtn.av_left = self.visionCallBtn.av_right + margin

        self.addPhotoBtn.isHidden = false
        self.voiceCallBtn.isHidden = self.enableCall ? false : true
        self.avatarCallBtn.isHidden = self.enableCall ? false : true
        self.visionCallBtn.isHidden = self.enableCall ? false : true
        self.videoCallBtn.isHidden = self.enableCall ? false : true
        
        self.scrollView.frame = CGRect(x: 0, y: self.inputContainer.av_bottom + 16, width: self.av_width, height: 86)
        self.scrollView.contentSize = CGSize(width: self.enableCall ? self.videoCallBtn.av_right + 24.0 : self.addPhotoBtn.av_right + 24.0, height: 86)

        UIView.animate(withDuration: 0.25) {
            let bot = self.av_bottom
            let height = self.expandHeight
            self.av_height = height
            self.av_bottom = bot
        }
        self.addBtn.isSelected = true
    }
    
    var normalHeight: CGFloat {
        get {
            let height = 8 + 3 + 8 + 66 + UIView.av_safeBottom
            return height
        }
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
            let height = self.normalHeight
            self.av_height = height
            self.av_bottom = bot
        }
        self.addBtn.isSelected = false
    }
}

@objcMembers open class AUIAIChatInputTextView: UIView {
    
    public init() {
        super.init(frame: CGRect.zero)
        
        self.addSubview(self.placeholderView)
        self.addSubview(self.rightBtn)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rightBtn.frame = CGRect(x: self.av_width - 40 - 6, y: 0, width: 40, height: self.av_height)
        self.placeholderView.frame = CGRect(x: 0, y: 0, width: self.rightBtn.av_left - 6, height: self.av_height)
    }
    
    fileprivate lazy var placeholderView: AVBlockButton = {
        let view = AVBlockButton()
        view.contentHorizontalAlignment = .left
        view.setTitle(AUIAIChatBundle.getString("Please enter content"), for: .normal)
        view.setTitleColor(AUIAIChatBundle.color_text_tertiary, for: .normal)
        view.titleLabel?.font = AVTheme.regularFont(16)
        view.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onClickedInputText?(self)
        }
        return view
    }()
    
    fileprivate lazy var rightBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_audio"), for: .normal)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_stop"), for: .selected)
        btn.tintColor = AUIAIChatBundle.color_icon
        btn.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            if btn.isSelected {
                self.onClickedStop?(self)
            }
            else {
                self.onClickedSelectedAudio?(self)
            }
        }
        return btn
    }()
    
    fileprivate var onClickedSelectedAudio: ((_ sender: AUIAIChatInputTextView) -> Void)? = nil
    fileprivate var isStopped: Bool = false {
        didSet {
            self.rightBtn.isSelected = self.isStopped
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
        
        self.addSubview(self.placeholderView)
        self.addSubview(self.rightBtn)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rightBtn.frame = CGRect(x: self.av_width - 40 - 6, y: 0, width: 40, height: self.av_height)
        self.placeholderView.frame = CGRect(x: 0, y: 0, width: self.rightBtn.av_left, height: self.av_height)
    }
    
    fileprivate lazy var placeholderView: AUIAICallDragButton = {
        let view = AUIAICallDragButton()
        view.contentHorizontalAlignment = .center
        view.setTitle(AUIAIChatBundle.getString("Press and hold to speak"), for: .normal)
        view.setTitleColor(AUIAIChatBundle.color_text, for: .normal)
        view.setTitleColor(AUIAIChatBundle.color_text_disabled, for: .disabled)
        view.titleLabel?.font = AVTheme.mediumFont(16)
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
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_text"), for: .normal)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_stop"), for: .selected)
        btn.tintColor = AUIAIChatBundle.color_icon
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


@objcMembers open class AUIAIChatMenuButton: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = AUIAIChatBundle.color_fill_secondary
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 1
        self.av_setLayerBorderColor(AUIAIChatBundle.color_border_secondary)
        self.layer.masksToBounds = true
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = CGRect(x: 30, y: 16, width: 26, height: 26)
        self.titleLabel.frame = CGRect(x: 0, y: self.imageView.av_bottom + 8, width: self.av_width, height: 20)
    }
    
    open lazy var imageView: UIImageView = {
        let img = UIImageView()
        img.tintColor =  AUIAIChatBundle.color_icon
        return img
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12.0)
        label.textColor = AUIAIChatBundle.color_text
        label.textAlignment = .center
        return label
    }()
    
    open var tappedAction: ((_ btn: AUIAIChatMenuButton)->Void)? = nil
    
    @objc open func onTapped() {
        self.tappedAction?(self)
    }
}
