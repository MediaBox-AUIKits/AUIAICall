//
//  AUIAICallViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation
import ARTCAICallKit

@objcMembers open class AUIAICallViewController: UIViewController {
    
    public init(_ controller: AUIAICallControllerInterface) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit: \(self)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = AVTheme.bg_medium
        
        self.titleLabel.frame = CGRect(x: 0, y: UIView.av_safeTop, width: self.view.av_width, height: 44)
        self.titleLabel.text = self.controller.config.agentType == .AvatarAgent ? AUIAICallBundle.getString("AI Avatar Call") : AUIAICallBundle.getString("AI Voice Call")

        self.callContentView.frame = self.view.bounds
        self.callContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContentViewClicked(recognizer:))))
        
        self.settingBtn.frame = CGRect(x: self.view.av_width - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44)
        self.bottomView.frame = CGRect(x: 0, y: self.view.av_height - UIView.av_safeBottom - 160, width: self.view.av_width, height: 160)
        self.bottomView.isHidden = false
                
        UIViewController.av_setIdleTimerDisabled(true)
        
        self.controller.delegate = self
        self.controller.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.callContentView.callStateAni.start()
    }
    
    func applicationWillResignActive() {
        self.callContentView.callStateAni.stop()
        self.callContentView.voiceAgentAniView?.stop()
    }
    
    func applicationDidBecomeActive() {
        self.callContentView.callStateAni.start()
        self.callContentView.voiceAgentAniView?.start()
    }
    
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public let controller: AUIAICallControllerInterface
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.mediumFont(16)
        label.text = AUIAICallBundle.getString("AI Voice Call")
        self.view.addSubview(label)
        return label
    }()
    
    open lazy var callContentView: AUIAICallContentView = {
        let view = AUIAICallContentView()
        self.view.addSubview(view)
        return view
    }()
    
    open lazy var settingBtn: UIButton = {
        let btn = UIButton()
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_setting"), for: .normal)
        btn.addTarget(self, action: #selector(onSettingBtnClicked), for: .touchUpInside)
        self.view.addSubview(btn)
        return btn
    }()
    
    open lazy var bottomView: AUIAICallBottomView = {
        let view = AUIAICallBottomView()
        view.switchSpeakerBtn.isSelected = self.controller.config.enableSpeaker == false
        view.muteAudioBtn.isSelected = self.controller.config.muteMicrophone == true
        view.handupBtn.tappedAction = { [weak self] btn in
            self?.controller.handup()
        }
        view.switchSpeakerBtn.tappedAction = { [weak self] btn in
            if self?.controller.state != .Connected {
                btn.isSelected = !btn.isSelected
                self?.controller.config.enableSpeaker = !btn.isSelected
                return
            }
            self?.controller.enableSpeaker(enable: btn.isSelected)
            btn.isSelected = self?.controller.config.enableSpeaker == false
        }
        view.muteAudioBtn.tappedAction = { [weak self] btn in
            if self?.controller.state != .Connected {
                btn.isSelected = !btn.isSelected
                self?.controller.config.muteMicrophone = btn.isSelected
                return
            }
            self?.controller.switchMicrophone(off: !btn.isSelected)
            btn.isSelected = self?.controller.config.muteMicrophone == true
        }
        self.view.addSubview(view)
        return view
    }()
    
    // 当前通话时间（单位：秒）
    public private(set) var callingSeconds = 0.0
    private lazy var countdownTimer: Timer = {
        let timer = Timer(timeInterval: 0.10, repeats: true) {[weak self] timer in
            if let self = self {
                self.callingSeconds = self.callingSeconds + 0.10
                let time = AVStringFormat.format(withDuration: Float(self.callingSeconds))
                self.bottomView.timeLabel.text = time
                
                self.printingAgentText()
                
                self.checkCallLimit()
            }
        }
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }()
    
    private var lastAgentSentenceId: Int? = nil
    private var currAgentSpeakingTokens: [String] = []
    private var nextAgentSpeakingTokenIndex: Int = 0
    private var isAgentPrintingText: Bool = false

    
    private func printingAgentText() {
        if self.isAgentPrintingText == false {
            return
        }
        
        if self.currAgentSpeakingTokens.count > self.nextAgentSpeakingTokenIndex {
            var currAgentPrintedText = ""
            for i in 0...self.nextAgentSpeakingTokenIndex {
                currAgentPrintedText.append(self.currAgentSpeakingTokens[i])
            }
            self.callContentView.updateSubTitle(enable: true, isLLM: true, text: currAgentPrintedText, clear: false)
            self.self.nextAgentSpeakingTokenIndex += 1
        }
    }
    
    private func checkCallLimit() {
        let limitSecond = self.controller.config.limitSecond
        if limitSecond == 0 {
            return
        }
        
        if Double(limitSecond) <= self.callingSeconds {
            self.controller.currentEngine.handup()
            self.countdownTimer.invalidate()
            self.callContentView.callStateAni.stop()
            self.callContentView.voiceAgentAniView?.stop()
            AVAlertController.show(withTitle: nil, message: AUIAICallBundle.getString("The call has ended. The avatar agent call can only be experienced for 5 minutes."), needCancel: false) { isCancel in
                self.controller.handup()
            }
        }
    }
}

extension AUIAICallViewController {
    
    @objc open func onSettingBtnClicked() {
        if self.controller.state != .Connected {
            AVToastView.show(AUIAICallBundle.getString("Currently Not Connected"), view: self.view, position: .mid)
            return
        }
        AUIAICallSettingPanel.enableVoiceIdSwitch = self.controller.config.agentType != .AvatarAgent
        let panel = AUIAICallSettingPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
        panel.refreshUI(config: self.controller.config)
        panel.applyPlayBlock = { [weak self] item in
            self?.controller.switchVoiceId(voiceId: item.voiceId, completed: { error in
                
            })
        }
        panel.interruptBlock = { [weak self, weak panel] isOn in
            self?.controller.enableVoiceInterrupt(enable: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        panel?.interruptSwitch.switchBtn.isOn = self.controller.config.enableVoiceInterrupt
                        AVToastView.show(AUIAICallBundle.getString("Failed to Switch Smart Interruption"), view: self.view, position: .mid)
                        return
                    }
                    if self.controller.config.enableVoiceInterrupt {
                        AVToastView.show(AUIAICallBundle.getString("Smart Interruption is Turned On"), view: self.view, position: .mid)
                    }
                    else {
                        AVToastView.show(AUIAICallBundle.getString("Smart Interruption is Turned Off"), view: self.view, position: .mid)
                    }
                }
            })
        }
        panel.show(on: self.view, with: .clickToClose)
    }
    
    @objc open func onContentViewClicked(recognizer: UIGestureRecognizer) {
        self.controller.interruptSpeaking()
    }
}

extension AUIAICallViewController: AUIAICallControllerDelegate {
    
    public func onAICallAIAgentStarted() {
        self.callContentView.updateAgentType(agentType: self.controller.config.agentType)
        if self.controller.config.agentType == .AvatarAgent {
            self.controller.setAgentView(view: self.callContentView.avatarAgentView, mode: .Auto)
        }
        self.titleLabel.text = self.controller.config.agentType == .AvatarAgent ? AUIAICallBundle.getString("AI Avatar Call") : AUIAICallBundle.getString("AI Voice Call")
    }
    
    public func onAICallStateChanged() {
        ARTCAICallEngineDebuger.PrintLog("Call State Changed: \(self.controller.state)")
        self.callContentView.callStateAni.updateState(newState: self.controller.state)
        
        if self.controller.state == .Connected {
            self.callContentView.callStateAni.isHidden = true
            self.callContentView.callStateAni.stop()
            self.callContentView.voiceAgentAniView?.isHidden = false
            self.callContentView.voiceAgentAniView?.start()
            self.callContentView.avatarAgentView?.isHidden = false
            
            // 启动计时
            self.countdownTimer.fire()
        }
        else if self.controller.state == .Over {
            self.countdownTimer.invalidate()
            self.callContentView.callStateAni.stop()
            self.callContentView.voiceAgentAniView?.stop()
        }
        
        // 更新提示语
        if self.controller.state == .None {
            self.callContentView.tipsLabel.text = nil
        }
        else if self.controller.state == .Connecting {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Connecting...")
        }
        else if self.controller.state == .Connected {
            self.onAICallAgentStateChanged()
        }
        else if self.controller.state == .Over {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Call Ended")
        }
        else if self.controller.state == .Error {
            ARTCAICallEngineDebuger.PrintLog("Call Error: \(self.controller.errorCode)")
            var msg = AUIAICallBundle.getString("An Error Occurred During the Call")
            switch self.controller.errorCode {
            case .BeginCallFailed:
                msg = AUIAICallBundle.getString("Cannot Start Call, Service Issue Detected")
                break
            case .TokenExpired:
                msg = AUIAICallBundle.getString("Call Failed, Authorization Expired")
                break
            case .ConnectionFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .PublishFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .SubscribeFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .KickedByUserReplace:
                msg = AUIAICallBundle.getString("Call Failed, User May Be Logined Another Device")
                break
            case .KickedBySystem:
                msg = AUIAICallBundle.getString("Call Failed, Ended by System")
                break
            case .KickedByChannelTerminated:
                msg = AUIAICallBundle.getString("Call Failed, Ended by System")
                break
            case .LocalDeviceException:
                msg = AUIAICallBundle.getString("Call Failed, Local Device Error")
                break
            case .AgentLeaveChannel:
                msg = AUIAICallBundle.getString("Call Failed, Agent Stopped")
                break
            case .AgentPullFailed:
                msg = AUIAICallBundle.getString("Call Failed, Agent Failed to Pull Stream")
                break
            case .AgentASRFailed:
                msg = AUIAICallBundle.getString("Call Failed, The Third Party Service of ASR Failed to Start")
                break
            case .AvatarServiceFailed:
                msg = AUIAICallBundle.getString("Call Failed, Avatar Agent Service Failed to Start")
                break
            case .AvatarRoutesExhausted:
                msg = AUIAICallBundle.getString("Call Ended")
                break
            case .UnknowError:
                msg = AUIAICallBundle.getString("Call Failed, Unknow Error")
                break
            default:
                break
            }
            self.callContentView.tipsLabel.text = msg
            self.countdownTimer.invalidate()
            self.callContentView.callStateAni.stop()
            self.callContentView.voiceAgentAniView?.stop()
            
            if self.controller.errorCode == .AvatarRoutesExhausted {
                AVAlertController.show(withTitle: nil, message: AUIAICallBundle.getString("AI avatar calling is in high demand, please try again later or enjoy the new experience of AI voice calling first."), needCancel: false) { isCancel in
                    self.controller.handup()
                    
                }
            }
        }
        
        // 挂断处理
        if self.controller.state == .Over {
            #if AICALL_ENABLE_FEEDBACK
            if self.controller.errorCode == .AvatarRoutesExhausted {
                self.dismiss(animated: true)
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100)) {
                    self.dismiss(animated: true) {
                        
                        AUIAICallFeedback.shared.tryToShowFeedback(controller: self.controller, vc: UIViewController.av_top())
                    }
                }
            }
            #else
            self.dismiss(animated: true)
            #endif
        }
    }
    
    public func onAICallAgentStateChanged() {
        if self.controller.agentState == .Listening {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("You Talk, I'm Listening...")
            self.isAgentPrintingText = false
            self.callContentView.updateSubTitle(enable: false, isLLM: false, text: "", clear: true)
        }
        else if self.controller.agentState == .Thinking {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Thinking...")
        }
        else if self.controller.agentState == .Speaking {
            if self.controller.config.enableVoiceInterrupt {
                self.callContentView.tipsLabel.text = AUIAICallBundle.getString("I'm Replying, Tap Screen or Speak to Interrupt Me")
            }
            else {
                self.callContentView.tipsLabel.text = AUIAICallBundle.getString("I'm Replying, Tap Screen to Interrupt Me")
            }
        }
        
        self.callContentView.voiceAgentAniView?.updateAgentState(newState: self.controller.agentState)
    }
    
    public func onAICallActiveSpeakerVolumeChanged(userId: String, volume: Int32) {
        if userId == self.controller.userId {
            self.callContentView.voiceAgentAniView?.listeningAniView.isSpeaking = volume > 10
        }
        else {
            self.callContentView.voiceAgentAniView?.listeningAniView.isSpeaking = false
        }
    }
    
    public func onAICallAgentSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        var tokens: [String] = []
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = text
        tagger.enumerateTags(in: NSRange(location: 0, length: text.utf16.count), scheme: .tokenType, options: []) { tag, tokenRange, _, _  in
            let word = (text as NSString).substring(with: tokenRange)
            tokens.append(word)
        }
        if userAsrSentenceId != self.lastAgentSentenceId {
            self.lastAgentSentenceId = userAsrSentenceId
            self.nextAgentSpeakingTokenIndex = 0
            self.currAgentSpeakingTokens.removeAll()
        }
        self.currAgentSpeakingTokens.append(contentsOf: tokens)

        self.isAgentPrintingText = true
    }
    
    public func onAICallUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int) {
        self.isAgentPrintingText = false
        self.callContentView.updateSubTitle(enable: true, isLLM: false, text: text, clear: false)

    }
}
