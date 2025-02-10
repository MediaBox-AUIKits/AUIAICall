//
//  AUIAICallLoadingAnimator.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import AUIFoundation


@objcMembers open class AUIAICallLoadingAnimator: UIView {
    
    public init(frame: CGRect, length: CGFloat = 20.0, margin: CGFloat = 16.0) {
        self.circleLength = length
        self.circleMargin = margin
        super.init(frame: frame)
        
        self.barViews.forEach { view in
            self.addSubview(view)
        }
        self.updateLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var barViews: [UIView] = {
        var list = [UIView]()
        let count = 3
        for i in 0..<count {
            let view = UIView()
            view.backgroundColor = AVTheme.fill_infrared
            view.layer.cornerRadius = self.circleLength / 2.0
            view.layer.masksToBounds = true
            list.append(view)
        }
        return list
    }()
    
    private let circleLength: CGFloat
    private let circleMargin: CGFloat
    
    private func updateLayout() {
        
        let circle = Double(self.barViews.count)
        let circle_height = self.circleLength
        let circle_margin = self.circleMargin
        let circle_midY = self.av_height / 2.0
        let circle_startX = (self.av_width - circle_height * circle - circle_margin * (circle - 1.0)) / 2.0
        
        for i in 0..<self.barViews.count {
            let view = self.barViews[i]
            view.layer.cornerRadius = circle_height / 2.0
            view.frame = CGRect(x: circle_startX + Double(i) * (circle_height + circle_margin), y: circle_midY - circle_height / 2.0, width: circle_height, height: circle_height)
        }
    }

    private var isAni: Bool = false
    
    func start() {
        self.isAni = true
        let t = 0.2
        for i in 0..<self.barViews.count {
            let view = self.barViews[i]
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [1.0, 1.5, 1.0, 1.0] // 缩放属性的起始值，中间值和结束值
            
            // 设置每个关键帧持续的时间比例
            let scaleDuration = t
            let pauseDuration = 2 * t + 0.1
            let totalDuration = scaleDuration + scaleDuration + pauseDuration
            animation.keyTimes = [0.0, NSNumber(value: scaleDuration / totalDuration), NSNumber(value: scaleDuration * 2 / totalDuration), 1.0]

            // 设置总时长，包含放大缩小的时间和暂停时间
            animation.duration = totalDuration
            animation.repeatCount = .infinity
            animation.beginTime = CACurrentMediaTime() + scaleDuration * Double(i)
            animation.isRemovedOnCompletion = false
            view.layer.add(animation, forKey: nil)
        }
    }
    func stop() {
        self.isAni = false
        self.barViews.forEach { view in
            view.layer.removeAllAnimations()
        }
    }
}
