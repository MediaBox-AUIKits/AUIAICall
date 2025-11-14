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
        
        self.backgroundColor = AUIAICallBundle.color_fill_tertiary
        self.layer.cornerRadius = 2
        self.layer.borderWidth = 1
        self.av_setLayerBorderColor(AUIAICallBundle.color_border_secondary)
        self.layer.masksToBounds = true
        
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
        
        self.iconView.frame = CGRect(x: 16, y: (self.av_height - 32) / 2, width: 32, height: 32)
        
        self.applyBtn.sizeToFit()
        let width = self.applyBtn.av_width + 32
        self.applyBtn.frame = CGRect(x: self.av_width - width, y: (self.av_height - 22) / 2, width: width, height: 22)
        self.appliedIcon.frame = self.applyBtn.frame
        
        self.titleLabel.frame = CGRect(x: self.iconView.av_right + 16, y: 0, width: self.applyBtn.av_left - self.iconView.av_right - 16, height: self.av_height)
    }
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AVTheme.regularFont(14)
        label.textColor = AUIAICallBundle.color_text_secondary
        return label
    }()
    
    open lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    
    open lazy var applyBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.titleLabel?.font = AVTheme.regularFont(14)
        btn.setTitleColor(AUIAICallBundle.color_text, for: .normal)
        btn.setTitle(AUIAICallBundle.getString("Use"), for: .normal)
        btn.isHidden = false
        return btn
    }()
    
    open lazy var appliedIcon: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = AUIAICallBundle.getCommonImage("ic_voiceid_apply")
        view.isHidden = true
        return view
    }()
    
    open var item: AUIAICallVoiceItem? {
        didSet {
            self.titleLabel.text = self.item?.voiceName
            self.iconView.image = AUIAICallBundle.getCommonImage(self.item?.icon)
        }
    }
    
    open var isApplied: Bool = false {
        didSet {
            self.av_setLayerBorderColor(self.isApplied ? AUIAICallBundle.color_border_selection : AUIAICallBundle.color_border_secondary)
            self.titleLabel.textColor = self.isApplied ? AUIAICallBundle.color_text_selection : AUIAICallBundle.color_text_secondary
            self.applyBtn.isHidden = self.isApplied
            self.appliedIcon.isHidden = !self.isApplied
        }
    }
}
