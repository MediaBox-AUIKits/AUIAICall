//
//  AUIAICallViewController.swift
//  AUIAICall
//
//  Created by Bingo on 2024/7/8.
//

import UIKit
import AUIFoundation

@objcMembers open class AUIAICallViewController: UIViewController {
    
    public init(_ engine: ARTCAICallEngine) {
        self.engine = engine
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

        self.callContentView.frame = self.view.bounds
        self.callContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContentViewClicked(recognizer:))))
        
        self.settingBtn.frame = CGRect(x: self.view.av_width - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44)
        self.bottomView.frame = CGRect(x: 0, y: self.view.av_height - UIView.av_safeBottom - 160, width: self.view.av_width, height: 160)
        self.bottomView.isHidden = false
                
        UIViewController.av_setIdleTimerDisabled(true)
        
        self.engine.delegate = self
        self.engine.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.callContentView.robotStateAni.start()
    }
    
    func applicationWillResignActive() {
        self.callContentView.robotStateAni.stop()
    }
    
    func applicationDidBecomeActive() {
        self.callContentView.robotStateAni.start()
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
    
    public let engine: ARTCAICallEngine
    
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
        view.switchSpeakerBtn.isSelected = self.engine.config.enableSpeaker == false
        view.muteAudioBtn.isSelected = self.engine.config.muteMicrophone == true
        view.handupBtn.tappedAction = { [weak self] btn in
            self?.engine.handup()
        }
        view.switchSpeakerBtn.tappedAction = { [weak self] btn in
            if self?.engine.state != .Connected {
                btn.isSelected = !btn.isSelected
                self?.engine.config.enableSpeaker = !btn.isSelected
                return
            }
            self?.engine.enableSpeaker(enable: btn.isSelected)
            btn.isSelected = self?.engine.config.enableSpeaker == false
        }
        view.muteAudioBtn.tappedAction = { [weak self] btn in
            if self?.engine.state != .Connected {
                btn.isSelected = !btn.isSelected
                self?.engine.config.muteMicrophone = btn.isSelected
                return
            }
            self?.engine.switchMicrophone(off: !btn.isSelected)
            btn.isSelected = self?.engine.config.muteMicrophone == true
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
                
                self.printingRobotText()
            }
        }
        RunLoop.current.add(timer, forMode: .default)
        return timer
    }()
    
    private var lastRobotSentenceId: Int? = nil
    private var currRobotSpeakingTokens: [String] = []
    private var nextRobotSpeakingTokenIndex: Int = 0
    private var isRobotPrintingText: Bool = false

    
    private func printingRobotText() {
        if self.isRobotPrintingText == false {
            return
        }
        
        if self.currRobotSpeakingTokens.count > self.nextRobotSpeakingTokenIndex {
            var currRobotPrintedText = ""
            for i in 0...self.nextRobotSpeakingTokenIndex {
                currRobotPrintedText.append(self.currRobotSpeakingTokens[i])
            }
            self.callContentView.updateSubTitle(enable: true, isLLM: true, text: currRobotPrintedText, clear: false)
            self.self.nextRobotSpeakingTokenIndex += 1
        }
    }
}

extension AUIAICallViewController {
    
    @objc open func onSettingBtnClicked() {
        if self.engine.state != .Connected {
            AVToastView.show(AUIAICallBundle.getString("Currently Not Connected"), view: self.view, position: .mid)
            return
        }
        
        let panel = AUIAICallSettingPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
        panel.refreshUI(config: self.engine.config)
        panel.applyPlayBlock = { [weak self] item in
            self?.engine.switchRobotVoice(voiceId: item.voiceId, completed: { error in
                
            })
        }
        panel.interruptBlock = { [weak self, weak panel] isOn in
            self?.engine.enableVoiceInterrupt(enable: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        panel?.interruptSwitch.switchBtn.isOn = self.engine.config.enableVoiceInterrupt
                        AVToastView.show(AUIAICallBundle.getString("Failed to Switch Smart Interruption"), view: self.view, position: .mid)
                        return
                    }
                    if self.engine.config.enableVoiceInterrupt {
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
        self.engine.interruptSpeaking(completed: nil)
    }
}

extension AUIAICallViewController: ARTCAICallEngineDelegate {
    
    public func onAICallEngineStateChanged() {
        // 启动计时
        if self.engine.state == .Connected {
            self.countdownTimer.fire()
        }
        else if self.engine.state == .Over {
            self.countdownTimer.invalidate()
        }
        
        // 更新提示语
        if self.engine.state == .None {
            self.callContentView.tipsLabel.text = nil
        }
        else if self.engine.state == .Connecting {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Connecting...")
        }
        else if self.engine.state == .Connected {
            self.onAICallEngineRobotStateChanged()
        }
        else if self.engine.state == .Over {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Call Ended")
        }
        else if self.engine.state == .Error {
            var msg = AUIAICallBundle.getString("An Error Occurred During the Call")
            switch self.engine.errorCode {
            case .StartFailed:
                msg = AUIAICallBundle.getString("Cannot Start Call, Service Issue Detected")
                break
            case .TokenExpired:
                msg = AUIAICallBundle.getString("Call Failed, Authorization Expired")
                break
            case .ConnectionFailed:
                msg = AUIAICallBundle.getString("Call Failed, Network Connection Issue")
                break
            case .kickedByUserReplace:
                msg = AUIAICallBundle.getString("Call Failed, User May Be Logined Another Device")
                break
            case .kickedBySystem:
                msg = AUIAICallBundle.getString("Call Failed, Ended by System")
                break
            case .LocalDeviceException:
                msg = AUIAICallBundle.getString("Call Failed, Local Device Error")
                break
            case .none:
                break
            }
            self.callContentView.tipsLabel.text = msg
        }
        
        // 挂断处理
        if self.engine.state == .Over {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100)) {
                self.dismiss(animated: true)
                if let window = UIView.av_keyWindow {
                    AVToastView.show(AUIAICallBundle.getString("Call Ended"), view: window, position: .mid)
                }
            }
        }
    }
    
    public func onAICallEngineRobotStateChanged() {
        if self.engine.robotState == .Listening {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("You Talk, I'm Listening...")
            self.isRobotPrintingText = false
            self.callContentView.updateSubTitle(enable: false, isLLM: false, text: "", clear: true)
        }
        else if self.engine.robotState == .Thinking {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Thinking...")
        }
        else if self.engine.robotState == .Speaking {
            if self.engine.config.enableVoiceInterrupt {
                self.callContentView.tipsLabel.text = AUIAICallBundle.getString("I'm Replying, Tap Screen or Speak to Interrupt Me")
            }
            else {
                self.callContentView.tipsLabel.text = AUIAICallBundle.getString("I'm Replying, Tap Screen to Interrupt Me")
            }
        }
        
        self.callContentView.robotStateAni.updateRobotState(newState: self.engine.robotState)
    }
    
    public func onAICallEngineActiveSpeakerVolumeChanged(userId: String, volume: Int32) {
        if userId == self.engine.userId {
            self.callContentView.robotStateAni.listeningAniView.isSpeaking = volume > 10
        }
        else {
            self.callContentView.robotStateAni.listeningAniView.isSpeaking = false
        }
    }
    
    public func onAICallEngineRobotSubtitleNotify(text: String, isSentenceEnd: Bool, userAsrSentenceId: Int) {
        var tokens: [String] = []
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = text
        tagger.enumerateTags(in: NSRange(location: 0, length: text.utf16.count), scheme: .tokenType, options: []) { tag, tokenRange, _, _  in
            let word = (text as NSString).substring(with: tokenRange)
            tokens.append(word)
        }
        if userAsrSentenceId != self.lastRobotSentenceId {
            self.lastRobotSentenceId = userAsrSentenceId
            self.nextRobotSpeakingTokenIndex = 0
            self.currRobotSpeakingTokens.removeAll()
        }
        self.currRobotSpeakingTokens.append(contentsOf: tokens)

        self.isRobotPrintingText = true
    }
    
    public func onAICallEngineUserAsrSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int) {
        self.isRobotPrintingText = false
        self.callContentView.updateSubTitle(enable: true, isLLM: false, text: text, clear: false)

    }
}
