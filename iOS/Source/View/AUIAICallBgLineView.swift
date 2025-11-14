//
//  AUIAICallBgLineView.swift
//  AUIAICall
//
//  Created by Bingo on 2025/9/18.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallBgLineView: UIView {
    
    public init(frame: CGRect, gradient: Bool) {
        super.init(frame: frame)
        
        let midView = self.createLineView(gradient: gradient)
        midView.av_centerX = self.av_width / 2.0
        self.addSubview(midView)
        
        let margin = 84.0
        var start = midView.av_centerX - margin
        while start > 0 {
            let line = self.createLineView(gradient: gradient)
            line.av_centerX = start
            self.addSubview(line)
            start = line.av_centerX - margin
        }
        
        start = midView.av_centerX + margin
        while start < self.av_width {
            let line = self.createLineView(gradient: gradient)
            line.av_centerX = start
            self.addSubview(line)
            start = line.av_centerX + margin
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        var lineColor = AUIAIMainBundle.color_border_tertiary
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                lineColor = lineColor.withAlphaComponent(0.9)
            }
        }
        self.lineViewInfos.forEach { (view, layer) in
            if let grad = layer as? CAGradientLayer {
                grad.colors = [lineColor.cgColor, lineColor.withAlphaComponent(0.0).cgColor]
            }
            else {
                layer.backgroundColor = lineColor.cgColor
            }
        }
    }
    
    var lineViewInfos = [(UIView, CALayer)]()
    
    func createLineView(gradient: Bool) -> UIView {
        let line = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: self.av_height))

        if gradient {
            let layer = CAGradientLayer()
            layer.startPoint = CGPoint(x: 0.5, y: 0.64)
            layer.endPoint = CGPoint(x: 0.5, y: 1.0)
            layer.colors = [AUIAIMainBundle.color_border_tertiary.cgColor, AUIAIMainBundle.color_border_tertiary.withAlphaComponent(0.0).cgColor]
            layer.frame = line.bounds
            line.layer.addSublayer(layer)
            self.lineViewInfos.append((line, layer))
        }
        else {
            line.layer.backgroundColor = AUIAIMainBundle.color_border_tertiary.cgColor
            self.lineViewInfos.append((line, line.layer))
        }

        return line
    }
}
