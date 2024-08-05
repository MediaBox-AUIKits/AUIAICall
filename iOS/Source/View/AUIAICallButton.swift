//
//  AUIAICallButton.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallButton: UIView {

    public override init(frame: CGRect) {
        self.isSelected = false
        super.init(frame: frame)
        
        self.addSubview(self.imageBgView)
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.isSelected = false
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageBgView.frame = CGRect(x: 0, y: 0, width: self.av_width, height: self.av_width)
        self.imageBgView.layer.cornerRadius = self.imageBgView.av_width / 2.0
        self.imageBgView.layer.masksToBounds = true
        self.imageView.frame = CGRect(x: 12, y: 12, width: self.av_width - 12 * 2, height: self.av_width - 12 * 2)
        
        self.titleLabel.sizeToFit()
        let width = max(self.av_width, self.titleLabel.av_width)
        self.titleLabel.frame = CGRect(x: (self.av_width - width) / 2.0, y: self.imageBgView.av_bottom + 8.0, width: width, height: 18.0)
    }
    
    open var selectedTitle: String? = nil
    open var normalTitle: String? = nil
    open var selectedImage: UIImage? = nil
    open var normalImage: UIImage? = nil
    open var isSelected: Bool {
        didSet {
            self.imageView.image = self.isSelected ? self.selectedImage : self.normalImage
            self.titleLabel.text = self.isSelected ? self.selectedTitle : self.normalTitle
            self.setNeedsLayout()
        }
    }
    
    open lazy var imageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    open lazy var imageBgView: UIView = {
        let bg = UIView()
        return bg
    }()
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12.0)
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        return label
    }()
    
    open var tappedAction: ((_ btn: AUIAICallButton)->Void)? = nil
    
    @objc open func onTapped() {
        self.tappedAction?(self)
    }
}

extension AUIAICallButton {
    
    public static func create(title: String?, iconBgColor: UIColor?, normalIcon: UIImage?, selectedTitle: String? = nil, selectedIcon: UIImage? = nil) -> AUIAICallButton {
        let btn = AUIAICallButton()
        btn.imageBgView.backgroundColor = iconBgColor
        btn.normalTitle = title
        btn.selectedTitle = selectedTitle
        btn.normalImage = normalIcon
        btn.selectedImage = selectedIcon
        btn.isSelected = false
        return btn
    }
    
}
