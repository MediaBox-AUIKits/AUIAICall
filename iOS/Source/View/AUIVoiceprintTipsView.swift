//
//  AUIVoiceprintTipsView.swift
//  AUIAICall
//
//  Created by Bingo on 2025/5/6.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIVoiceprintTipsView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.textLabel)
        self.addSubview(self.clearBtn)
        self.isHidden = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func showTips() {
        self.isHidden = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTips(_:)), object: nil)
        self.perform(#selector(hideTips(_:)), with: nil, afterDelay: 8)
    }
    
    open func hideTips() {
        self.isHidden = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTips(_:)), object: nil)
    }
    
    @objc func hideTips(_ myObject: Any?) {
        self.isHidden = true
    }
    
    open func layoutAt(frame: CGRect) {
        self.textLabel.sizeToFit()
        self.clearBtn.sizeToFit()
        self.clearBtn.av_size = CGSize(width: self.clearBtn.av_width + 18, height: 18)

        var width = self.textLabel.av_width + self.clearBtn.av_width + 24
        if width > frame.width {
            width = frame.width
        }
        self.textLabel.av_left = 8
        self.textLabel.av_height = 40
        self.clearBtn.av_left = self.textLabel.av_right + 8
        self.clearBtn.av_centerY = 20
        self.av_size = CGSize(width: self.clearBtn.av_right + 8, height: 40)
        self.center = CGPoint(x: frame.midX, y: frame.midY)
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
    }
    
    open var isSelected = false {
        didSet {
            if self.isSelected {
                self.backgroundColor = UIColor.av_color(withHexString: "#868686")
            }
            else {
                self.backgroundColor = UIColor.clear
            }
        }
    }
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.font = AVTheme.regularFont(12)
        label.text = AUIAICallBundle.getString("Detected other speaking, stop responded this question.")
        label.numberOfLines = 0
        return label
    }()
    
    
    open lazy var clearBtn: AVBlockButton = {
        let btn = AVBlockButton()
        btn.setTitle(AUIAICallBundle.getString("Restore"), for: .normal)
        btn.setTitleColor(AVTheme.text_strong, for: .normal)
        btn.setBorderColor(AVTheme.colourful_border_strong, for: .normal)
        btn.titleLabel?.font = AVTheme.regularFont(10)
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 9
        return btn
    }()
}
