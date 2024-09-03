//
//  AUIAICallStateAnimation.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallStateAnimation: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.loadingAniView)
        self.addSubview(self.errorView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.loadingAniView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
        self.errorView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
    }
    
    open lazy var loadingAniView: AUIAICallConnectingAniView = {
        let view = AUIAICallConnectingAniView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.isHidden = true
        return view
    }()
    
    open lazy var errorView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.image = AUIAICallBundle.getCommonImage("ic_error")
        view.contentMode = .center
        view.isHidden = true
        return view
    }()
    
    
    open func updateState(newState: AUIAICallState) {
        if self.state == newState {
            return
        }
        
        debugPrint("AUIAICallStateAnimation: updateState:\(newState)")
        self.state = newState
        self.loadingAniView.isHidden = !(self.state == .Connecting || self.state == .None)
        self.errorView.isHidden = self.state != .Error

        if self.isAni {
            self.start()
        }
    }
    
    open private(set) var state: AUIAICallState = .None
    
    open private(set) var isAni: Bool = false
    
    open func start() {
        self.stop()
        
        debugPrint("AUIAICallStateAnimation: start ani")
        self.isAni = true
        if self.loadingAniView.isHidden == false {
            self.loadingAniView.start()
        }
    }
    
    open func stop() {
        debugPrint("AUIAICallStateAnimation: stop ani")
        self.isAni = false
        
        self.loadingAniView.stop()
    }
    
}

@objcMembers open class AUIAICallConnectingAniView: UIView {
    
    public override init(frame: CGRect) {
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
            view.layer.cornerRadius = 10
            view.layer.masksToBounds = true
            list.append(view)
        }
        return list
    }()
    
    
    private func updateLayout() {
        
        let circle = Double(self.barViews.count)
        let circle_height = 20.0
        let circle_margin = 16.0
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
            animation.values = [1.0, 30.0 / 20.0, 1.0, 1.0] // 缩放属性的起始值，中间值和结束值
            
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
