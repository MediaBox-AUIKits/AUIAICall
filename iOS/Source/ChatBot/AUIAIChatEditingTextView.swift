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
        
        self.addSubview(self.bgView)
        self.addSubview(self.inputTextView)
        self.addSubview(self.sendBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bgView.frame = self.bounds
        self.sendBtn.frame = CGRect(x: self.av_width - 40 - 6, y: self.av_height - 40, width: 40, height: 40)
        self.inputTextView.frame = CGRect(x: 12, y: 0, width: self.sendBtn.av_left - 6, height: self.av_height)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if !(view == self.inputTextView || view == self.sendBtn) {
            if self.inputTextView.isFirstResponder {
                self.inputTextView.resignFirstResponder()
            }
        }
        
        return view
    }
    
    open lazy var bgView: UIView = {
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

    open lazy var sendBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setImage(AUIAIChatBundle.getCommonImage("ic_send"), for: .normal)
        btn.setImage(AUIAIChatBundle.getImage("ic_stop"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            if btn.isSelected {
                self?.onClickedStop?()
                return
            }
            if let text = self?.inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty == false {
                self?.onSendBlock?(text)
                self?.inputTextView.text = ""
            }
            self?.inputTextView.resignFirstResponder()
        }
        return btn
    }()
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        if (!self.inputTextView.isFirstResponder) {
            return;
        }
        
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let translateY = -keyboardFrame.cgRectValue.height
            self.transform = CGAffineTransform(translationX: 0, y: translateY)
            self.translateY = translateY
            debugPrint("AUIAIChatEditingTextView translateY: \(self.translateY)")
            self.textViewDidChange(self.inputTextView)
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        self.transform = .identity
        self.removeFromSuperview()
        self.translateY = 0
        debugPrint("AUIAIChatEditingTextView translateY: \(self.translateY)")
        self.onPositionYChangedBlock?(0)
    }
}

extension AUIAIChatEditingTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        
        var height = self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.av_width, height: 0)).height
        height = max(height, 40)
        height = min(height, 5 * 22)
        let bottom = self.av_bottom
        self.frame = CGRect(x: self.av_left, y: bottom - height, width: self.av_width, height: height)
        self.onPositionYChangedBlock?(self.translateY - (height - 40))
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
