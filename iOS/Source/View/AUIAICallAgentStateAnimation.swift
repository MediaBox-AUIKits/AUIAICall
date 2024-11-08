//
//  AUIAICallAgentStateAnimation.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallAgentStateAnimation: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.listeningAniView)
        self.addSubview(self.thinkingAniView)
        self.addSubview(self.speakingAniView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.listeningAniView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
        self.thinkingAniView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
        self.speakingAniView.center = CGPoint(x: self.av_width / 2.0, y: self.av_height / 2.0)
    }
        
    open lazy var listeningAniView: AUIAICallListeningAniView = {
        let view = AUIAICallListeningAniView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.isHidden = false
        return view
    }()
    
    open lazy var thinkingAniView: AUIAICallThinkingAniView = {
        let view = AUIAICallThinkingAniView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.isHidden = true
        return view
    }()
    
    open lazy var speakingAniView: AUIAICallSpeakingAniView = {
        let view = AUIAICallSpeakingAniView(frame: CGRect(x: 0, y: 0, width: 250, height: 200))
        view.isHidden = true
        return view
    }()
    
    
    open func updateAgentState(newState: ARTCAICallAgentState) {
        if self.agentState == newState {
            return
        }
        
        debugPrint("AUIAICallAgentStateAnimation: updateAgentState:\(newState)")
        let oldState = self.agentState
        self.agentState = newState
        self.listeningAniView.isHidden = self.agentState != .Listening
        self.thinkingAniView.isHidden = self.agentState != .Thinking
        self.speakingAniView.isHidden = self.agentState != .Speaking
        
        var pre = false
        if oldState == .Listening && newState == .Thinking {
            pre = true
        }
        else if oldState == .Thinking && newState == .Speaking {
            pre = true
        }
        
        if self.isAni {
            self.start(pre)
        }
    }
    
    private var agentState: ARTCAICallAgentState = .Listening
    
    open private(set) var isAni: Bool = false
    
    open func start(_ pre: Bool = false) {
        self.stop()
        
//        debugPrint("AUIAICallAgentStateAnimation: start ani")
        self.isAni = true
        if self.listeningAniView.isHidden == false {
            self.listeningAniView.start()
        }
        if self.thinkingAniView.isHidden == false {
            self.thinkingAniView.start(pre: pre)
        }
        if self.speakingAniView.isHidden == false {
            self.speakingAniView.start(pre: pre)
        }
    }
    
    open func stop() {
//        debugPrint("AUIAICallAgentStateAnimation: stop ani")
        self.isAni = false
        
        self.listeningAniView.stop()
        self.thinkingAniView.stop()
        self.speakingAniView.stop()
    }
    
}


@objcMembers open class AUIAICallListeningAniView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.listeningImg)
        self.addSubview(self.speakingAniView)
        self.updateLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var listeningImg: UIImageView = {
        let view = UIImageView()
        view.image = AUIAICallBundle.getCommonImage("ic_agent_state_listening")
        return view
    }()
    
    private lazy var speakingAniView: AUIAICallSpeakingAniView = {
        let view = AUIAICallSpeakingAniView(frame: CGRect(x: 0, y: 0, width: 100, height: 22), isMin: true)
        view.center = CGPoint(x: self.av_width / 2.0, y: self.av_height - 22.0 / 2.0)
        view.isHidden = true
        return view
    }()
    
    private var isAni: Bool = false
    
    public var isSpeaking: Bool = false {
        didSet {
            self.speakingAniView.isHidden = !self.isSpeaking
            if self.isAni && self.isSpeaking {
                self.speakingAniView.start(pre: false)
            }
            else {
                self.speakingAniView.stop()
            }
        }
    }
    
    private func updateLayout() {
        self.listeningImg.frame = CGRect(x: 0, y: 0, width: 153, height: 153)
        self.listeningImg.center = CGPoint(x: self.av_width / 2.0, y: 153.0 / 2.0)
    }
    
    func start() {
//        debugPrint("AUIAICallListeningAniView start")
        self.isAni = true
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.byValue = CGFloat.pi * 2  // 旋转 360 度
        rotationAnimation.duration = 3.0              // 完成一次旋转的时间
        rotationAnimation.repeatCount = .infinity   // 重复无限次数
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .both
        self.listeningImg.layer.add(rotationAnimation, forKey: nil)
        if self.isSpeaking == true {
            self.speakingAniView.start(pre:false)
        }
    }
    
    func stop() {
//        debugPrint("AUIAICallListeningAniView stop")
        self.isAni = false
        self.listeningImg.layer.removeAllAnimations()
        self.speakingAniView.stop()
    }
}

@objcMembers open class AUIAICallThinkingAniView: UIView {
    
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
            view.layer.cornerRadius = 20
            view.layer.masksToBounds = true
            list.append(view)
        }
        return list
    }()
    
    
    private func updateLayout() {
        
        let circle = Double(self.barViews.count)
        let circle_height = 32.0
        let circle_margin = 18.0
        let circle_midY = self.av_height / 2.0
        let circle_startX = (self.av_width - circle_height * circle - circle_margin * (circle - 1.0)) / 2.0
        
        for i in 0..<self.barViews.count {
            let view = self.barViews[i]
            view.layer.cornerRadius = circle_height / 2.0
            view.frame = CGRect(x: circle_startX + Double(i) * (circle_height + circle_margin), y: circle_midY - circle_height / 2.0, width: circle_height, height: circle_height)
        }
    }
    
    private func loadingAni() {
        let t = 0.2
        for i in 0..<self.barViews.count {
            let view = self.barViews[i]
            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.values = [1.0, 42.0 / 32.0, 1.0, 1.0] // 缩放属性的起始值，中间值和结束值
            
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
    
    private var isAni: Bool = false
    
    func start(pre: Bool) {
        
//        debugPrint("AUIAICallThinkingAniView start")
        self.isAni = true
        if pre == false {
            self.loadingAni()
            return
        }
        
        var list = [UIView]()
        for i in 0..<self.barViews.count {
            let view = UIImageView()
            view.image = AUIAICallBundle.getCommonImage("ic_agent_state_listening")
            view.frame = CGRect(x: 0, y: 0, width: 153, height: 153)
            view.center = CGPoint(x: self.av_width / 2.0, y: 153.0 / 2.0)
            self.addSubview(view)
            list.append(view)
            
            self.barViews[i].isHidden = true
        }
        
        UIView.animate(withDuration: 0.5) {
            for i in 0..<self.barViews.count {
                list[i].center = self.barViews[i].center
                list[i].transform = CGAffineTransform(scaleX: 32.0 / 153.0, y: 32.0 / 153.0)
            }
            
        } completion: { com in
            for i in 0..<self.barViews.count {
                self.barViews[i].isHidden = false
                list[i].removeFromSuperview()
            }
            
            if self.isAni {
                self.loadingAni()
            }
        }
    }
    func stop() {
        
//        debugPrint("AUIAICallThinkingAniView stop")
        self.isAni = false
        self.barViews.forEach { view in
            view.layer.removeAllAnimations()
        }
    }
}

@objcMembers open class AUIAICallSpeakingAniView: UIView {
    
    public init(frame: CGRect, isMin: Bool) {
        self.isMin = isMin
        super.init(frame: frame)
        
        self.barViews.forEach { view in
            self.addSubview(view)
        }
        self.updateLayout()
    }
    
    public override convenience init(frame: CGRect) {
        self.init(frame: frame, isMin: false)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var barViews: [UIView] = {
        var list = [UIView]()
        let count = 10
        for i in 0..<count {
            let view = UIView()
            view.backgroundColor = AVTheme.fill_infrared
            view.layer.cornerRadius = self.isMin ? 4.0 : 8.0
            view.layer.masksToBounds = true
            list.append(view)
        }
        return list
    }()
    
    
    private func updateLayout() {
        
        let bar = Double(self.barViews.count)
        let bar_height = self.isMin ? 6.0 : 16.0
        let bar_margin = self.isMin ? 4.0 : 10.0
        let bar_midY = self.av_height / 2.0
        let bar_startX = (self.av_width - bar_height * bar - bar_margin * (bar - 1.0)) / 2.0
        
        for i in 0..<self.barViews.count {
            let view = self.barViews[i]
            view.layer.cornerRadius = bar_height / 2.0
            view.frame = CGRect(x: bar_startX + Double(i) * (bar_height + bar_margin), y: bar_midY - bar_height / 2.0, width: bar_height, height: bar_height)
        }
    }
    
    private let isMin: Bool
    private var isAni: Bool = false
    
    private func growAni(view: UIView) {
        let bar_height = self.isMin ? 6.0 : 16.0
        let max_height = self.isMin ? 22.0 : 80.0
        let bar_bottom = self.av_height / 2.0 + bar_height / 2.0
        let growH = Double(arc4random() % UInt32(max_height - bar_height))
        let time = (Double(arc4random() % 100) / 1000.0 + 0.4) / 2.0
        UIView.animate(withDuration: time, delay: 0.0, options: [.curveEaseOut], animations: {
            // 改变高度的动画
            view.av_height = growH + bar_height
            view.av_bottom = bar_bottom
        }) { finished in
            UIView.animate(withDuration: time, delay: 0.0, options: [.curveEaseOut]) {
                view.av_height = bar_height
                view.av_bottom = bar_bottom
            } completion: { finished in
                if self.isAni {
                    self.growAni(view: view)
                }
            }
        }
    }
    
    private func createPreViews() -> [UIView] {
        var list = [UIView]()
        let count = self.barViews.count
        for _ in 0..<count {
            let view = UIView()
            view.backgroundColor = AVTheme.fill_infrared
            view.layer.cornerRadius = 20
            view.layer.masksToBounds = true
            list.append(view)
        }
        
        let circle = Double(3)
        let circle_height = 32.0
        let circle_margin = 18.0
        let circle_midY = self.av_height / 2.0
        let circle_startX = (self.av_width - circle_height * circle - circle_margin * (circle - 1.0)) / 2.0
        
        for i in 0..<list.count {
            let view = list[i]
            var index = 1
            if i < 3 {
                index = 0
            }
            else if i > 6 {
                index = 2
            }
            view.layer.cornerRadius = circle_height / 2.0
            view.frame = CGRect(x: circle_startX + Double(index) * (circle_height + circle_margin), y: circle_midY - circle_height / 2.0, width: circle_height, height: circle_height)
            self.addSubview(view)
        }
        
        
        
        return list
    }
    
    func start(pre: Bool) {
//        debugPrint("AUIAICallSpeakingAniView start")
        self.isAni = true
        
        if pre == false {
            self.barViews.forEach { view in
                self.growAni(view: view)
            }
            return
        }
        
        let preViews = self.createPreViews()
        for i in 0..<self.barViews.count {
            self.barViews[i].isHidden = true
        }
        
        UIView.animate(withDuration: 0.5) {
            for i in 0..<self.barViews.count {
                preViews[i].center = self.barViews[i].center
                preViews[i].transform = CGAffineTransform(scaleX: 16.0 / 32.0, y: 16.0 / 32.0)
            }
            
        } completion: { com in
            for i in 0..<self.barViews.count {
                self.barViews[i].isHidden = false
                preViews[i].removeFromSuperview()
                
                if self.isAni {
                    self.growAni(view: self.barViews[i])
                }
            }
        }
    }
    
    func stop() {
//        debugPrint("AUIAICallSpeakingAniView stop")
        self.isAni = false
        self.barViews.forEach { view in
            view.layer.removeAllAnimations()
        }
    }
    
}
