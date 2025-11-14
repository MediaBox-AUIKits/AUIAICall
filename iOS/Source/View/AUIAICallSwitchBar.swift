//
//  AUIAICallSwitchBar.swift
//  AUIAICall
//
//  Created by Bingo on 2025/9/8.
//

import UIKit
import AUIFoundation


@objcMembers open class AUIAICallSwitchBar: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.infoLabel)
        self.addSubview(self.switchBtn)
        self.switchBtn.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var ch = 24.0 + 20.0 + 8.0
        if self.infoLabel.isHidden {
            ch = 24
        }
        let y = (self.av_height - ch) / 2.0
        self.titleLabel.frame = CGRect(x: 0, y: y, width: self.av_width - self.switchBtn.av_width - 8, height: 24)
        self.switchBtn.center = CGPoint(x: self.av_width - self.switchBtn.av_width / 2.0, y: self.titleLabel.av_centerY)
        self.infoLabel.frame = CGRect(x: 0, y: self.titleLabel.av_bottom + 8, width: self.av_width, height: 20)
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(16.0)
        label.textColor = AUIAICallBundle.color_text
        return label
    }()
    
    open lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12.0)
        label.textColor = AUIAICallBundle.color_text_tertiary
        return label
    }()
    
    open lazy var switchBtn: UISwitch = {
        let btn = UISwitch()
        btn.onTintColor = AUIAICallBundle.color_primary
        btn.tintColor = AUIAICallBundle.color_fill_quaternary
        btn.thumbTintColor = AUIAICallBundle.color_fill_switch_identical
        return btn
    }()
    
    open var onSwitchValueChangedBlock: ((_ bar: AUIAICallSwitchBar) -> Void)? = nil
    
    @objc func onSwitchValueChanged() {
        self.onSwitchValueChangedBlock?(self)
    }
}
