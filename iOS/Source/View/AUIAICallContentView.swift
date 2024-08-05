//
//  AUIAICallContentView.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallContentView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.addSublayer(self.gradientlayer)
        self.addSubview(self.tipsLabel)
        self.addSubview(self.robotStateAni)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradientlayer.frame = CGRect(x: 0, y: self.av_height - 300, width: self.av_width, height: 300)
        
        let hei = self.av_bottom - 228 - 18
        self.robotStateAni.frame = CGRect(x: 0, y: UIView.av_safeTop + 44, width: self.av_width, height: hei - UIView.av_safeTop - 44)
        
        self.tipsLabel.frame = CGRect(x: 0, y: hei, width: self.av_width, height: 18)
    }
        
    open lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.regularFont(14)
        label.text = ""
        return label
    }()
    
    open lazy var gradientlayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        return layer
    }()
    
    open lazy var robotStateAni: AUIAICallRobotStateAnimation = {
        let view = AUIAICallRobotStateAnimation()
        return view
    }()
}
