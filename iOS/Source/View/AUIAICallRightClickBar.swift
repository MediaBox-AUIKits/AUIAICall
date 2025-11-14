//
//  AUIAICallRightClickBar.swift
//  AUIAICall
//
//  Created by Bingo on 2025/9/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallRightClickBar: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.rightImageView)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rightImageView.sizeToFit()
        self.rightImageView.av_centerY = self.av_height / 2.0
        self.rightImageView.av_right = self.av_width
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: self.rightImageView.av_left - 8.0, height: self.av_height)
    }
    
    open override func sizeToFit() {
        super.sizeToFit()
        
        self.titleLabel.sizeToFit()
        self.rightImageView.sizeToFit()
        
        self.av_size = CGSize(width: self.titleLabel.av_width + 8.0 + self.rightImageView.av_width, height: max(self.titleLabel.av_height, self.rightImageView.av_height))
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = AUIAICallBundle.color_text
        label.font = AVTheme.regularFont(16)
        return label
    }()
    
    open lazy var rightImageView: UIImageView = {
        let view = UIImageView(frame: CGRect.zero)
        view.image = AUIAICallBundle.getTemplateImage("ic_right")
        view.tintColor = AUIAICallBundle.color_icon
        return view
    }()
    
    open var tappedAction: ((_ btn: AUIAICallRightClickBar)->Void)? = nil
    
    @objc open func onTapped() {
        self.tappedAction?(self)
    }
}
