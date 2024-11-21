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
        
        self.callContentView.frame = self.view.bounds
        self.callContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onContentViewClicked(recognizer:))))
        self.callContentView.updateAgentType(agentType: self.controller.config.agentType)
        
        self.titleLabel.frame = CGRect(x: 0, y: UIView.av_safeTop, width: self.view.av_width, height: 44)
        self.updateTitle()

        self.settingBtn.frame = CGRect(x: self.view.av_width - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44)
        #if AICALL_ENABLE_FEEDBACK
        self.reportBtn = self.setupReportBtn()
        #endif
        
        self.bottomView.frame = CGRect(x: 0, y: self.view.av_height - 308, width: self.view.av_width, height: 308)
        self.bottomView.isHidden = false
        self.bottomView.enablePushToTalk = self.controller.config.enablePushToTalk
                
        UIViewController.av_setIdleTimerDisabled(true)
        
        self.controller.delegate = self
        self.controller.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.callContentView.callStateAni.start()
    }
    
    public var onUserTokenExpiredBlcok: (()->Void)? = nil
    
    @objc private func applicationWillResignActive() {
        self.callContentView.callStateAni.stop()
        self.callContentView.voiceAgentAniView?.stop()
    }
    
    @objc private func applicationDidBecomeActive() {
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
    public var enableVoiceIdSwitch: Bool = true
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AVTheme.text_strong
        label.textAlignment = .center
        label.font = AVTheme.mediumFont(16)
        label.numberOfLines = 0
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTitleLabelTap)))
        label.isUserInteractionEnabled = true
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
        btn.setImage(AUIAICallBundle.getCommonImage("ic_setting_selected"), for: .selected)
        btn.addTarget(self, action: #selector(onSettingBtnClicked), for: .touchUpInside)
        self.view.addSubview(btn)
        return btn
    }()
    
    open var reportBtn: UIButton? = nil
    private weak var settingPanel: AUIAICallSettingPanel? = nil
    
    open lazy var bottomView: AUIAICallBottomView = {
        let view = AUIAICallBottomView(agentType: self.controller.config.agentType)
        view.switchSpeakerBtn.isSelected = self.controller.config.enableSpeaker == false
        view.muteAudioBtn.isSelected = self.controller.config.muteMicrophone == true
        view.muteCameraBtn.isSelected = self.controller.config.muteLocalCamera == true
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
            self?.controller.muteMicrophone(mute: !btn.isSelected)
            btn.isSelected = self?.controller.config.muteMicrophone == true
        }
        view.muteCameraBtn.tappedAction = { [weak self] btn in
            self?.controller.muteLocalCamera(mute: !btn.isSelected)
            btn.isSelected = self?.controller.config.muteLocalCamera == true
            self?.callContentView.visionAgentView?.isHidden = !btn.isSelected
            self?.updateSubTitleStyle()
        }
        view.switchCameraBtn.clickBlock = { [weak self] btn in
            self?.controller.switchCamera()
        }
        view.pushToTalkBtn.longPressAction = { [weak self] btn, state, elapsed in
            if state == 1 {
                if elapsed <= 0.5 {
                    _ = self?.controller.cancelPushToTalk()
                    AVToastView.show(AUIAICallBundle.getString("The hold time is too short, sending has been canceled."), view: self!.view, position: .mid)
                }
                else {
                    _ = self?.controller.finishPushToTalk()
                }
                btn.isSelected = false
                debugPrint("ptt: finish elapsed \(elapsed)")
            }
            else if state == 2 {
                _ = self?.controller.cancelPushToTalk()
                AVToastView.show(AUIAICallBundle.getString("You have canceled to send you talk."), view: self!.view, position: .mid)
                btn.isSelected = false
                self?.callContentView.voiceAgentAniView?.listeningAniView.isSpeaking = false
                debugPrint("ptt: cancel elapsed: \(elapsed)")
            }
            else {
                _ = self?.controller.startPushToTalk()
                btn.isSelected = true
                self?.callContentView.voiceAgentAniView?.listeningAniView.isSpeaking = false
                debugPrint("ptt: start elapsed: \(elapsed)")
            }
        }
        self.view.addSubview(view)
        return view
    }()
    
    private func updateTitle() {
        var title = AUIAICallBundle.getString("AI Voice Call")
        if self.controller.config.agentType == .AvatarAgent {
            title = AUIAICallBundle.getString("AI Avatar Call")
        }
        else if self.controller.config.agentType == .VisionAgent {
            title = AUIAICallBundle.getString("AI Vision Call")
        }
        let attributedString = NSMutableAttributedString()
        let firstLine = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: AVTheme.mediumFont(16),
        ])
        attributedString.append(firstLine)
        
        self.titleLabel.attributedText = attributedString
    }
    
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
    private var isTimeToShowSubTitle: Bool = false
    
    private func printingAgentText() {
        if self.isTimeToShowSubTitle == false || self.isAgentPrintingText == false {
            return
        }
        
        if self.currAgentSpeakingTokens.count > self.nextAgentSpeakingTokenIndex {
            var currAgentPrintedText = ""
            for i in 0...self.nextAgentSpeakingTokenIndex {
                currAgentPrintedText.append(self.currAgentSpeakingTokens[i])
            }
            self.callContentView.updateSubTitle(enable: true, isLLM: true, text: currAgentPrintedText, clear: false)
            self.callContentView.voiceprintTipsLabel.isHidden = true
            self.self.nextAgentSpeakingTokenIndex += 1
        }
    }
    
    private func updateSubTitleStyle() {
        if self.controller.config.agentType == .VisionAgent && self.bottomView.muteCameraBtn.isSelected == false && self.controller.state == .Connected {
            self.callContentView.subtitleLabel.textColor = AVTheme.text_ultraweak
            self.titleLabel.textColor = UIColor.av_color(withHexString: "#3A3D48FF")
            self.settingBtn.isSelected = true
            self.reportBtn?.isSelected = true
        }
        else {
            self.callContentView.subtitleLabel.textColor = AVTheme.text_weak
            self.titleLabel.textColor = AVTheme.text_strong
            self.settingBtn.isSelected = false
            self.reportBtn?.isSelected = false
        }
    }
    
    private func checkCallLimit() {
        let limitSecond = self.controller.config.limitSecond
        if limitSecond == 0 {
            return
        }
        
        if Double(limitSecond) <= self.callingSeconds {
            self.controller.currentEngine.handup(true)
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
            AVToastView.show(AUIAICallBundle.getString("Currently not connected"), view: self.view, position: .mid)
            return
        }
        let panel = AUIAICallSettingPanel(frame: CGRect(x: 0, y: 0, width: self.view.av_width, height: 0))
        panel.enableVoiceIdSwitch = self.enableVoiceIdSwitch
        panel.config = self.controller.config
        panel.isVoiceprintRegisted = self.controller.isVoiceprintRegisted
        panel.applyPlayBlock = { [weak self] item in
            self?.controller.switchVoiceId(voiceId: item.voiceId, completed: { error in
                
            })
        }
        panel.interruptBlock = { [weak self, weak panel] isOn in
            self?.controller.enableVoiceInterrupt(enable: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        panel?.interruptSwitch.switchBtn.isOn = self.controller.config.enableVoiceInterrupt
                        AVToastView.show(AUIAICallBundle.getString("Failed to switch smart interruption"), view: self.view, position: .mid)
                        return
                    }
                    
                    if self.controller.config.enableVoiceInterrupt {
                        AVToastView.show(AUIAICallBundle.getString("Smart interruption is turned on"), view: self.view, position: .mid)
                    }
                    else {
                        AVToastView.show(AUIAICallBundle.getString("Smart interruption is turned off"), view: self.view, position: .mid)
                    }
                }
            })
        }
        panel.pushToTalkBlock = { [weak self] isOn in
            self?.controller.enablePushToTalk(enable: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        AVToastView.show(AUIAICallBundle.getString("Failed to enable/disable push to talk Mode"), view: self.view, position: .mid)
                        return
                    }
                }
            })
        }
        panel.voiceprintBlock = { [weak self, weak panel] isOn in
            self?.controller.useVoiceprint(isUse: isOn, completed: { error in
                if let self = self {
                    if error != nil {
                        panel?.voiceprintSettingView.voiceprintSwitch.switchBtn.isOn = self.controller.config.useVoiceprint
                        AVToastView.show(AUIAICallBundle.getString("Failed to switch voiceprint"), view: self.view, position: .mid)
                        return
                    }
                    
                    if self.controller.config.useVoiceprint {
                        AVToastView.show(AUIAICallBundle.getString("Voiceprint is turned on"), view: self.view, position: .mid)
                    }
                    else {
                        AVToastView.show(AUIAICallBundle.getString("Voiceprint is turned off"), view: self.view, position: .mid)
                    }
                }
            })
        }
        panel.clearVoiceprintBlock = { [weak self] sender in
            if let self = self {
                if self.controller.clearVoiceprint() == true {
                    sender.isVoiceprintRegisted = self.controller.isVoiceprintRegisted
                }
                else {
                    AVToastView.show(AUIAICallBundle.getString("Failed to clear voiceprint's data"), view: self.view, position: .mid)
                }
            }
        }
        panel.show(on: self.view, with: .clickToClose)
        self.settingPanel = panel
    }

    @objc open func onContentViewClicked(recognizer: UIGestureRecognizer) {
        self.controller.interruptSpeaking()
    }
    
    @objc func onTitleLabelTap() {
#if DEMO_FOR_DEBUG
        self.showDebugInfo()
#endif
    }
    
}

extension AUIAICallViewController: AUIAICallControllerDelegate {
    
    public func onAICallAIAgentStarted(agentInfo: ARTCAICallAgentInfo) {
        self.callContentView.updateAgentType(agentType: self.controller.config.agentType)
        if self.controller.config.agentType == .AvatarAgent {
            self.controller.setAgentView(view: self.callContentView.avatarAgentView, mode: .Auto)
        }
        else if self.controller.config.agentType == .VisionAgent {
            let visionConfig = ARTCAICallVisionConfig(preview: self.callContentView.visionCameraView, viewMode: .Auto)
            self.controller.currentEngine.visionConfig = visionConfig
        }
        self.updateTitle()
    }
    
    public func onAICallStateChanged() {
        ARTCAICallEngineLog.WriteLog(.Debug, "Call State Changed: \(self.controller.state)")
        self.callContentView.callStateAni.updateState(newState: self.controller.state)
        
        if self.controller.state == .Connected {
            self.callContentView.callStateAni.isHidden = true
            self.callContentView.callStateAni.stop()
            self.callContentView.voiceAgentAniView?.isHidden = false
            self.callContentView.voiceAgentAniView?.start()
            self.callContentView.avatarAgentView?.isHidden = false
            self.callContentView.visionCameraView?.isHidden = false
            self.callContentView.visionAgentView?.isHidden = !self.controller.config.muteLocalCamera
            self.updateSubTitleStyle()
            
            // 启动计时
            self.countdownTimer.fire()
            
            if self.controller.config.agentType == .VoiceAgent || self.self.controller.config.agentType == .VisionAgent {
                self.isTimeToShowSubTitle = true
            }
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
            ARTCAICallEngineLog.WriteLog(.Error, "Call Error: \(self.controller.errorCode)")
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
            self.showFeedback()
            #else
            self.dismiss(animated: true)
            #endif
        }
    }
    
    public func onAICallAgentStateChanged() {
        if self.controller.agentState == .Listening {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("You Talk, I'm Listening...")
        }
        else if self.controller.agentState == .Thinking {
            self.callContentView.tipsLabel.text = AUIAICallBundle.getString("Thinking...")
        }
        else if self.controller.agentState == .Speaking {
            if self.controller.config.enableVoiceInterrupt && !self.controller.config.enablePushToTalk {
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
    
    public func onAICallUserSubtitleNotify(text: String, isSentenceEnd: Bool, sentenceId: Int, voiceprintResult: ARTCAICallVoiceprintResult) {
        if self.isTimeToShowSubTitle == false {
            return
        }
        
        self.isAgentPrintingText = false
        
#if DEMO_FOR_DEBUG
        let text = self.getUserSubtitle(text: text, voiceprintResult: voiceprintResult)
#endif
        self.callContentView.updateSubTitle(enable: true, isLLM: false, text: text, clear: false)
        if isSentenceEnd && voiceprintResult == .UndetectedSpeaker {
            self.callContentView.voiceprintTipsLabel.isHidden = false
        }
        else {
            self.callContentView.voiceprintTipsLabel.isHidden = true
        }
    }
    
    public func onAICallUserTokenExpired() {
        AVAlertController.show(withTitle: nil, message: AUIAICallBundle.getString("Log in token expired, please try log in."), needCancel: false) { isCancel in
            self.controller.handup()
            self.onUserTokenExpiredBlcok?()
        }
    }
    
    public func onAICallAvatarFirstFrameDrawn() {
        self.isTimeToShowSubTitle = true
    }
    
    public func onAICallAgentPushToTalkChanged(enable: Bool) {
        self.settingPanel?.config = self.controller.config
        self.bottomView.enablePushToTalk = self.controller.config.enablePushToTalk
        if self.controller.config.enablePushToTalk {
            AVToastView.show(AUIAICallBundle.getString("Push to talk mode is turned on"), view: self.view, position: .mid)
        }
        else {
            AVToastView.show(AUIAICallBundle.getString("Push to talk mode is turned off"), view: self.view, position: .mid)
        }
    }
    
    public func onAICallAgentWillLeave(reason: Int32, message: String) {
        self.controller.handup()
        if let keyWindow = UIView.av_keyWindow {
            var toast = AUIAICallBundle.getString("The call has ended.")
            if reason == 2001 {
                toast = AUIAICallBundle.getString("Due to your prolonged inactivity, the call has ended.")
            }
            AVToastView.show(toast, view: keyWindow, position: .mid)
        }
    }
}

#if AICALL_ENABLE_FEEDBACK
extension AUIAICallViewController {
    
    func showFeedback() {
        if self.controller.errorCode == .AvatarRoutesExhausted ||
            self.controller.errorCode == .BeginCallFailed ||
            self.controller.errorCode == .TokenExpired{
            self.dismiss(animated: true)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100)) {
                self.dismiss(animated: true) {
                    AUIAICallFeedback.shared.tryToShowFeedback(controller: self.controller, vc: UIViewController.av_top())
                }
            }
        }
    }
    
    func setupReportBtn() -> UIButton {
        AUIAICallReport.shared.setup()
        
        let btn = AVBlockButton()
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_report"), for: .normal)
        btn.setImage(AUIAICallBundle.getCommonImage("ic_report_select"), for: .selected)
        btn.clickBlock = { [weak self] btn in
            self?.av_presentFullScreenViewController(AUIAICallReportViewController(), animated: true)
        }
        self.view.addSubview(btn)
        btn.frame = CGRect(x: self.settingBtn.av_left - 6 - 44, y: UIView.av_safeTop, width: 44, height: 44)
        return btn
    }
}
#endif

#if DEMO_FOR_DEBUG
extension AUIAICallViewController {
    
    func showDebugInfo() {
        var info = "instanceId:\(self.controller.agentInfo?.instanceId ?? "")\n"
        info.append("channelId:\(self.controller.agentInfo?.channelId ?? "")\n")
        info.append("agentUid:\(self.controller.agentInfo?.uid ?? "")\n")
        info.append("agentType:\(self.controller.agentInfo?.agentType.rawValue ?? 0)\n")
        info.append("userId:\(self.controller.userId)\n")
        
        AVAlertController.show(withTitle: "Debug", message: info, cancelTitle: "Close", okTitle: "Copy") { isCancel in
            if !isCancel {
                UIPasteboard.general.string = info
            }
        }
    }
    
    func getUserSubtitle(text: String, voiceprintResult: ARTCAICallVoiceprintResult) -> String {
        if self.controller.config.voiceprintId != nil && self.controller.config.useVoiceprint {
            return "[\(voiceprintResult.rawValue)]\(text)"
        }
        return text
    }
    
}
#endif
