//
//  AUIAIChatEditingTextView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation
import ARTCAICallKit


@objcMembers open class AUIAIChatEditingTextView: UIView {
    
    public init() {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = AVTheme.bg_weak

        self.addSubview(self.sendingBar)
        self.addSubview(self.inputAudioView)
        self.addSubview(self.inputTextView)
        self.addSubview(self.sendBtn)
        self.addSubview(self.rightBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let sendAttachmentsViewTop = self.av_height - self.getBottomEdge() - self.getAttachmentHeight()
        self.sendAttachmentsView?.frame = CGRect(x: 0, y: sendAttachmentsViewTop, width: self.av_width, height: self.getAttachmentHeight())
        
        self.rightBtn.frame = CGRect(x: self.av_right - 40 - 14, y: sendAttachmentsViewTop - 14 - 40, width: 40, height: 40)

        let sendingBarHeight = sendAttachmentsViewTop - 24
        let sendingBarWidth = self.rightBtn.isHidden ? self.av_width - 20 - 20 : self.rightBtn.av_left - 6 - 20
        self.sendingBar.frame = CGRect(x: 20, y: 14, width: sendingBarWidth, height: sendingBarHeight)
        self.sendBtn.frame = CGRect(x: self.sendingBar.av_right - 40 - 6, y: self.sendingBar.av_bottom - 40, width: 40, height: 40)
        
        let inputTextViewX = self.sendingBar.av_left + 12
        let inputTextViewWidth = self.sendBtn.av_left - 6 - inputTextViewX
        self.inputTextView.frame = CGRect(x: inputTextViewX, y: self.sendingBar.av_top, width: inputTextViewWidth, height: self.sendingBar.av_height)
        self.inputAudioView.frame = self.sendingBar.frame
    }
    
    public private(set) var viewOnShow: Bool = false
    
    open lazy var sendingBar: UIView = {
        let view = UIView()
        view.backgroundColor = AVTheme.fg_strong
        view.layer.cornerRadius = 20
        return view
    }()
    
    open lazy var inputTextView: UITextView = {
        let view = UITextView()
        view.backgroundColor = UIColor.clear
        view.textColor = AVTheme.text_strong
        view.font = AVTheme.regularFont(14)
        view.returnKeyType = .default
        view.delegate = self
        return view
    }()
    
    open lazy var inputAudioView: AUIAICallDragButton = {
        let view = AUIAICallDragButton()
        view.contentHorizontalAlignment = .center
        view.setTitle(AUIAIChatBundle.getString("Press and hold to speak"), for: .normal)
        view.setTitleColor(AVTheme.text_strong, for: .normal)
        view.setTitleColor(AVTheme.text_ultraweak, for: .disabled)
        view.titleLabel?.font = AVTheme.regularFont(14)
        view.isHidden = true
//        view.isEnabled = false
        return view
    }()
    
    fileprivate lazy var rightBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getImage("ic_audio"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_text"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.isAudioMode = !self.isAudioMode
        }
        return btn
    }()
    
    open var sendAttachmentsView: AUIAIChatSendAttachmentView? = nil {
        willSet {
            self.sendAttachmentsView?.willAddItemBlock = nil
            self.sendAttachmentsView?.willRemoveItemBlock = nil
            self.sendAttachmentsView?.allUploadSuccessBlock = nil
            self.sendAttachmentsView?.removeFromSuperview()
            self.enableSendBtn = true
            self.inputAudioView.isEnabled = true
        }
        didSet {
            if let sendAttachmentsView = self.sendAttachmentsView {
                sendAttachmentsView.frame = CGRect(x: 0, y: 68, width: 0, height: self.getAttachmentHeight())
                self.addSubview(sendAttachmentsView)
                
                self.enableSendBtn = sendAttachmentsView.allUploadSuccess
                self.inputAudioView.isEnabled = sendAttachmentsView.allUploadSuccess
                sendAttachmentsView.allUploadSuccessBlock = { [weak self]  allUploadSuccess in
                    self?.enableSendBtn = allUploadSuccess
                    self?.inputAudioView.isEnabled = allUploadSuccess
                }
            }
        }
    }
    
    private var translateY: CGFloat = 0
    open var onPositionYChangedBlock: ((_ value: CGFloat) -> Void)? = nil
    open var onInputTextChangedBlock: ((_ text: String?) -> Void)? = nil
    open var onSendBlock: ((_ text: String) -> Void)? = nil
    open var isStopped: Bool = false {
        didSet {
            self.sendBtn.isSelected = self.isStopped
        }
    }
    open var onClickedStop: (() -> Void)? = nil
    open var isAudioMode: Bool = false {
        didSet {
            self.rightBtn.isSelected = self.isAudioMode
            self.inputAudioView.isHidden = !self.rightBtn.isSelected
            self.inputTextView.isHidden = self.rightBtn.isSelected
            self.sendBtn.isHidden = self.rightBtn.isSelected
            
            if self.isAudioMode {
                let height = self.getDefaultHeight()
                let bottom = self.av_bottom
                self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
                self.onPositionYChangedBlock?(self.translateY - self.av_height)
            }
            else {
                let height = self.getCurrentHeight()
                let bottom = self.av_bottom
                self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
                self.onPositionYChangedBlock?(self.translateY - self.av_height)
            }
        }
    }

    open lazy var sendBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_send"), for: .normal)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_send_disabled"), for: .disabled)
        btn.setImage(AUIAIChatBundle.getImage("ic_stop"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            if btn.isSelected {
                self?.onClickedStop?()
                return
            }
            let text = self?.inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self?.onSendBlock?(text)
            self?.inputTextView.text = ""
            self?.inputTextView.resignFirstResponder()
        }
        return btn
    }()
    
    private var enableSendBtn: Bool = true {
        didSet {
            if self.enableSendBtn {
                self.sendBtn.setImage(AUIAIChatBundle.getCommonImage("ic_send"), for: .normal)
            }
            else {
                self.sendBtn.setImage(AUIAIChatBundle.getCommonImage("ic_send_disabled"), for: .normal)
            }
        }
    }
    
    open lazy var clickedBgView: AVBlockButton = {
        let view = AVBlockButton(frame: .zero)
        view.isHidden = true
        view.clickBlock = { [weak self] btn in
            guard let self = self else {return}
            if self.inputTextView.isFirstResponder {
                self.inputTextView.resignFirstResponder()
            }
        }
        
        return view
    }()
}

extension AUIAIChatEditingTextView {
    
    open func getBottomEdge() -> CGFloat {
        return UIView.av_safeBottom
    }
    
    open func getAttachmentHeight() -> CGFloat {
        if self.sendAttachmentsView != nil {
            return 90.0
        }
        return 0.0
    }
    
    open func getSendingBarHeight() -> CGFloat {
        return 68.0
    }
    
    open func getDefaultHeight() -> CGFloat {
        return self.getSendingBarHeight() + self.getAttachmentHeight() + self.getBottomEdge()
    }
    
    open func getCurrentHeight() -> CGFloat {
        var inputHeight = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.av_width, height: 0)).height
        inputHeight = max(inputHeight, 40)
        inputHeight = min(inputHeight, 5 * 22)
        let sendingBarHeight = inputHeight + 28.0
        return sendingBarHeight + self.getAttachmentHeight() + self.getBottomEdge()
    }
    
    open func presentOnView(parent: UIView, isAudioMode: Bool, isEditing: Bool) {
        self.isAudioMode = isAudioMode
        self.rightBtn.isHidden = self.sendAttachmentsView == nil
        self.inputTextView.text = self.inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let height = self.getDefaultHeight()
        self.frame = CGRect(x: 0, y: parent.av_height - height, width: parent.av_width, height: height)
        parent.addSubview(self)
        self.onPositionYChangedBlock?(self.translateY - self.av_height)
        if isEditing && self.isAudioMode == false {
            self.inputTextView.becomeFirstResponder()
        }
        self.viewOnShow = true
    }
    
    open func dismiss() {
        self.sendAttachmentsView = nil
        self.tryToDismiss()
    }
    
    private func tryToDismiss() {
        if self.sendAttachmentsView == nil {
            self.onPositionYChangedBlock?(self.translateY)
            self.removeFromSuperview()
            self.viewOnShow = false
        }
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        if (!self.inputTextView.isFirstResponder) {
            return;
        }
        
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            
            self.clickedBgView.frame = self.superview?.bounds ?? .zero
            self.superview?.insertSubview(self.clickedBgView, belowSubview: self)
            self.clickedBgView.isHidden = false
            
            self.backgroundColor = .clear
            self.sendAttachmentsView?.backgroundColor = AVTheme.bg_weak
            self.rightBtn.isHidden = true
            self.setNeedsLayout()
            let translateY = -keyboardFrame.cgRectValue.height + self.getBottomEdge()
            self.transform = CGAffineTransform(translationX: 0, y: translateY)
            self.translateY = translateY
            debugPrint("AUIAIChatEditingTextView translateY: \(self.translateY)")
            self.textViewDidChange(self.inputTextView)
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        
        self.clickedBgView.isHidden = true
        
        self.backgroundColor = AVTheme.bg_weak
        self.sendAttachmentsView?.backgroundColor = AVTheme.bg_weak
        self.rightBtn.isHidden = self.sendAttachmentsView == nil
        self.setNeedsLayout()
        self.transform = .identity
        self.tryToDismiss()
        self.translateY = 0
        debugPrint("AUIAIChatEditingTextView translateY: \(self.translateY)")
        self.onPositionYChangedBlock?(self.viewOnShow ? self.translateY - self.av_height : self.translateY)
    }
}

extension AUIAIChatEditingTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        let height = self.getCurrentHeight()
        let bottom = self.av_bottom
        self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
        self.onPositionYChangedBlock?(self.translateY - self.av_height)
        self.onInputTextChangedBlock?(self.inputTextView.text)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            /*
            if let text = self.inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty == false {
                self.onSendBlock?(text)
            }
            self.inputTextView.resignFirstResponder()
            return false
             */
        }
        return true
    }
}
