//
//  AUIAICallAgentAvatarAnimator.swift
//  AUIAICall
//
//  Created by Bingo on 2024/12/12.
//

import UIKit
import ARTCAICallKit
import Lottie


@objcMembers open class AUIAICallAgentAvatarAnimator: AUIAICallAgentAnimator {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.bgView)
        self.addSubview(self.startCallAni)
        self.addSubview(self.onCallingAni)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let length = 540.0
        self.bgView.frame = CGRect(x: 0, y: 0, width: 180.0, height: 180.0)
        self.bgView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY - 32)
        self.startCallAni.frame = CGRect(x: 0, y: 0, width: length, height: length)
        self.startCallAni.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        self.onCallingAni.frame = self.self.startCallAni.frame
    }
    
    open override func updateState(newState: AUIAICallState) {
        let isLoading = newState == .Connecting || newState == .None
        let showOnCall = !isLoading && self.isStartAniCompleted
        self.startCallAni.isHidden = showOnCall
        self.onCallingAni.isHidden = !showOnCall
        
        if isLoading {
            self.startCallAni.startAni()
        }
        
        if newState == .Connected {
            self.onCallingAni.setEyeAnimatorType(type: .Listening)
            self.onCallingAni.startAni()
        }
        else if newState == .Error {
            self.onCallingAni.setEyeAnimatorType(type: .Error)
            if self.onCallingAni.isStartAni == false {
                self.onCallingAni.startAni()
            }
        }
        else if newState == .Over {
            self.onCallingAni.pauseAni()
        }
        else {
            self.onCallingAni.setEyeAnimatorType(type: .Start)
            self.onCallingAni.startAni()
        }
    }
    
    open override func updateAgentAnimator(state: ARTCAICallAgentState) {
        if state == .Listening {
            self.onCallingAni.setEyeAnimatorType(type: .Listening)
        }
        else if state == .Speaking {
            self.onCallingAni.setEyeAnimatorType(type: .Speaking)
        }
        else if state == .Thinking {
            self.onCallingAni.setEyeAnimatorType(type: .Thinking)
        }
    }
    
    open override func onAgentInterrupted() {
        self.onCallingAni.setEyeAnimatorType(type: .Interrupting)
    }
    
    open override func updateAgentAnimator(emotion: String) {
        if emotion == "happy" {
            self.onCallingAni.setEyeAnimatorType(type: .HappySpeaking)
        }
        else if emotion == "sad" {
            self.onCallingAni.setEyeAnimatorType(type: .SadSpeaking)
        }
    }
    
    open lazy var bgView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(contentsOfFile: AUIAICallBundle.getResourceFullPath("Avatar/bg.png"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    open lazy var startCallAni: AUIAICallStartCallAnimator = {
        let view = AUIAICallStartCallAnimator()
        view.isHidden = true
        view.completedBlock = { [weak self] in
            guard let self = self else { return }
            self.startCallAni.isHidden = true
            self.onCallingAni.isHidden = false
            self.isStartAniCompleted = true
        }
        return view
    }()
    
    open lazy var onCallingAni: AUIAICallOnCallingAnimator = {
        let view = AUIAICallOnCallingAnimator()
        view.isHidden = true
        return view
    }()
    
    private var isStartAniCompleted: Bool = false
}


@objcMembers open class AUIAICallStartCallAnimator: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.enterAnimator?.frame = self.bounds
    }
    
    private lazy var enterAnimator: LottieAnimationView? = nil
    open private(set) var isStartAni: Bool = false
    open var completedBlock: (() -> Void)? = nil

    private func createAnimator(path: String, loop: Bool) -> LottieAnimationView {
        let filePath = AUIAICallBundle.getResourceFullPath("Avatar" + path)
        let animator = LottieAnimationView(filePath: filePath)
        animator.contentMode = .scaleAspectFit
        animator.loopMode = loop ? .loop : .playOnce
        animator.animationSpeed = 1.0
        return animator
    }
    
    public func startAni() {
        if self.isStartAni {
            return
        }
        self.isStartAni = true
        self.enterAnimator = self.createAnimator(path: "/Enter/Enter.json", loop: false)
        self.addSubview(self.enterAnimator!)
        self.setNeedsLayout()
        self.enterAnimator?.play(completion: { [weak self] completed in
            self?.stopAni()
            self?.completedBlock?()
        })
    }
    
    private func stopAni() {
        self.isStartAni = false
        self.enterAnimator?.removeFromSuperview()
        self.enterAnimator = nil
    }
}


@objcMembers open class AUIAICallOnCallingAnimator: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.headAnimator)
        self.addSubview(self.eyeAnimatorContainerView)
        self.addSubview(self.handAnimator)
        
        self.eyeAnimatorContainerView.addSubview(self.eyeAnimator)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("deinit: \(self)")
        self.stopAni()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.headAnimator.frame = self.bounds
        self.handAnimator.frame = self.bounds
        self.interruptAnimator?.frame = self.bounds

        self.eyeAnimatorContainerView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width)
        self.eyeAnimatorContainerView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY + 9)
        self.eyeAnimator.frame = self.eyeAnimatorContainerView.bounds
    }
    
    private func createAnimator(path: String, loop: Bool) -> LottieAnimationView {
        let filePath = AUIAICallBundle.getResourceFullPath("Avatar" + path)
        let animator = LottieAnimationView(filePath: filePath)
        animator.contentMode = .scaleAspectFit
        // 如果lottie资源支持autoreverse，请使用autoReverse进行循环，这样可以减少lottie资源加载的内存
        animator.loopMode = loop ? .autoReverse : .repeatBackwards(1.0)
        animator.animationSpeed = 1.0
        return animator
    }
    
    private lazy var headAnimator: LottieAnimationView = {
        return self.createAnimator(path: "/Head/Head.json", loop: true)
    }()
    
    private lazy var handAnimator: LottieAnimationView = {
        return self.createAnimator(path: "/Hand/Hand.json", loop: true)
    }()
    
    private lazy var interruptAnimator: LottieAnimationView? = nil

    private lazy var eyeAnimator: LottieAnimationView = {
        return LottieAnimationView()
    }()
    
    private lazy var nextEyeAnimator: LottieAnimationView? = nil

    
    private lazy var eyeAnimatorContainerView: UIView = {
        let view = UIView()
        // view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    open private(set) var isStartAni: Bool = false
    private var isPlayingAni: Bool = false
    
    private var timer: Timer? = nil
    private let eyeOffset: CGFloat = 10
    private let frameCount: CGFloat = 40
    private var hadBegin: Bool = true
    
    open func startAni() {
        if self.isStartAni {
            return
        }
        self.isStartAni = true
        if self.currEyeAnimatorType == .None {
            if let nextEyeAnimator = self.nextEyeAnimator {
                
                self.eyeAnimator.stop()
                self.eyeAnimator.removeFromSuperview()
                
                nextEyeAnimator.frame = self.eyeAnimatorContainerView.bounds
                self.eyeAnimatorContainerView.addSubview(nextEyeAnimator)
                
                self.eyeAnimator = nextEyeAnimator
                self.currEyeAnimatorType = self.nextEyeAnimatorType
                debugPrint("Start Animator Type: \(self.currEyeAnimatorType)")
            }
        }
        self.playAni()
    }
    
    open func stopAni() {
        self.headAnimator.stop()
        self.handAnimator.stop()
        self.eyeAnimator.stop()
        self.interruptAnimator?.stop()
        self.timer?.invalidate()
        
        self.isStartAni = false
    }
    
    open func playAni() {
        
        if self.isPlayingAni {
            return
        }
        self.isPlayingAni = true
        
        self.headAnimator.play()
        self.handAnimator.play()
        self.eyeAnimator.play()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1 / self.frameCount, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            // 获取播放进度（范围为 0 到 1）
            let progress = self.headAnimator.realtimeAnimationProgress
            let y = self.eyeOffset * (progress - 1.0)
            // print("CurrentFrame: \(self.headAnimator.realtimeAnimationFrame) Progress: \(progress)    offset: \(y)")
            self.eyeAnimatorContainerView.transform = CGAffineTransform(translationX: 0, y: y)
            
            // 每一次动画开始时
            let isBegin = 1 / self.frameCount
            if self.hadBegin == false && progress <= isBegin  {
                self.hadBegin = true
                // print("CurrentFrame: isBegin")
                if self.nextEyeAnimatorType != .None {
                    self.startNextEyeAnimator(type: self.nextEyeAnimatorType)
                    if self.currEyeAnimatorType == .Interrupting {
                        // 打断状态结束后，切换为聆听状态
                        self.nextEyeAnimatorType = .Listening
                    }
                    else {
                        self.nextEyeAnimatorType = .None
                    }
                }
            }
            if progress > 0.9 {
                self.hadBegin = false
            }
        }
    }
    
    open func pauseAni() {
        guard self.isPlayingAni else {
            return
        }
        self.isPlayingAni = false
        
        self.headAnimator.pause()
        self.handAnimator.pause()
        self.eyeAnimator.pause()
        self.interruptAnimator?.pause()
        self.timer?.invalidate()
    }
    
    @objc private func applicationWillResignActive() {
        self.pauseAni()
    }
    
    @objc private func applicationDidBecomeActive() {
        if self.isStartAni {
            self.playAni()
        }
    }
    
    
    
    @objc public enum EyeAnimator: Int32 {
        case None                 // 非动画场景
        case Start                // 智能体启动
        case Error                // 智能体出错
        case Interrupting         // 智能体被打断
        case Thinking             // 智能体思考中，或者加载中
        case Listening            // 智能体聆听中
        case Speaking             // 智能体讲话中（自然形态）
        case HappySpeaking        // 智能体讲话中（开心形态）
        case SadSpeaking          // 智能体讲话中（伤心形态）
    }

    
    private var currEyeAnimatorType: EyeAnimator = .None
    private var nextEyeAnimatorType: EyeAnimator = .None
    
    private func startNextEyeAnimator(type: EyeAnimator) {
        
        guard let animator = self.createEyeAnimator(type: type) else {
            return
        }
        
        self.eyeAnimator.stop()
        self.eyeAnimator.removeFromSuperview()
        
        animator.frame = self.eyeAnimatorContainerView.bounds
        animator.play()
        self.eyeAnimatorContainerView.addSubview(animator)
        
        self.eyeAnimator = animator
        self.currEyeAnimatorType = type
        debugPrint("Start Animator Type: \(self.currEyeAnimatorType)")
        
        self.handAnimator.isHidden = false
        self.interruptAnimator?.removeFromSuperview()
        self.interruptAnimator = nil
        if self.currEyeAnimatorType == .Interrupting || self.currEyeAnimatorType == .Error  {
            self.handAnimator.isHidden = true
            self.interruptAnimator = self.createAnimator(path: "/CoveringEyes/CoveringEyes.json", loop: self.currEyeAnimatorType == .Error ? false : true)
            self.addSubview(self.interruptAnimator!)
            self.interruptAnimator?.play()
        }
    }

    private func createEyeAnimator(type: EyeAnimator) -> LottieAnimationView? {
        var path = ""
        switch type {
        case .None:
            return nil
        case .Thinking:
            path = "/EyeEmotions/Thinking/Thinking.json"
            break
        case .Listening:
            path = "/EyeEmotions/Listening/Listening.json"
            break
        case .Interrupting:
            path = "/EyeEmotions/Interrupting/Interrupting.json"
            break
        case .Speaking:
            path = "/EyeEmotions/Speaking/Speaking.json"
            break
        case .HappySpeaking:
            path = "/EyeEmotions/Happy/Happy.json"
            break
        case .SadSpeaking:
            path = "/EyeEmotions/Sad/Sad.json"
            break
        case .Start:
            path = "/EyeEmotions/Thinking/Thinking.json"
            break
        case .Error:
            path = "/EyeEmotions/Interrupting/Interrupting.json"
            break
        }
        return self.createAnimator(path: path, loop: true)
    }

    open func setEyeAnimatorType(type: EyeAnimator) {
        debugPrint("Will Set Animator Type Curr: \(self.currEyeAnimatorType) To: \(type)")
        if type == .None {
            return
        }
        if self.currEyeAnimatorType == type {
            return
        }
        if self.currEyeAnimatorType == .Error {
            // 出错时最终状态，不能切换
            return
        }
        if self.nextEyeAnimatorType == .Interrupting || self.nextEyeAnimatorType == .Error {
            // 如果下一个是打断状态，不能打断
            return
        }
        if self.currEyeAnimatorType == .Interrupting {
            // 当前打断状态，不能打断，需要等继续执行完成
            if type == .Speaking && self.nextEyeAnimatorType.rawValue > type.rawValue {
                // 下一个是带表情状态讲话时，下一个不能切换为自然状态讲话
                return
            }
            self.nextEyeAnimatorType = type
            return
        }
        if type == .Speaking && self.currEyeAnimatorType.rawValue > type.rawValue {
            // 当前是带表情状态讲话时，不能切换为自然状态讲话
            return
        }
        if type == .Interrupting || type == .Error {
            // 下一个是打断状态或错误状态，需要等当前执行完成
            self.nextEyeAnimatorType = type
            return
        }
        debugPrint("Set Animator Type Next: \(type) Curr: \(self.currEyeAnimatorType)")
        self.startNextEyeAnimator(type: type)
    }
}
