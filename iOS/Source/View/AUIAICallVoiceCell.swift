//
//  AUIAICallVoiceCell.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallVoiceItem: NSObject {
    open var voiceId: String = ""
    open var voiceName: String = ""
    open var icon: String = ""
}

@objcMembers open class AUIAICallVoiceCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(self.iconView)
        self.addSubview(self.applyBtn)
        self.addSubview(self.appliedIcon)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconView.frame = CGRect(x: 20, y: (self.av_height - 32) / 2, width: 32, height: 32)
        
        self.applyBtn.sizeToFit()
        let width = self.applyBtn.av_width + 24
        self.applyBtn.frame = CGRect(x: self.av_width - width - 20, y: (self.av_height - 22) / 2, width: width, height: 22)
        self.appliedIcon.frame = self.applyBtn.frame
        
        self.titleLabel.frame = CGRect(x: self.iconView.av_right + 12, y: 0, width: self.applyBtn.av_left - self.iconView.av_right - 12 - 12, height: self.av_height)
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(12)
        label.textColor = AVTheme.text_strong
        return label
    }()
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = AVTheme.border_weak.cgColor
        return view
    }()
    
    
    open lazy var applyBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.layer.cornerRadius = 11
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = AVTheme.regularFont(12)
        btn.setImage(nil, for: .normal)
        btn.setBorderColor(AVTheme.border_strong, for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setTitle(AUIAICallBundle.getString("Use"), for: .normal)
        btn.isHidden = false
        return btn
    }()
    
    open lazy var appliedIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = AUIAICallBundle.getCommonImage("ic_sound_apply")
        view.isHidden = true
        return view
    }()
    
    open var item: AUIAICallVoiceItem? {
        didSet {
            self.titleLabel.text = self.item?.voiceName
            self.iconView.image = AUIAICallBundle.getImage(self.item?.icon)
        }
    }
    
    open var isApplied: Bool = false {
        didSet {
            self.applyBtn.isHidden = self.isApplied
            self.appliedIcon.isHidden = !self.isApplied
        }
    }
}
