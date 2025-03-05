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
        self.addSubview(self.callBtn)
        self.addSubview(self.textView)
        self.addSubview(self.audioView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.callBtn.frame = CGRect(x: self.av_width - 40 - 14, y: 14, width: 40, height: 40)
        var right = self.callBtn.av_left - 6
        if self.callBtn.isHidden {
            right = self.av_width - 20.0
        }
        
        self.textView.frame = CGRect(x: 20, y: 14, width: right - 20.0, height: 40)
        self.audioView.frame = CGRect(x: 20, y: 14, width: right - 20.0, height: 40)
    }
    
    open lazy var callBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_call"), for: .normal)
        return btn
    }()

    open lazy var textView: AUIAIChatInputTextView = {
        let view = AUIAIChatInputTextView()
        view.onClickedSelectedAudio = {[weak self] textView in
            guard let self = self else {
                return
            }
            self.audioView.isHidden = false
            self.textView.isHidden = true
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
            self.audioView.isHidden = true
            self.textView.isHidden = false
        }
        view.onClickedStop = {[weak self] sender in
            guard let self = self else {
                return
            }
            self.onClickedStop?(self)
        }
        return view
    }()
    
    open var isStopped: Bool = false {
        didSet {
            self.audioView.isStopped = self.isStopped
            self.textView.isStopped = self.isStopped
        }
    }
    open var onClickedStop: ((_ sender: AUIAIChatBottomView) -> Void)? = nil

}

@objcMembers open class AUIAIChatInputTextView: UIView {
    
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
    
    fileprivate lazy var rightBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_audio"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_stop"), for: .selected)
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
    
    fileprivate lazy var placeholderView: AVBlockButton = {
        let view = AVBlockButton()
        view.contentHorizontalAlignment = .center
        view.setTitle(AUIAIChatBundle.getString("Press and hold to speak"), for: .normal)
        view.setTitleColor(AVTheme.text_strong, for: .normal)
        view.setTitleColor(AVTheme.text_ultraweak, for: .disabled)
        view.titleLabel?.font = AVTheme.regularFont(14)
        view.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
        }
        view.touchDownBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onTouchedRecordingArea?(self)
        }
        view.touchDragEnterBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onTouchingRecordingAreaAndDrag?(self, false)
        }
        view.touchDragExitBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onTouchingRecordingAreaAndDrag?(self, true)
        }
        view.touchUpInsideBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onTouchUpRecordingArea?(self, true)
        }
        view.touchUpOutsideBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.onTouchUpRecordingArea?(self, false)
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
