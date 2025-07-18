//
//  AUIAICallCusAgentContentView.swift
//  Pods
//
//  Created by Bingo on 2025/6/20.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallCusAgentContentView: UIView, UITextFieldDelegate {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.scanBtn)
        self.addSubview(self.inputField)
        self.addSubview(self.lineView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var titleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 0, y: 16, width: self.av_width, height: 24))
        title.text = AUIAIMainBundle.getString("Authorized AI Agent")
        title.textColor = AVTheme.text_strong
        title.font = AVTheme.regularFont(14)
        return title
    }()
    
    open lazy var scanBtn: AVBlockButton = {
        let scan = AVBlockButton(frame: CGRect(x: self.av_width - 24, y: self.titleLabel.av_bottom + 2, width: 24, height: 42))
        scan.setImage(AUIAIMainBundle.getImage("ic_scan"), for: .normal)
        return scan
    }()
    
    open lazy var inputField: UITextField = {
        let input = UITextField(frame: CGRect(x: 0, y: self.titleLabel.av_bottom + 2, width: self.av_width - 24 , height: 42))
        input.textColor = AVTheme.text_strong
        input.keyboardType = .default
        input.returnKeyType = .done
        input.delegate = self
        let placeholderText = AUIAIMainBundle.getString("Please Scan Code to Get Authorized Token")
        let placeholderColor = AVTheme.text_ultraweak
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor,
            .font: AVTheme.regularFont(14)
        ]
        input.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return input
    }()
    
    open lazy var lineView: UIView = {
        let line = UIView(frame: CGRect(x: 0, y: self.inputField.av_bottom, width: self.av_width, height: 1))
        line.backgroundColor = AVTheme.border_weak
        return line
    }()
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if self.inputField.isFirstResponder && view != self.inputField {
            self.inputField.resignFirstResponder()
        }
        return view
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}
