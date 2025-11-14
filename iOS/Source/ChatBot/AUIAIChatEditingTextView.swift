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
        
        self.backgroundColor = AUIAIChatBundle.color_bg_elevated
        self.addSubview(self.topLineView)
        self.addSubview(self.dragLineView)
        
        self.addSubview(self.sendingBar)
        self.addSubview(self.inputAudioView)
        self.addSubview(self.placeholderView)
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
        
        self.topLineView.frame = CGRect(x: 0, y: 0, width: self.av_width, height: 1)
        self.dragLineView.frame = CGRect(x: 0, y: 8, width: 26, height: 3)
        self.dragLineView.av_centerX = self.av_width / 2.0
        
        let sendAttachmentsViewTop = self.av_height - self.getBottomEdge() - self.getAttachmentHeight()
        self.sendAttachmentsView?.frame = CGRect(x: 0, y: sendAttachmentsViewTop, width: self.av_width, height: self.getAttachmentHeight())
        
        let y = 20.0 + 8.0
        let sendingBarHeight = sendAttachmentsViewTop - y - 8
        let sendingBarWidth = self.av_width - 24 - 24
        self.sendingBar.frame = CGRect(x: 24, y: y, width: sendingBarWidth, height: sendingBarHeight)
        
        self.rightBtn.frame = CGRect(x: self.sendingBar.av_right - 40 - 8, y: self.sendingBar.av_bottom - 40 - 5, width: 40, height: 40)
        self.sendBtn.frame = self.rightBtn.frame

        let inputTextViewX = self.sendingBar.av_left + 16
        let inputTextViewWidth = self.sendBtn.av_left - 6 - inputTextViewX
        let inputTextViewHeight = self.sendingBar.av_height
        let inputTextViewY = self.sendingBar.av_top
        self.inputTextView.frame = CGRect(x: inputTextViewX, y: inputTextViewY, width: inputTextViewWidth, height: inputTextViewHeight)
        self.placeholderView.frame = self.inputTextView.frame
        self.inputAudioView.frame = CGRect(x: self.sendingBar.av_left, y: self.sendingBar.av_top, width: self.sendingBar.av_width, height: self.sendingBar.av_height)
    }
    
    public private(set) var viewOnShow: Bool = false
    
    open lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAIChatBundle.color_border_tertiary
        return view
    }()
    
    open lazy var dragLineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = AUIAIChatBundle.color_fill_tertiary
        return view
    }()
    
    open lazy var sendingBar: UIView = {
        let view = UIView()
        view.backgroundColor = AUIAIChatBundle.color_fill_secondary
        view.av_setLayerBorderColor(AUIAIChatBundle.color_border_secondary)
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    open lazy var placeholderView: AVBlockButton = {
        let view = AVBlockButton()
        view.contentHorizontalAlignment = .left
        view.setTitle(AUIAIChatBundle.getString("Please enter content"), for: .normal)
        view.setTitleColor(AUIAIChatBundle.color_text_tertiary, for: .normal)
        view.titleLabel?.font = AVTheme.regularFont(16)
        view.clickBlock = { [weak self] btn in
            guard let self = self else {
                return
            }
            self.inputTextView.becomeFirstResponder()
        }
        return view
    }()
    
    open lazy var inputTextView: UITextView = {
        let view = UITextView()
        view.textContainerInset = UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0)
        view.backgroundColor = UIColor.clear
        view.textColor = AUIAIChatBundle.color_text
        view.font = AVTheme.regularFont(16)
        view.returnKeyType = .default
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    open lazy var inputAudioView: AUIAICallDragButton = {
        let view = AUIAICallDragButton()
        view.contentHorizontalAlignment = .center
        view.setTitle(AUIAIChatBundle.getString("Press and hold to speak"), for: .normal)
        view.setTitleColor(AUIAIChatBundle.color_text, for: .normal)
        view.setTitleColor(AUIAIChatBundle.color_text_disabled, for: .disabled)
        view.titleLabel?.font = AVTheme.mediumFont(16)
        view.isHidden = true
//        view.isEnabled = false
        return view
    }()
    
    fileprivate lazy var rightBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_audio"), for: .normal)
        btn.setImage(AUIAIChatBundle.getTemplateImage("ic_text"), for: .selected)
        btn.tintColor = AUIAIChatBundle.color_icon
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
                sendAttachmentsView.frame = CGRect(x: 0, y: self.getSendingBarHeight(), width: 0, height: self.getAttachmentHeight())
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
            self.inputAudioView.isHidden = !self.isAudioMode
            self.placeholderView.isHidden = self.isAudioMode
        }
    }

    open lazy var sendBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_send"), for: .normal)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_send_disabled"), for: .disabled)
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_stop"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            if btn.isSelected {
                self?.onClickedStop?()
                return
            }
            let text = self?.inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self?.onSendBlock?(text)
            self?.inputTextView.text = ""
            self?.inputTextView.resignFirstResponder()
            self?.updatePlaceholderText(text: "")
        }
        btn.isHidden = true
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
            return 94.0
        }
        return 0.0
    }
    
    open func getSendingBarHeight() -> CGFloat {
        return 86.0
    }
    
    open func getDefaultHeight() -> CGFloat {
        return self.getSendingBarHeight() + self.getAttachmentHeight() + self.getBottomEdge()
    }
    
    open func getActiveHeight() -> CGFloat {
        var inputHeight = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.av_width, height: 0)).height
        inputHeight = min(inputHeight, 5 * 24)
        let sendingBarHeight = max(20 + 8 + inputHeight + 8, self.getSendingBarHeight())
        return sendingBarHeight + self.getAttachmentHeight() + self.getBottomEdge()
    }
    
    open func presentOnView(parent: UIView, isAudioMode: Bool, isEditing: Bool) {
        self.isAudioMode = isAudioMode
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
            
            self.sendBtn.isHidden = false
            self.rightBtn.isHidden = true
            self.inputTextView.isHidden = false
            self.placeholderView.isHidden = true
            
            self.transform = .identity
            let height = self.getDefaultHeight()
            let bottom = self.av_bottom
            self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
            
            let translateY = -keyboardFrame.cgRectValue.height + self.getBottomEdge()
            self.transform = CGAffineTransform(translationX: 0, y: translateY)
            self.translateY = translateY
            debugPrint("AUIAIChatEditingTextView translateY: \(self.translateY)")
            self.textViewDidChange(self.inputTextView)
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        
        self.clickedBgView.isHidden = true
        
        self.sendBtn.isHidden = true
        self.rightBtn.isHidden = false
        self.inputTextView.isHidden = true
        self.placeholderView.isHidden = false
        
        self.transform = .identity
        let height = self.getDefaultHeight()
        let bottom = self.av_bottom
        self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
        
        self.tryToDismiss()
        self.translateY = 0
        debugPrint("AUIAIChatEditingTextView translateY: \(self.translateY)")
        self.onPositionYChangedBlock?(self.viewOnShow ? self.translateY - self.av_height : self.translateY)
    }
    
    public func updatePlaceholderText(text: String?) {
        if let text = text, text.isEmpty == false {
            self.placeholderView.setTitle(text, for: .normal)
        }
        else {
            self.placeholderView.setTitle(AUIAIChatBundle.getString("Please enter content"), for: .normal)
        }
    }
}

extension AUIAIChatEditingTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        let height = self.getActiveHeight()
        let bottom = self.av_bottom
        self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
        self.updatePlaceholderText(text: self.inputTextView.text)
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
