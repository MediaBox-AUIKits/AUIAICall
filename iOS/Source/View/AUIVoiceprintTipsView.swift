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
        
        self.backgroundColor = AUIAICallBundle.color_fill_toast_identical
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.av_setLayerBorderColor(AUIAICallBundle.color_border_identical)
        self.layer.masksToBounds = true

        self.addSubview(self.textLabel)
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

        var width = self.textLabel.av_width + 24
        if width > frame.width {
            width = frame.width
        }
        self.textLabel.av_left = 12
        self.textLabel.av_height = 40
        self.av_size = CGSize(width: width, height: 40)
        self.center = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    open lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = AUIAICallBundle.color_text
        label.font = AVTheme.regularFont(12)
        label.text = AUIAICallBundle.getString("Detected other speaking, stop responded this question.")
        label.numberOfLines = 0
        return label
    }()
    
}
