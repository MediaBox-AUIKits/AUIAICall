//
//  AUIAICallImmerseBottomView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallImmerseBottomView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(self.gradientLayer)
        self.addSubview(self.timeLabel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        return layer
    }()
    
    open lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.av_width, height: 22))
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.regularFont(14)
        return label
    }()
}
